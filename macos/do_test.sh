#!/bin/bash

export ARCH=arm64
export BASEDIR=/Volumes/dev/ffmpeg_compile
export TARGET=iphoneos
export TOOLS="${BASEDIR}/tools"
export SOURCE="${BASEDIR}/sources"
export BUILD="${BASEDIR}/build/${TARGET}"
export SDK_PATH=`xcrun --show-sdk-path --sdk ${TARGET}`


. ./script/ios_common.sh

LIB_NAME="x264"

set_toolchain_clang_paths ${LIB_NAME}

