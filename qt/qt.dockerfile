ARG QT_VERSION=6.11.1
ARG QT_MODULES=qtbase,qtdeclarative,qttools,qttranslations,qtsvg,qtgraphs,qtlocation,qtpositioning,qtspeech,qtmultimedia,qtserialport,qtimageformats,qtshadertools,qtconnectivity,qtquick3d,qtsensors,qtscxml,qtwebsockets,qthttpserver,qtwebchannel,qtwebengine
ARG QT_BUILD_JOBS=4

FROM ghcr.io/yevhenkuznetsov/devcontainers/base:1.8 AS build

ARG QT_VERSION
ARG QT_MODULES
ARG QT_BUILD_JOBS

# Qt WebEngine starts a recursive Ninja build for Chromium. CMake's outer
# --parallel value does not constrain that build, so limit both levels.
ENV CMAKE_BUILD_PARALLEL_LEVEL=$QT_BUILD_JOBS
ENV NINJAFLAGS=-j$QT_BUILD_JOBS

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Qt $QT_VERSION container volume for projects with VS code devcontainers"
LABEL org.opencontainers.image.licenses="tbd."

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

WORKDIR /tmp
RUN git clone --depth 1 --branch v$QT_VERSION git://code.qt.io/qt/qt5.git qt6
RUN cd qt6 && perl init-repository --module-subset=$QT_MODULES

RUN sudo apt-get update && \
    sudo apt-get install --no-install-recommends -y \
    gperf \
    flex \
    bison \
    pkg-config \
    libdrm-dev \
    libxdamage-dev \
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
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && \
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

RUN ../qt6/configure -openssl -release -nomake examples -nomake tests \
    -webengine-proprietary-codecs \
    -webengine-webrtc \
    -submodules $QT_MODULES \
    -- \
    -DFEATURE_qtwebengine_build=ON
COPY qt/build.sh /tmp/qt6-build
RUN ./build.sh
RUN sudo cmake --install .
RUN bash -lc 'set -euo pipefail; \
required_modules="Concurrent Core Graphs Gui HttpServer LinguistTools Location Multimedia Network OpenGL Positioning Qml QmlIntegration Quick Quick3D QuickControls2 QuickVectorImage QuickWidgets Sensors SerialPort ShaderTools Sql StateMachine Svg TextToSpeech WebChannel WebEngineCore WebEngineQuick WebSockets Xml"; \
qt_cmake_root="/usr/local/Qt-${QT_VERSION}/lib/cmake"; \
missing_required=""; \
for m in $required_modules; do \
  if [ ! -f "${qt_cmake_root}/Qt6${m}/Qt6${m}Config.cmake" ]; then \
    missing_required="${missing_required} ${m}"; \
  fi; \
done; \
if [ -n "${missing_required}" ]; then \
  echo "Missing required Qt6 modules:${missing_required}"; \
  exit 1; \
fi'

FROM alpine:latest

ARG QT_VERSION
COPY --from=build /usr/local/Qt-$QT_VERSION /opt/qt
COPY qt/env.sh /opt/qt.env
RUN sed -i "s:%QT_PATH%:/opt/qt:g" /opt/qt.env
RUN sed -i "s:%QT_BIN_PATH%:/opt/qt/bin:g" /opt/qt.env
