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
    git bash-completion gnupg2 && \
    rm -rf /var/lib/apt/lists/* && apt-get clean -y && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

RUN pip install cmake_format clang-format

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

COPY base/.clang-format /
COPY base/.cmake-format.json /

USER $USERNAME
