#!/bin/bash
# $1 is the userID passed by the API call
# Note that this part is not authenticated. TODO: Check if we have some way of double-checking that this is DART requesting this.

if ! [[ -s "/home/researcher/currentUID" ]]; then
  echo "No current user detected. Logging in user $1." >> /home/researcher/change-active-user.log
  # clean up a state where no user is in (session cleared) but a CaPTk session lingers (double-guard)
  sudo pkill -9 -f "run-captk" >> /home/researcher/load-study.log 2>&1 # Kill the run-script to avoid full session-kill on CaPTk close in this instance
  sudo pkill -9 -f "CaPTk" >> /home/researcher/load-study.log 2>&1 # Now kill the instance itself
  sudo pkill -9 -f "zenity" >> /home/researcher/load-study.log 2>&1 # Finally, kill any popups that might allow session-load...
  touch /home/researcher/currentUID
  echo "$1" > /home/researcher/currentUID
  exit 0
fi

existing_UID=$(cat /home/researcher/currentUID | tr -d '\n')
if [[ "$existing_UID" == "$1" ]]; then
  echo "User with UID $1 is already logged in. Continuing." >> /home/researcher/change-active-user.log
  exit 0
else
  echo "A different user is currently logged in. Their session must be terminated first." >> /home/researcher/change-active-user.log
  exit 1
  # Terminate existing user session -- we can disable this and instead exit with error if we want to force explicit termination by DART
  #echo "Logging off user $existing_UID, logging on user $1."
  #/etc/scripts/force-logoff.sh
  # Now do anything needed to log on a new user
fi


