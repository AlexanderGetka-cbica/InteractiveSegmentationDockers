# DOCKER-VERSION 1.0
# x11 image for other SlicerDocker platform images
# (based on https://github.com/dit4c/dockerfile-dit4c-container-x11 debian branch)

ARG VERSION="0721"

FROM alexandergetka/base:${VERSION}
MAINTAINER pieper@isomics.com

# Install
# - MESA DRI drivers for software GLX rendering
# - X11 dummy & void drivers
# - RandR utility
# - X11 xinit binary
# - reasonable fonts for UI
# - x11vnc
# - python-websockify
# - openbox
# - tint2
# - xterm
# - lxrandr
# - nitrogen
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libgl1-mesa-dri \
    xserver-xorg-video-dummy \
    xserver-xorg-input-void \
    x11-xserver-utils \
    xinit \
    fonts-dejavu \
    x11vnc \
    websockify \
    openbox \
    tint2 \
    xterm \
    lxrandr \
    nitrogen \
    libpulse-dev \
    libnss3 \
    libasound2 \
    && \
  rm -f /usr/share/applications/x11vnc.desktop && \
  apt-get clean


# Get noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
  rm -rf /opt/noVNC/.git

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY usr /usr
COPY var /var

RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

# Check nginx config is OK
RUN nginx -t

# Install our custom Okta user verification plugin for websockify
RUN mkdir /etc/scripts && \
    sudo apt-get install python3 && \
    curl https://bootstrap.pypa.io/get-pip.py -o /etc/scripts/get-pip.py && \
    python3 --version && \
    python3 /etc/scripts/get-pip.py && \
    cd /etc/pymodule/websockify-okta-1.0.0 && \
    python3 setup.py install
