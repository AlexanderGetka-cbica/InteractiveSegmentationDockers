#!/bin/bash
echo "entered ask-user-load-study.sh" >> /home/researcher/load-study.log 2>&1
DISPLAY=:0 zenity --question --width=480 --title="Confirm New Study Load" --text="CaPTk received a request to load a new study, but you have an existing open CaPTk session.\nIf you continue, the previous study instance will be closed and you will lose any unsaved progress. Are you sure you want to continue?\nPress Yes to continue loading (it may take a few seconds for the new study to be displayed)." 

case $? in
    0)
        echo "User selected to continue loading the new study." >> /home/researcher/load-study.log 2>&1
	# Now close existing CaPTk session
        echo "killing CaPTk-run-script from within ask-user-load-study.sh" >> /home/researcher/load-study.log 2>&1
        sudo pkill -9 -f "run-captk" >> /home/researcher/load-study.log 2>&1 # Kill the run-script to avoid session-kill on CaPTk close in this instance
	sudo pkill -9 -f "CaPTk" >> /home/researcher/load-study.log 2>&1 # Now kill the instance itself
        # Now open the new study -- simplest way just to run load-study again, which won't exit early with 429 this time
        /etc/scripts/load-study.sh "$@"
        ;;
    1)
        echo "User cancelled loading the new study." >> /home/researcher/load-study.log 2>&1
	;;
    -1)
        echo "An unexpected error has occurred or the user exited the prompt abnormally." >> /home/researcher/load-study.log 2>&1
        DISPLAY=:0 zenity --error --width=480 --title="Error" --text="An unexpected error occurred when confirming study load. Please submit a bug report."
	;;
esac
