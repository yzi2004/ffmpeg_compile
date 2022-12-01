#!/bin/bash

SOURCES_PATH=$HOME/tmp/sources

if [ -d "$SOURCES_PATH" ]; then
  rm -rf $SOURCES_PATH
fi

echo "$SOURCES_PATH"
mkdir -p $SOURCES_PATH

cd $SOURCES_PATH
echo -e "\e[1;44m GET ffmpeg  \e[0m"
git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git ffmpeg 

echo -e "\e[1;44m GET x264  \e[0m"
git clone --depth 1 https://code.videolan.org/videolan/x264.git 

echo -e "\e[1;44m GET x265  \e[0m"
git clone https://bitbucket.org/multicoreware/x265_git.git x265

echo -e "\e[1;44m GET libass  \e[0m"
git clone --depth 1 https://github.com/libass/libass.git 

echo -e "\e[1;44m GET aom  \e[0m"
git clone --depth 1 https://aomedia.googlesource.com/aom 

echo -e "\e[1;44m GET AMF  \e[0m"
git clone --depth 1 https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git 

echo -e "\e[1;44m brolti \e[0m"
git clone --depth 1 https://github.com/google/brotli.git

echo -e "\e[1;44m GET freetype  \e[0m"
git clone --depth 1 https://gitlab.freedesktop.org/freetype/freetype.git 

echo -e "\e[1;44m GET harfbuzz  \e[0m"
git clone --depth 1 https://github.com/harfbuzz/harfbuzz.git

echo -e "\e[1;44m GET fribidi  \e[0m"
git clone --depth 1 https://github.com/fribidi/fribidi.git

echo -e "\e[1;44m GET fontconfig  \e[0m"
git clone --depth 1 https://gitlab.freedesktop.org/fontconfig/fontconfig.git

echo -e "\e[1;44m GET libvpx  \e[0m"
git clone --depth 1 https://chromium.googlesource.com/webm/libvpx

echo -e "\e[1;44m GET fdk-aac  \e[0m"
git clone --depth 1 https://github.com/mstorsjo/fdk-aac.git

echo -e "\e[1;44m GET kvazaar  \e[0m"
git clone --depth 1 https://github.com/ultravideo/kvazaar.git
