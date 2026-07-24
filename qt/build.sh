#!/usr/bin/env bash

set -euo pipefail

build_jobs="${CMAKE_BUILD_PARALLEL_LEVEL:-4}"
command=(cmake --build . --parallel "$build_jobs")
max_attempts=3
attempt_num=1

until "${command[@]}"
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
