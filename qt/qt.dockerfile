ARG QT_VERSION=6.6.1

FROM ubuntu:jammy AS build
ARG QT_VERSION

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Qt 6.6.1 container volume for projects with VS code devcontainers"
LABEL org.opencontainers.image.licenses="tbd."

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    tzdata locales ca-certificates \
    clang perl cmake ninja-build python3 python3-pip \
    git curl && \
    rm -rf /var/lib/apt/lists/* && apt-get clean -y && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /tmp
RUN git clone --depth 1 --branch v$QT_VERSION git://code.qt.io/qt/qt5.git qt6
RUN cd qt6 && perl init-repository

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    gperf \
    flex \
    bison \
    libnss3-dev \
    libnss3 \
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
    libvulkan-dev

WORKDIR /tmp/qt6-build
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt -y install nodejs && \
    pip3 install html5lib

RUN ../qt6/configure -skip qtwebengine && \
    cmake --build . && \
    cmake --install .
RUN cd / && rm -rf /tmp/qt6*

FROM alpine:latest

ARG QT_VERSION
COPY --from=build /usr/local/Qt-$QT_VERSION /qt-volume/opt/qt
COPY qt/env.sh /qt-volume/opt/qt.env
RUN sed -i "s:%QT_PATH%:/opt/qt:g" /qt-volume/opt/qt.env
RUN sed -i "s:%QT_BIN_PATH%:/opt/qt/bin:g" /qt-volume/opt/qt.env
