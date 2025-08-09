FROM jlesage/baseimage-gui:ubuntu-22.04-v4.9.0 AS build

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Europe/Berlin
ENV QT_XCB_NO_MITSHM 1 
ENV NVIDIA_VISIBLE_DEVICES "all",
ENV NVIDIA_DRIVER_CAPABILITIES "compute,utility"
ENV LANG en_US.UTF-8 \
    LC_ALL en_US.UTF-8 \
    LANGUAGE en_US:en  \
    NUMBA_CACHE_DIR /tmp

USER root

RUN apt-get update -y && \
    apt-get install -qqy build-essential \
            gcc \
            wget \
            qtcreator \
            python3-dev \
            python3-pip \
            python3-wheel \
            libblas-dev \
            liblapack-dev \
            libgl1 \
            mesa-utils \
            libgl1-mesa-glx \
            libxcb-xinerama0 \
            libatlas-base-dev \
            gfortran \
            apt-utils \
            bzip2 \
            ca-certificates \
            curl \
            libxcb-cursor0 \
            locales \
            libarchive-dev \
            cmake \
            libxcb-cursor0 \
            python3-minimal \
            unzip &&  \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

WORKDIR /tmp

RUN python3 -m pip install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 --extra-index-url https://download.pytorch.org/whl/cu118 && \
    python3 -m pip install pyqt6==6.6.1 pyqt6-qt6==6.6.1 cellpose[gui]==3.1.1.2 safetensors

COPY download_cellpose_models.py /
RUN python3 /download_cellpose_models.py

EXPOSE 5800

COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

ENV APP_NAME="Cellpose"

ENV KEEP_APP_RUNNING=0
ENV TAKE_CONFIG_OWNERSHIP=1
ENV HOME=/config

COPY rc.xml.template /opt/base/etc/openbox/rc.xml.template

WORKDIR /config

