#!/usr/bin/env sh

SOURCE_FOLDER=/tmp/googletest
BUILD_FOLDER=$SOURCE_FOLDER/build

cd /tmp
git clone --depth 1 https://github.com/google/googletest.git
mkdir $BUILD_FOLDER
cmake -S $SOURCE_FOLDER -B $BUILD_FOLDER -G Ninja -DINSTALL_GTEST=ON || exit 1
cmake --build $BUILD_FOLDER || exit 1
cmake --install $BUILD_FOLDER || exit 1
rm -rf $SOURCE_FOLDER

exit 0
