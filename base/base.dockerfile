FROM ubuntu:jammy

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Base container for the all derived devcontainers"

ARG USERNAME=vscode
RUN useradd -s /bin/bash -m $USERNAME

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    tzdata locales ca-certificates \
    clang gdb cmake ninja-build python3 python3-pip \
    git ssh bash-completion gnupg2 \
    mesa-common-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libclang-dev \
    llvm-14-dev \
    libglib2.0-0 \
    libgl1 \
    libegl1 \
    libfontconfig1 \
    libxkbcommon* \
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
    libxkbcommon-x11-dev && \
    rm -rf /var/lib/apt/lists/* && apt-get clean -y && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

RUN pip install cmake_format clang-format

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

COPY base/.clang-format /
COPY base/.cmake-format.json /

RUN echo "\n\n# Configure environment variables for all attached volumes\n \
    for f in \"/env/*.env\"; do\n \
    \tif [ -f \$f ]; then\n \
    \t\tsource \$f\n \
    \tfi\n \
    done\n" > /etc/profile

USER $USERNAME
