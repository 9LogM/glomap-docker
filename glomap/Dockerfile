FROM nvcr.io/nvidia/pytorch:24.01-py3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    lsb-release \
    libeigen3-dev \
    libsuitesparse-dev \
    libmetis-dev \
    libboost-all-dev \
    libsqlite3-dev \
    libgl1-mesa-dev \
    libcgal-dev \
    libglew-dev \
    libfreeimage-dev \
    && rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/opt/hpcx/ucx/lib:/opt/hpcx/ucc/lib:/usr/lib/x86_64-linux-gnu/libcudss/12/:${LD_LIBRARY_PATH}
ENV LD_PRELOAD=/opt/hpcx/ucx/lib/libucs.so.0:/opt/hpcx/ucx/lib/libucm.so.0

# Intel RealSense utils (for .bag file conversion)
RUN mkdir -p /etc/apt/keyrings \
    && curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null
RUN echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | \
    tee /etc/apt/sources.list.d/librealsense.list
RUN apt-get update && apt-get install -y --no-install-recommends librealsense2-utils && rm -rf /var/lib/apt/lists/*

# cuDSS
RUN wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i cuda-keyring_1.1-1_all.deb \
    && rm -f cuda-keyring_1.1-1_all.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libcudss0-cuda-12 libcudss0-dev-cuda-12 libcudss0-static-cuda-12 \
    && rm -rf /var/lib/apt/lists/*

# Ceres
RUN git clone --recursive https://ceres-solver.googlesource.com/ceres-solver /opt/ceres-solver && \
    cd /opt/ceres-solver && mkdir build && cd build && \
    cmake .. -GNinja \
        -Dcudss_DIR=/usr/lib/x86_64-linux-gnu/libcudss/12/cmake/cudss \
        -Dcudss_INCLUDE_DIR=/usr/include/libcudss/12 \
    && ninja && ninja install && \
    cd / && \
    rm -rf /opt/ceres-solver && \
    rm -rf /var/lib/apt/lists/*

# COLMAP
WORKDIR /app
RUN git clone --depth 1 https://github.com/colmap/colmap.git && \
    mkdir -p colmap/build && cd colmap/build && \
    cmake .. -GNinja \
        -DGUI_ENABLED=OFF \
        -DCUDA_ENABLED=ON \
        -Dcudss_DIR=/usr/lib/x86_64-linux-gnu/libcudss/12/cmake/cudss \
        -Dcudss_INCLUDE_DIR=/usr/include/libcudss/12 && \
    ninja install && \
    cd /app && rm -rf colmap

# GLOMAP
RUN git clone https://github.com/colmap/glomap.git /glomap \
    && cd /glomap \
    && mkdir build && cd build \
    && cmake .. -GNinja \
        -Dcudss_DIR=/usr/lib/x86_64-linux-gnu/libcudss/12/cmake/cudss \
        -Dcudss_INCLUDE_DIR=/usr/include/libcudss/12 \
    && ninja \
    && ninja install \
    && cd / && rm -rf /glomap

WORKDIR /glomap

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/glomap/entrypoint.sh"]

# Keep container running
# CMD [ "tail", "-f", "/dev/null" ]

# Debug
# docker compose up --build glomap --remove-orphans 2>&1 | tee compose_log.txt