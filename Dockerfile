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
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda \
    && rm -f Miniconda3-latest-Linux-x86_64.sh

ENV CONDA_BIN_PATH="/opt/conda/bin"
ENV PATH $CONDA_BIN_PATH:$PATH
#ENV LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"
ENV LD_LIBRARY_PATH "/usr/local/nvidia/lib:/usr/local/nvidia/lib64"

RUN conda config --set channel_priority flexible && \
    echo "yes" | conda tos accept --channel https://repo.anaconda.com/pkgs/main && \
    echo "yes" | conda tos accept --channel https://repo.anaconda.com/pkgs/r

RUN conda install mamba -n base -c conda-forge

RUN mamba create --name cellpose --yes python=3.8 pytorch-gpu cudatoolkit=11.2 packaging safetensors -c conda-forge
RUN /opt/conda/envs/cellpose/bin/pip install cellpose[gui]

EXPOSE 5800

COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

ENV APP_NAME="Cellpose"

ENV KEEP_APP_RUNNING=0

ENV TAKE_CONFIG_OWNERSHIP=1

WORKDIR /config

