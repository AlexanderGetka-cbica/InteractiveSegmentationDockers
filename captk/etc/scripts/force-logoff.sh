#!/bin/bash

# Exit and log if any command fails for debugging
#set -e
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
#trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

# This script will fail if the user ID isn't the same as that passed in at container run-time.
# FOR RIGHT NOW this will succeed for any user so long as the token is active.
#/etc/scripts/validate-token-okta.py "$1"
# We don't need to authenticate this right now. Re-enable this if the API port becomes open to the internet,
# or if we have a mechanism to confirm DART is performing the action.

userIdentifier=`/etc/scripts/get-uid-from-token.py $1 2>/dev/null | tr -d '\n'`

if ! [[ -s /home/researcher/currentUID ]]; then
  echo "404" # No user has been logged in, so why terminate
  exit 1
else # a current user exists at all
  loggedInUser=`cat /home/researcher/currentUID | tr -d '\n'`
  if [ "$userIdentifier" = "$loggedInUser" ]; then
    /etc/scripts/end-user-session.sh # Logoff initiated for current user
  else
    echo "401" # Logoff initiated for a different userID
    exit 1
  fi
fi

echo "200"
