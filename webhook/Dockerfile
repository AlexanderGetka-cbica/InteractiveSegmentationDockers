# Webhook base Docker platform image
# All this does is install the Webhook software (see https://github.com/adnanh/webhook for details)
# In order to actually use this, you will need to set up the auto-run script for to start the webhook listener and provide the right webhook files.
# Auto-run script is found under "home/researcher" in the app directories. Look for .xinitrc
# the auto-run script is copied in at build-time
# Webhook files can be brought in at build-time with the same mechanism

# Could work to mount in webhook files at run-time. Just need the auto-run script to point to the mounted location.

ARG VERSION="0821"

FROM alexandergetka/x11:0821
MAINTAINER Alexander.Getka@pennmedicine.upenn.edu
 

RUN sudo apt-get install webhook

# Slicer 4.5: http://download.
# Note that slicer is started automatically at login from /home/researcher/.xinitrc 
# (Previously /etc/skel/.xinitrc) 
# it will run whatever is in the user's home directory .slicerrc.py, so any
# users of this docker image have the option of putting arbitrary startup commands in that file.
#
# Note also you can set the SLICER_ARGUMENTS environment variable using the -e "SLICER_ARGUMENTS=<value>"
# on the docker run command line.
