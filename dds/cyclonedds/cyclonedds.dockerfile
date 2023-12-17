ARG CYCLONEDDS_VERSION=0.10.4

FROM ubuntu:jammy AS build
ARG CYCLONEDDS_VERSION

LABEL org.opencontainers.image.source=https://github.com/yevhenkuznetsov/devcontainers
LABEL org.opencontainers.image.description="Cyclne DDS 0.10.4 container volume for projects with VS code devcontainers"
LABEL org.opencontainers.image.licenses="tbd."

ARG DEBIAN_FRONTEND="noninteractive"
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    tzdata locales ca-certificates \
    clang cmake ninja-build \
    libssl-dev bison \
    git && \
    rm -rf /var/lib/apt/lists/* && apt-get clean -y && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /tmp
RUN git clone --depth 1 --branch $CYCLONEDDS_VERSION https://github.com/eclipse-cyclonedds/cyclonedds.git && \
    cd cyclonedds && mkdir build && \
    cmake -S ./ -B build/ -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/opt/cyclonedds \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=OFF \
    -DBUILD_IDLC=YES \
    -DBUILD_DDSPERF=NO \
    -DBUILD_DOCS=OFF \
    -DENABLE_SSL=AUTO \
    -DENABLE_ICEORYX=AUTO \
    -DENABLE_SECURITY=YES \
    -DENABLE_LIFESPAN=YES \
    -DENABLE_DEADLINE_MISSED=YES \
    -DENABLE_TYPELIB=YES \
    -DENABLE_TYPE_DISCOVERY=YES \
    -DENABLE_TOPIC_DISCOVERY=YES \
    -DENABLE_SOURCE_SPECIFIC_MULTICAST=YES \
    -DENABLE_IPV6=YES \
    -DBUILD_IDLC_XTESTS=NO && \
    cmake --build build/ && cmake --install build/

RUN git clone --depth 1 --branch $CYCLONEDDS_VERSION https://github.com/eclipse-cyclonedds/cyclonedds-cxx.git && \
    cd cyclonedds-cxx && mkdir build && \
    cmake -S ./ -B build/ -G Ninja \
    -DCMAKE_INSTALL_PREFIX=/opt/cyclonedds-cxx \
    -DBUILD_IDLLIB=ON \ 
    -DBUILD_DDSPERF=NO \
    -DBUILD_DOCS=OFF \
    -DBUILD_TESTING=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DENABLE_LEGACY=NO \
    -DENABLE_SHM=NO \
    -DENABLE_TYPE_DISCOVERY=YES \
    -DENABLE_TOPIC_DISCOVERY=YES \
    -DENABLE_COVERAGE=NO && \
    cmake --build build/ && cmake --install build/

FROM alpine:latest

ARG QT_VERSION
COPY --from=build /opt/cyclonedds /cyclonedds-volume/opt/cyclonedds
COPY --from=build /opt/cyclonedds-cxx /cyclonedds-volume/opt/cyclonedds-cxx
COPY dds/cyclonedds/env.sh /cyclonedds-volume/opt/cyclonedds.env
RUN sed -i "s:%CYCLONEDDS_PATH%:/opt/cyclonedds:g" /cyclonedds-volume/opt/cyclonedds.env
RUN sed -i "s:%CYCLONEDDS_CXX_PATH%:/opt/cyclonedds-cxx:g" /cyclonedds-volume/opt/cyclonedds.env
RUN sed -i "s:%CYCLONEDDS_BIN_PATH%:/opt/cyclonedds/bin:g" /cyclonedds-volume/opt/cyclonedds.env
