ARG QT_VERSION=6.6.1

FROM ubuntu:jammy AS build
ARG QT_VERSION

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Qt 6.6.1 container volume for projects with VS code devcontainers"

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    tzdata locales ca-certificates \
    clang nodejs perl cmake ninja-build git && \
    apt-get install --no-install-recommends -y \
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

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /tmp
RUN git clone git://code.qt.io/qt/qt5.git qt6 && \
    cd qt6 && git checkout v$QT_VERSION && \
    perl init-repository

WORKDIR /tmp/qt6-build
RUN ../qt6/configure && \
    cmake --build . && \
    cmake --install . && \
    cd / && rm -rf /tmp/qt6*

FROM alpine:latest AS volume

ARG QT_VERSION
COPY --from=build /usr/local/Qt-$QT_VERSION /usr/local/Qt-$QT_VERSION
COPY qt/env.sh /env/qt.env
RUN sed -i "s:%QT_PATH%:/usr/local/Qt-$QT_VERSION:g" /env/qt.env
RUN sed -i "s:%QT_BIN_PATH%:/usr/local/Qt-$QT_VERSION/bin:g" /env/qt.env
