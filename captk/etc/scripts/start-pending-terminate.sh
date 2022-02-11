#!/bin/bash

time_to_wait="$SESSION_END_DELAYTIME"
touch /home/researcher/delaytimer
sleep "$time_to_wait"

/etc/scripts/end-user-session.sh
