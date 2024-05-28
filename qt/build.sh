#!/usr/bin/env bash

sed -i '18i #include "ui/gl/gl_surface.h"' /tmp/qt6/qtwebengine/src/3rdparty/chromium/ui/gl/gl_context_glx.cc

command="cmake --build . --parallel"
max_attempts=3
attempt_num=1

until $command
do
  if [ $attempt_num -eq $max_attempts ]
  then
    echo "Attempt $attempt_num failed! No more retries left."
    exit 1
  else
    echo "Attempt $attempt_num failed! Retrying..."
    attempt_num=$((attempt_num+1))
    sleep 1
  fi
done

cmake --install .
