# ---- Build stage ----
FROM jlesage/baseimage-gui:ubuntu-22.04-v4.9.0 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_NO_CACHE_DIR=1

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip \
    libegl1 libopengl0 libgl1-mesa-glx libglib2.0-0 libgomp1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Install Python dependencies
RUN pip3 install \
    numpy==1.24.4 \
    scipy==1.10.1 \
    matplotlib \
    opencv-python-headless \
    tifffile \
    scikit-image \
    torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 \
        --extra-index-url https://download.pytorch.org/whl/cu118 \
    pyqt6==6.6.1 pyqt6-qt6==6.6.1 \
    cellpose[gui]==3.1.1.2 \
    safetensors

# Pre-download Cellpose models
COPY download_cellpose_models.py /build/
RUN python3 download_cellpose_models.py


# ---- Runtime stage ----
FROM jlesage/baseimage-gui:ubuntu-22.04-v4.9.0

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin
ENV QT_XCB_NO_MITSHM=1
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en NUMBA_CACHE_DIR=/tmp
ENV APP_NAME="Cellpose" KEEP_APP_RUNNING=0 TAKE_CONFIG_OWNERSHIP=1 HOME=/config
ENV QT_QPA_PLATFORM=xcb
ENV QT_X11_NO_MITSHM=1

USER root

# Install runtime dependencies - comprehensive GUI libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip \
    libegl1 libopengl0 libgl1-mesa-glx libgl1-mesa-dri \
    libglib2.0-0 libgomp1 \
    libfontconfig1 libfreetype6 libxrender1 libxext6 libx11-6 \
    libxcb-xinerama0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 \
    libxcb-randr0 libxcb-render-util0 libxcb-shape0 libxcb-xfixes0 \
    libxcb-cursor0 libxcb-util1 \
    libxkbcommon-x11-0 libxkbcommon0 \
    libdbus-1-3 libxcb1 libxcb-glx0 libxcb-xkb1 \
    fonts-liberation fonts-dejavu-core \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

# Copy Python packages & Cellpose models
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /root/.cellpose /root/.cellpose

# App startup script
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh && \
    mkdir -p ./home/cp_working_dir

# GUI config template
COPY rc.xml.template /opt/base/etc/openbox/rc.xml.template

WORKDIR /config
EXPOSE 5800
