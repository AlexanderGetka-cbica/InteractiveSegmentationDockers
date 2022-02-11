#!/bin/bash

# Print tool, studyPath, and launch captk with that

# Do any pre-processing that is done per-study at load-time here.

# For right now: just parse over the corresponding study dir for any files.

# Exit and log if any command fails for debugging
# Disabled for now to allow pgrep
#set -e
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
                #trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

#echo "Received a request to load a study in the interactive session."
#echo $INTROSPECT_URL
# This script will fail if the user ID isn't the same as that passed in at container run-time.
# FOR RIGHT NOW this will succeed for any user so long as the token is active.

userIdentifier=`/etc/scripts/get-uid-from-token.py $1 2>/dev/null`
userName=`/etc/scripts/get-sub-from-token.py $1 2>/dev/null`

/etc/scripts/validate-token-okta.py "$1" >> /home/researcher/load-study.log 2>&1

if [ "$?" = 0 ]; then
 echo "Token successfully validated." >> /home/researcher/load-study.log
else
 echo "Token validation failed. Halting." >> /home/researcher/load-study.log
 #echo "Status: 403\n\nToken validation failed.\n"
 echo "403"
 exit 1
fi

echo "Done validating token." >> /home/researcher/load-study.log

/etc/scripts/change-active-user.sh "$userIdentifier" >> /home/researcher/load-study.log 2>&1

if [ "$?" = 0 ]; then
 echo "User with identifier $userIdentifier logged in successfully." >> /home/researcher/load-study.log
else
 echo "User couldn't be logged in. Halting." >> /home/researcher/load-study.log
 #echo "Status: 423\n\nCouldn't log in user $userIdentifier. Session already has a user.\n"
 echo "423"
 exit 1
fi

echo "Done changing user identifier." >> /home/researcher/load-study.log
#DISPLAY=:0 xautolock -restart



# First thing: check if the user is already running a captk process, fail if so
tsp -S 5 #First, set tsp num-jobs to >1 so zenity messages can work without blocking
number_loadstudy_processes=`pgrep -c /etc/scripts/load-study.sh`
number_captk_processes=`pgrep -c CaPTk`
if [ "$?" = 0 ]; then
  # check if too many are open
  echo "Pgrep found some existing CaPTk processes" >> /home/researcher/load-study.log
  # Check if captk instance already exists OR if another load-study is already going (not incl. this one)
  if (( number_captk_processes > 0 )) || (( number_loadstudy_processes > 1)); then
    #if [ -f  "/home/researcher/delaytimer" ]; then # Cancel pending termination to give user a chance to come back.
    #   /etc/scripts/clear-pending-terminate.sh >> /home/researcher/clear-pending-terminate.log 2>&1
    #fi
    # User already has a CaPTk window
    #tsp bash -c 'DISPLAY=:0 zenity --warning --title="Session Warning" --width=480 --text="You are at the limit for active CaPTk instances in this session. Please close one before loading another study." ' >/dev/null 2>/dev/null
    #tsp bash -c 'DISPLAY=:0 zenity --warning --title="Session Warning" --width=480 --text="You are at the limit for active CaPTk instances in this session (1). Please close one (either by clicking the X at the top right of the CaPTk window, or right clicking the entry in the taskbar) before loading another study." >>/home/researcher/load-study.log 2>&1 &' >> /home/researcher/load-study.log 2>&1
    # tsp up a separate script to ask user for confirmation of study-load
    tsp /etc/scripts/ask-user-load-study.sh "$@" >> /home/researcher/load-study.log 2>&1 &
    echo "User is at the CaPTk session limit for this container." >> /home/researcher/load-study.log
    # Fail with a specific code (for shell2http)
    #echo "Status: 429\n\nReached the CaPTk instance limit.\n"
    echo "429"
    exit 1
  fi
else
 # can continue normally
 echo "Pgrep failed to find existing CaPTk processes" >> /home/researcher/load-study.log
fi

# Actually getting to study data now.


# $2 is studyPath, $3 is openWith (all from payload)  $1 is provided access token (from url), $6 is refresh token.
# $4 is the transactionID, $5 is outputFolderPath (both passed to CaPTk in ACR-mode). outputFolderPath should be a location under a shared mount.
# e.g. mount a folder in called shared-output, specify it as output dir, CaPTk writes to "shared-output/transactionID/"
echo "Looking for studyPath $2 under shared mount, attempting to open with tool: $3 ." >> /home/researcher/load-study.log
search_dir="/home/researcher/shared-mount/$2"
study_instance_uid=`/etc/scripts/get-study-instance-uid-from-dir.py "$search_dir"`
input_images=""
nifti_dir="/home/researcher/nifti-conversions/$2"
output_dir="/home/researcher/session-output/$5"
transactionID="$4"
refresh_token="$6"
shopt -s nocasematch

if [[ -z "$2" ]]; then
  # StudyPath is empty -- do not proceed, as this is a leakage risk right now.
  echo "404"
  exit 1
fi

DART_STUDY_INSTANCE_UID="$study_instance_uid"
export DART_STUDY_INSTANCE_UID
DART_TRANSACTION_ID="$transactionID"
export DART_TRANSACTION_ID
DART_USER_ID="$userIdentifier"
export DART_USER_ID
DART_USER_NAME="$userName"
export DART_USER_NAME
NOTIFY_DART_JOBDONE_SCRIPT_PATH=/etc/scripts/notify-dart-annotation-created.py
export NOTIFY_DART_JOBDONE_SCRIPT_PATH
DART_USER_ACCESSTOKEN="$1"
export DART_USER_ACCESSTOKEN
DART_CAPTK_OUTPUT_DIR_ROOT="$output_dir"
export DART_CAPTK_OUTPUT_DIR_ROOT
DART_CAPTK_OUTPUT_MOUNTPOINT=/home/researcher/session-output/
export DART_CAPTK_OUTPUT_MOUNTPOINT

echo "Done exporting variables." >> /home/researcher/load-study.log

echo "Attempting to create output location (if necessary)" >> /home/researcher/load-study.log
mkdir -pv "$DART_CAPTK_OUTPUT_DIR_ROOT" >> /home/researcher/load-study.log 2>&1
echo "Done checking output dir." >> /home/researcher/load-study.log


# Check if the dir exists, otherwise fail
if ! [[ -d "$search_dir" ]]; then
  #tsp DISPLAY=:0 zenity --error --title="Could not load study" --text="Couldn't load the requested study. Please submit a bug report." >/dev/null
  #echo "Status: 404\n\nStudy not found.\n"
  echo "404"
  exit 1
fi

echo "Done checking search dir existence." >> /home/researcher/load-study.log

echo "Creating refresh token file." >>/home/researcher/load-study.log
if [[ -f /home/researcher/refresh ]]; then
  rm -f /home/researcher/refresh
fi
echo "$refresh_token" > /home/researcher/refresh
echo "Done creating refresh token file.">>/home/researcher/load-study.log

DISPLAY=:0 xautolock -exit 1>/home/researcher/xautolock.log 2>&1
tsp bash -c 'DISPLAY=:0 xautolock -time 20 -locker /etc/scripts/start-timeout.sh 1>/home/researcher/xautolock.log 2>&1 &' >/dev/null 2>&1

# Create corresponding nifti location as needed (clear if it exists for now, to make sure conversion happens without duplicates)
if [[ -d "$nifti_dir" ]]; then
  rm -rf "$nifti_dir"
fi
mkdir -p "$nifti_dir"

echo "Done creating nifti dir." >> /home/researcher/load-study.log

# Perform nifti-conversion on the study, place output in corresponding nifti dir
command="/opt/captk/squashfs-root/usr/bin/dcm2niix -o $nifti_dir -z y $search_dir"
$command >> /home/researcher/load-study.log

echo "Done conversion to NIFTI with dcm2niix." >> /home/researcher/load-study.log

# Parse for the generated NIfTI files, and not the tilt ones
TILT_STRING="_Tilt_"
# Note that we now assume the only images present here are .nii.gz NIfTIs (alongside the .json header info from the original DICOMs)
for entry in "$nifti_dir"/*
do
  if [[ -f "$entry" ]]; then
    #echo "entry=$entry"
    filename=`basename "$entry"`
    #fileext="${filename#*.}"
    # Note that we now check via wildcard match to the end, so that filenames with periods work.
    #if [[ "$filename" == *.dcm ]]; then
    #    echo "Detected a DICOM".
    #    input_images+=",$entry";;
        #break;; # Don't break in the top-level case, in case of self-contained single .dcm files
    #fi
    if [[ "$filename" == *.nii.gz ]]; then
        #echo "Detected a NIfTI."
        if [[ "$filename" == *"$TILT_STRING"* ]]; then
           :
           #echo "Detected a tilt image. Ignoring."
        else
            input_images+=",$entry"
        fi
    fi
    if [[ "$filename" == *.json ]]; then
      :
      #echo "Detected a JSON file."
      # Skip for now, we might need to handle this later.
    fi
    continue
  fi
  if [[ -d "$entry" ]]; then
    for subentry in "$entry"/*
    do
      #echo "subentry=$subentry"
      if [[ -f "$subentry" ]]; then
        filename=`basename "$subentry"`
        #fileext="${filename#*.}"
        # Additional steps go here.
      fi
    done
  fi
done

echo "Done checking tilt and forming captk arguments." >> /home/researcher/load-study.log

# Pass to captk.
export MESA_GL_VERSION_OVERRIDE=3.2
export HOME=/home/researcher/
export input_images="$input_images"
command="tsp bash -c '/etc/scripts/run-captk.sh --no-sandbox -acr -sb -i $input_images >/home/researcher/captk.log 2>/home/researcher/captk-err.log'"
#echo "$command"
echo "$command" >> /home/researcher/load-study.log
#PID=`DISPLAY=:0 MESA_GL_VERSION_OVERRIDE=3.2 $command`
PID=`runuser root -c "DISPLAY=:0 MESA_GL_VERSION_OVERRIDE=3.2 HOME=/home/researcher/ $command"`
#sudo -E -u researcher "MESA_GL_VERSION_OVERRIDE=3.2 DISPLAY=:0 $command"
#$command

#If we get here, return Status: 200\n\nOK\n (can be parsed by shell2http)
#echo "Status: 200\n\nOK\n"
#cat /home/researcher/load-study.log

echo "200"
