#!/bin/bash


echo "killing pending termination due to quick reconnect!" >> /home/researcher/end-user-session.log 2>&1
#Hack to make sure we only kill the spun-up start-pending-terminate instead of the whole x11vnc process chain
sudo pkill -9 -f "/bin/bash /etc/scripts/start-pending-terminate.sh" >> /home/researcher/end-user-session.log 2>&1
echo "removing delaytimer file" >> /home/researcher/end-user-session.log 2>&1
rm -f /home/researcher/delaytimer >> /home/researcher/end-user-session.log 2>&1
