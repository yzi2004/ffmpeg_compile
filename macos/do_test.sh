#!/bin/bash

ARCH=arm64
TARGET_SDK=iphoneos
SDK_PATH=`xcrun --show-sdk-path --sdk iphoneos`
BASEDIR=/Volumes/dev/ffmpeg_compile/macos

. ./script/ios_common.sh

LIB_NAME="x264"

set_toolchain_clang_paths ${LIB_NAME}

