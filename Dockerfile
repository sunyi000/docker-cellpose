FROM jlesage/baseimage-gui:ubuntu-22.04-v4.5.2 AS build

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Europe/Berlin
ENV QT_XCB_NO_MITSHM 1 
ENV NVIDIA_VISIBLE_DEVICES "all",
ENV NVIDIA_DRIVER_CAPABILITIES "compute,utility"
ENV LANG en_US.UTF-8 \
    LC_ALL en_US.UTF-8 \
    LANGUAGE en_US:en  \
    NUMBA_CACHE_DIR /tmp
#ENV HOME /config

RUN apt-get update -y && apt-get install -qqy build-essential 

RUN apt-get install -y -q --no-install-recommends \
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
            locales \
            libarchive-dev \
            cmake \
            libxcb-cursor0 \
            unzip &&  apt-get clean


RUN rm -rf /var/lib/apt/lists/* 

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

WORKDIR /tmp
RUN wget https://github.com/conda-forge/miniforge/releases/download/24.7.1-0/Miniforge3-24.7.1-0-Linux-x86_64.sh\
    && bash Miniforge3-24.7.1-0-Linux-x86_64.sh -b -p /opt/conda \
    && rm -f Miniforge3-24.7.1-0-Linux-x86_64.sh 

ENV CONDA_BIN_PATH="/opt/conda/bin"
ENV PATH $CONDA_BIN_PATH:$PATH
ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"
ENV LD_LIBRARY_PATH "/usr/local/nvidia/lib:/usr/local/nvidia/lib64"

RUN conda install mamba -n base -c conda-forge 

RUN mamba create --name cellpose --yes python=3.9 pytorch==1.12.0 torchvision==0.13.0 torchaudio==0.12.0 cudatoolkit=11.3 mkl==2024.0 -c pytorch -c conda-forge -c bioconda
RUN /opt/conda/envs/cellpose/bin/pip install cellpose[gui]

COPY download_cellpose_models.py /
RUN /opt/conda/envs/cellpose/bin/python /download_cellpose_models.py

EXPOSE 5800

COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

ENV APP_NAME="Cellpose"

ENV KEEP_APP_RUNNING=0

ENV TAKE_CONFIG_OWNERSHIP=1

WORKDIR /config

