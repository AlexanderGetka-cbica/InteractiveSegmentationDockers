# SlicerDocker platform image
# (based on https://github.com/dit4c/dockerfile-dit4c-container-slicer)

ARG VERSION="0721"


FROM alexandergetka/x11:${VERSION}
# we don't need webhook since InciSe can use MITK's REST API module
MAINTAINER pieper@isomics.com

#RUN sudo apt-get install -y build-essential gawk bison

#RUN gcc --version
#RUN mkdir ~/glibc_install; cd ~/glibc_install && \
#   wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/glibc/2.27-3ubuntu1.2/glibc_2.27.orig.tar.xz && \
#   tar xvf glibc_2.27.orig.tar.xz && \
#   cd glibc-2.27 && \
#   mkdir build && \
#   cd build && \
#   ../configure --prefix=/opt/glibc-2.27-3ubuntu1.2 && \
#   make -j1 && \
#   sudo make install && \
#   ln -sf /etc/localtime /opt/glibc-2.27-3ubuntu1.2/etc/localtime
#RUN touch /etc/profile.d/new_glibc.sh && \
#   echo 'export LD_PRELOAD=' >> /etc/profile.d/new_glibc.sh
# FIX ABOVE 

RUN apt-get --fix-missing update
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

RUN INCISE_URL="https://github.com/AlexanderGetka-cbica/InciSe/releases/download/v0.1linux/InciSe-linux-x86_64.tar.gz" && \
   curl -v -s -L $INCISE_URL | tar xz -C /tmp && \
   mv /tmp/MITK-experiments/sDMAS-2018.07-3194-gc0f884b289-linux-x86_64/ /opt/InciSe


# copy /opt after extraction slicer (/opt/slicer is extracted tar)
COPY /etc /etc
COPY /opt /opt
COPY /usr /usr
COPY InciSe.desktop /opt/InciSe/InciSe.desktop
COPY icon.png /opt/InciSe/icon.png

RUN chmod -R a+w /opt/InciSe

# See http://na-mic.org/Mantis/view.php?id=4015
RUN su researcher -c "mkdir /home/researcher/Documents"
COPY /home/researcher/Documents /home/researcher/Documents
RUN chown -R researcher:researcher /home/researcher/Documents

COPY /home/researcher/.config /home/researcher/.config
RUN chown -R researcher:researcher /home/researcher/.config

COPY /home/researcher/.xinitrc /home/researcher/.xinitrc
RUN chown -R researcher:researcher /home/researcher/.xinitrc

RUN mkdir /home/researcher/session-output && \
    mkdir /home/researcher/shared-mount

RUN chmod -R a+rwx /home/researcher/session-output

RUN LNUM=$(sed -n '/launcher_item_app/=' /etc/tint2/panel.tint2rc | head -1) && \
  sed -i "${LNUM}ilauncher_item_app = /opt/InciSe/InciSe.desktop" /etc/tint2/panel.tint2rc

# Note that slicer is started automatically at login from /etc/skel/.xinitrc
# it will run whatever is in the user's home directory .slicerrc.py, so any
# users of this docker image have the option of putting arbitrary startup commands in that file.
#
# Note also you can set the SLICER_ARGUMENTS environment variable using the -e "SLICER_ARGUMENTS=<value>"
# on the docker run command line.
