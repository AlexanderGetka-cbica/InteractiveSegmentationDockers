#!/bin/bash

if ! [[ -s "/home/researcher/currentUID" ]]; then
  exit 0
fi

rm -f /home/researcher/currentUID >> /home/researcher/end-user-session.log 2>&1
rm -f /home/researcher/refresh >> /home/researcher/end-user-session.log 2>&1
rm -f /home/researcher/delaytimer >> /home/researcher/end-user-session.log 2>&1
# TEMP FOR DEBUG: use Zenity to display that the user is being logged off.
DISPLAY=:0 zenity --warning --title="Logging off" --text="User is being logged off." --timeout 1 &

# Also kill the VNC connection on force logoff
echo "killing x11vnc" >> /home/researcher/end-user-session.log 2>&1
sudo pkill -9 -f "x11vnc" >> /home/researcher/end-user-session.log 2>&1

# now notify DART
# TBD with /etc/scripts/notify-dart-logoff.py (should notify DART with container identifier (found via hostname) and current user's UID)
echo "exiting xautolock" >> /home/researcher/end-user-session.log 2>&1
sudo DISPLAY=:0 xautolock -exit >> /home/researcher/end-user-session.log 2>&1

# force-kill all active captk sessions LAST (avoid weirdness where it finds CaPTk and stops this process)
# capitalization matters
echo "killing CaPTk" >> /home/researcher/end-user-session.log 2>&1
sudo pkill -9 -f "CaPTk" >> /home/researcher/end-user-session.log 2>&1
# Kill run-script to avoid session leakage
sudo pkill -9 -f "run-captk" >> /home/researcher/end-user-session.log 2>&1

# Kill any zenity windows that might allow session leak
sudo pkill -9 -f "zenity" >> /home/researcher/end-user-session.log 2>&1 # Finally, kill any popups that might allow session-load...

