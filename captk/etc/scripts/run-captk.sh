#!/bin/bash
# Forward all params passed to this to CaPTk

# First, double check CaPTk process count
number_captk_processes=`pgrep -c CaPTk`
if [ "$?" = 0 ]; then
  # check if too many are open
  echo "Pgrep found some existing CaPTk processes" >> /home/researcher/load-study.log
  # Check if captk instance already exists at this point (happens if load-study is called again in-between CaPTk close + new CaPTk open)
  if (( number_captk_processes > 0 )); then
    zenity --warning --width=480 --title="CaPTk Instance Limit Reached" --text="Multiple near-simultaneous CaPTk load events were detected. As a result, the study may have loaded incompletely. To ensure integrity of input data, you should close the session and load the study again. In the future, please wait for one study to load completely first before loading another.\n\n If you believe you have received this message in error, please submit a bug report."
    exit 1
  fi
else
 # can continue normally
 echo "Pgrep failed to find existing CaPTk processes" >> /home/researcher/load-study.log
fi

DISPLAY=:0 MESA_GL_VERSION_OVERRIDE=3.2 /opt/captk/squashfs-root/usr/bin/CaPTk "$@" >/home/researcher/captk.log 2>/home/researcher/captk-err.log
# When CaPTk closes, end the user session fully.
/etc/scripts/end-user-session.sh

