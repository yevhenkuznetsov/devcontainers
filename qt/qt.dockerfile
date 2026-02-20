ARG QT_VERSION=6.10.1
ARG QT_MODULES=qtbase,qt5compat,qtshadertools,qtdeclarative,qttools,qttranslations,qtcharts,qtconnectivity,qtmultimedia,qtpositioning,qtlocation,qtsensors,qtsvg,qtspeech,qtserialport,qtquick3d

FROM ghcr.io/yevhenkuznetsov/devcontainers/base:1.8 AS build

ARG QT_VERSION
ARG QT_MODULES

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Qt $QT_VERSION container volume for projects with VS code devcontainers"
LABEL org.opencontainers.image.licenses="tbd."

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /tmp
RUN git clone --depth 1 --branch v$QT_VERSION git://code.qt.io/qt/qt5.git qt6
RUN cd qt6 && perl init-repository --module-subset=$QT_MODULES

RUN sudo apt-get update && \
    sudo apt-get install --no-install-recommends -y \
    gperf \
    flex \
    bison \
    libnss3-dev \
    libnss3 \
    libbluetooth-dev \
    bluez \
    libspeechd-dev \
    speech-dispatcher \
    libasound2-dev \
    libpulse-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev && \
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
    sudo pip3 install html5lib

RUN ../qt6/configure -openssl -release -nomake examples -nomake tests -submodules $QT_MODULES
COPY qt/build.sh /tmp/qt6-build
RUN sudo ./build.sh
RUN sudo cmake --install .
RUN bash -lc 'set -euo pipefail; \
required_modules="Charts Concurrent Core Core5Compat Gui LinguistTools Location Multimedia Network OpenGL Positioning Qml QmlIntegration Quick QuickControls2 QuickWidgets Sensors Sql Svg TextToSpeech Widgets Xml"; \
optional_modules="Bluetooth MultimediaQuickPrivate Quick3D SerialPort Test"; \
qt_cmake_root="/usr/local/Qt-${QT_VERSION}/lib/cmake"; \
missing_required=""; \
missing_optional=""; \
for m in $required_modules; do \
  if [ ! -f "${qt_cmake_root}/Qt6${m}/Qt6${m}Config.cmake" ]; then \
    missing_required="${missing_required} ${m}"; \
  fi; \
done; \
for m in $optional_modules; do \
  if [ ! -f "${qt_cmake_root}/Qt6${m}/Qt6${m}Config.cmake" ]; then \
    missing_optional="${missing_optional} ${m}"; \
  fi; \
done; \
if [ -n "${missing_required}" ]; then \
  echo "Missing required Qt6 modules:${missing_required}"; \
  exit 1; \
fi; \
if [ -n "${missing_optional}" ]; then \
  echo "Missing optional Qt6 modules:${missing_optional}"; \
fi'

FROM alpine:latest

ARG QT_VERSION
COPY --from=build /usr/local/Qt-$QT_VERSION /opt/qt
COPY qt/env.sh /opt/qt.env
RUN sed -i "s:%QT_PATH%:/opt/qt:g" /opt/qt.env
RUN sed -i "s:%QT_BIN_PATH%:/opt/qt/bin:g" /opt/qt.env
