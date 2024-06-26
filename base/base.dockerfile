FROM ubuntu:noble

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Base container for the all derived devcontainers"
LABEL org.opencontainers.image.licenses="tbd"

ARG USERNAME=vscode
RUN useradd -s /bin/bash -m $USERNAME

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    tzdata locales ca-certificates \
    clang gdb cmake ninja-build python3 python3-pip \
    git ssh bash-completion gnupg2 curl sudo \
    mesa-common-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libclang-dev \
    llvm-18-dev \
    libglib2.0-0 \
    libgl1 \
    libegl1 \
    libfontconfig1 \
    libxkbcommon* \
    libxcursor-dev \
    libxshmfence-dev \
    libdbus-1-dev \
    libdbus-1-3 \
    libxcb*-dev \
    libxcb-cursor0 \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrender-dev \
    libxcb1-dev \
    libxcb-cursor-dev \
    libxcb-glx0-dev \
    libxcb-keysyms1-dev \
    libxcb-image0-dev \
    libxcb-shm0-dev \
    libxcb-icccm4-dev \
    libxcb-sync-dev \
    libxcb-xfixes0-dev \
    libxcb-shape0-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-util-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxkbfile-dev \
    libxcomposite-dev \
    libxcomposite1 \
    libxrandr-dev \
    libxrandr2 \
    libxtst-dev \
    libxtst6 \
    libwayland-* \
    libnvidia-egl-wayland-dev \
    mesa-vulkan-drivers \
    libvulkan1 \
    libvulkan-dev \
    libpcre2-dev \
    libnss3 \
    libjpeg-turbo8 \
    libwebp-dev \
    libtiff-dev && \
    rm -rf /var/lib/apt/lists/* && apt-get clean -y && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

COPY base/gtest.sh /tmp
RUN /tmp/gtest.sh

RUN pip install --break-system-packages cmake_format clang-format black mkdocs mkdocs-material

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

COPY base/.clang-format /
COPY base/.cmake-format.json /

RUN echo "\n\n# Configure environment variables for all attached volumes\n \
    for f in /opt/*.env; do if [ -f \$f ]; then source \$f; fi done\n" > /etc/profile

RUN usermod -a -G video $USERNAME

RUN echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir /code && chown ${USERNAME}:${USERNAME} /code

USER $USERNAME
