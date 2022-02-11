#!/bin/bash

# Exit and log if any command fails for debugging

# Disabled here right now for compatibility with Zenity exit codes
#set -e
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
#trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

# This script will fail if the user ID isn't the same as that passed in at container run-time.
# FOR RIGHT NOW this will succeed for any user so long as the token is active.
#/etc/scripts/validate-token-okta.py "$1"

#if [ "$?" = 0 ]; then
#  echo "Successfully validated the token."
#else
#  echo "Token validation failed. Halting."
#  exit 1
#fi

if ! [[ -s /home/researcher/currentUID ]]; then
  echo "404"
  exit 1
fi

#TODO: Make this progress bar smoother
(
echo "20"; sleep 60
echo "#Logging off automatically in 4 minutes..."; sleep 60
echo "40";
echo "#Logging off automatically in 3 minutes..."; sleep 60
echo "60";
echo "#Logging off automatically in 2 minutes..."; sleep 60
echo "80";
echo "#Logging off automatically in <1 minute..."; sleep 60
echo "100"
) |
DISPLAY=:0 zenity --progress \
  --title="Warning: Inactivity Timeout (press any button to cancel)" \
  --text="Logging off automatically in 5 minutes..." \
  --percentage=0 \
  --window-icon="warning" \
  --timeout=310 \
  --width=480

if [ "$?" = 5 ]; then
  bash /etc/scripts/end-user-session.sh
else
  :
  #DISPLAY=:0 zenity --message --title="Logoff canceled." --text="Automatic logoff canceled by user." --timeout=5
fi

echo "OK"
