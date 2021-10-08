#!/bin/bash

# Print tool, studyPath, and launch captk with that

# Do any pre-processing that is done per-study at load-time here.

# For right now: just parse over the corresponding study dir for any files.

# Exit and log if any command fails for debugging
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT


#echo $INTROSPECT_URL
# This script will fail if the user ID isn't the same as that passed in at container run-time.
# FOR RIGHT NOW this will succeed for any user so long as the token is active.
/etc/scripts/validate-token-okta.py "$1"

# $2 is studyPath, $3 is openWith (all from payload)  $1 is provided access token (from url)
echo "Looking for studyPath $2 under shared mount, attempting to open with tool: $3 ."
search_dir="/home/researcher/shared-mount/$2"
input_images=""
nifti_dir="/home/researcher/nifti-conversions/$2"
shopt -s nocasematch

# Create corresponding nifti location as needed (clear if it exists for now, to make sure conversion happens without duplicates)
if [[ -d "$nifti_dir" ]]; then
  rm -rf "$nifti_dir"
fi
mkdir -pv "$nifti_dir"

# Perform nifti-conversion on the study, place output in corresponding nifti dir
command="/opt/captk/squashfs-root/usr/bin/dcm2niix -o $nifti_dir -z y $search_dir"
$command

# Parse for the generated NIfTI files, not the tilt ones
TILT_STRING="_Tilt_"
for entry in "$nifti_dir"/*
do
  if [[ -f "$entry" ]]; then
    echo "entry=$entry"
    filename=`basename "$entry"`
    fileext="${filename#*.}"
    case "$fileext" in
      "dcm")
            echo "Detected a DICOM".
            input_images+=",$entry";;
            #break;; # Don't break in the top-level case, in case of self-contained single .dcm files
      "nii.gz")
            echo "Detected a NIfTI."
            if [[ "$filename" == *"$TILT_STRING"* ]]; then
             echo "Detected a tilt image. Ignoring."
            else
              input_images+=",$entry"
            fi
            ;;
    esac

    #input_images+=",$entry"
    continue
  fi
  if [[ -d "$entry" ]]; then
    for subentry in "$entry"/*
    do
      echo "subentry=$subentry"
      if [[ -f "$subentry" ]]; then
        filename=`basename "$subentry"`
        fileext="${filename#*.}"
        case "$fileext" in
         "dcm")  # Most software can pick up the other dcm files from just one, let's not try to load them all :)
            input_images+=",$subentry"
            break;;
         "nii.gz")
            if [[ "$filename" == *"$TILT_STRING"* ]]; then
             echo "Detected a tilt image. Ignoring."
            else
              input_images+=",$subentry"
            fi
            ;;

        esac
      fi
    done
  fi
done




# Pass to captk.
export MESA_GL_VERSION_OVERRIDE=3.2
export input_images="$input_images"
command="/opt/captk/squashfs-root/usr/bin/CaPTk -i $input_images &"
echo "$command"
runuser -p -l researcher -c "DISPLAY=:0 MESA_GL_VERSION_OVERRIDE=3.2 $command"
#sudo -E -u researcher "MESA_GL_VERSION_OVERRIDE=3.2 DISPLAY=:0 $command"
#$command

