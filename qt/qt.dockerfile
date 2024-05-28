ARG QT_VERSION=6.7.1

FROM ghcr.io/yevhenkuznetsov/devcontainers/base:1.6 AS build

ARG QT_VERSION

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Qt 6.7.1 container volume for projects with VS code devcontainers"
LABEL org.opencontainers.image.licenses="tbd."

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /tmp
RUN git clone --depth 1 --branch v$QT_VERSION git://code.qt.io/qt/qt5.git qt6
RUN cd qt6 && perl init-repository

RUN sudo apt-get update && \
    sudo apt-get install --no-install-recommends -y \
    gperf \
    flex \
    bison \
    libnss3-dev \
    libnss3 && \
    sudo rm -rf /var/lib/apt/lists/* && sudo apt-get clean -y

WORKDIR /tmp/qt6-build
# move to base
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    sudo apt-get update && \
    sudo apt-get install -y \
    nodejs \
    libcups2-dev \
    libglib2.0-dev \
    libssl-dev \
    libxi6 \
    libxi-dev \
    libxrandr2 \
    libxrandr-dev \
    libxss1 \
    libxss-dev \
    libxtst6 \
    libxtst-dev && \
    sudo pip3 install --break-system-packages html5lib

RUN ../qt6/configure -no-webengine-jumbo-build -openssl -release
COPY qt/build.sh /tmp/qt6-build
RUN sudo ./build.sh
RUN sudo cmake --install .

FROM alpine:latest

ARG QT_VERSION
COPY --from=build /usr/local/Qt-$QT_VERSION /opt/qt
COPY qt/env.sh /opt/qt.env
RUN sed -i "s:%QT_PATH%:/opt/qt:g" /opt/qt.env
RUN sed -i "s:%QT_BIN_PATH%:/opt/qt/bin:g" /opt/qt.env
