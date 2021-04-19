# SlicerDocker platform image
# (based on https://github.com/dit4c/dockerfile-dit4c-container-slicer)

ARG VERSION="4.11.20200930"


FROM alexandergetka/x11:${VERSION}
MAINTAINER pieper@isomics.com
 

RUN sudo apt-get update
RUN apt-get install -y libglu1-mesa libgomp1
RUN apt-get install -y libpulse-dev libnss3 libglu1-mesa
RUN apt-get install -y --reinstall libxcb-xinerama0
RUN apt-get install -y libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-xkb1 libxkbcommon-x11-0

# Slicer 4.5: http://download.slicer.org/bitstream/461634
# Slicer 4.8.1 http://download.slicer.org/bitstream/738960
# Slicer 4.10.1 http://download.slicer.org/bitstream/944596
# Slicer 4.10.2 http://download.slicer.org/bitstream/1023242

# Slicer 4.11.20200930
#RUN SLICER_URL="http://download.slicer.org/bitstream/1341035" && \
#  curl -v -s -L $SLICER_URL | tar xz -C /tmp && \
#  mv /tmp/Slicer* /opt/slicer

ENV CAPTK_VERSION=1.8.1

RUN CAPTK_URL="https://captk.projects.nitrc.org/CaPTk_${CAPTK_VERSION}_Installer.bin" && \
   mkdir /opt/captk/ && \
   cd /opt/captk/ && \
   wget $CAPTK_URL && \
   chmod +x CaPTk_${CAPTK_VERSION}_Installer.bin && \
   echo "Y" | ./CaPTk_${CAPTK_VERSION}_Installer.bin && \
   ./CaPTk/${CAPTK_VERSION}/captk --appimage-extract && \
   rm -f ./CaPTk_${CAPTK_VERSION}_Installer.bin && \
   rm -rf ./CaPTk

# copy /opt after extraction
COPY /etc /etc
COPY /opt /opt
COPY /usr /usr
COPY captk.desktop /opt/captk/captk.desktop
COPY icon.png /opt/captk/icon.png
COPY wallpaper.png /usr/local/shared/backgrounds/wallpaper.png

RUN chmod -R a+rx /opt/captk/

# See http://na-mic.org/Mantis/view.php?id=4015
RUN su researcher -c "mkdir /home/researcher/Documents"
COPY /home/researcher/Documents /home/researcher/Documents
RUN chown -R researcher:researcher /home/researcher/Documents

# Necessary to get wallpapers and auto-run working
COPY /home/researcher/.config /home/researcher/.config
RUN chown -R researcher:researcher /home/researcher/.config
COPY /home/researcher/.xinitrc /home/researcher/.xinitrc
RUN chown -R researcher:researcher /home/researcher/.xinitrc

RUN mkdir /home/researcher/shared-mount && \
    mkdir /home/researcher/session-output && \
    chmod -R a+rwx /home/researcher/session-output

RUN LNUM=$(sed -n '/launcher_item_app/=' /etc/tint2/panel.tint2rc | head -1) && \
  sed -i "${LNUM}ilauncher_item_app = /opt/captk/captk.desktop" /etc/tint2/panel.tint2rc

# Note that slicer is started automatically at login from /home/researcher/.xinitrc 
# (Previously /etc/skel/.xinitrc) 
# it will run whatever is in the user's home directory .slicerrc.py, so any
# users of this docker image have the option of putting arbitrary startup commands in that file.
#
# Note also you can set the SLICER_ARGUMENTS environment variable using the -e "SLICER_ARGUMENTS=<value>"
# on the docker run command line.
