#!/bin/bash

# Print tool, study ID, and launch captk with that

# Do any pre-processing that is done per-study at load-time here.
# e.g. load-time DICOM-to-NIFTI could be done here.

# For right now: just parse over the corresponding study dir for any files.

# Exit and log if any command fails for debugging
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

# This script will fail if the user ID isn't the same as that passed in at container run-time.
/etc/scripts/validate-token-okta.py "$1"

echo "Opening study $2 with tool: $3 ."
search_dir="/home/researcher/shared-mount/studies/$2"
input_arg=""
for entry in "$search_dir"/*
do
  if [[ -f $entry ]]; then
    input_images+=",$entry"
  fi
done


# Pass to captk.
export MESA_GL_VERSION_OVERRIDE=3.2

command="/opt/captk/squashfs-root/usr/bin/CaPTk -i $input_images &"
echo "$command"
$command


