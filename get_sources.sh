#!/bin/bash

SOURCES_PATH=$HOME/tmp/sources

if [ -d "$SOURCES_PATH" ]; then
  rm -rf $SOURCES_PATH
fi

echo "$SOURCES_PATH"

mkdir -p $SOURCES_PATH

cd $SOURCES_PATH
echo -e "\e[1;44m get ffmpeg  \e[0m"
git clone --depth 1 https://git.ffmpeg.org/ffmpeg.git ffmpeg 

echo -e "\e[1;44m get x264  \e[0m"
git clone --depth 1 https://code.videolan.org/videolan/x264.git 

echo -e "\e[1;44m get x265  \e[0m"
hg clone http://hg.videolan.org/x265 

echo -e "\e[1;44m get libass  \e[0m"
git clone --depth 1 https://github.com/libass/libass.git 

echo -e "\e[1;44m get aom  \e[0m"
git clone --depth 1 https://aomedia.googlesource.com/aom 

echo -e "\e[1;44m get AMF  \e[0m"
git clone --depth 1 https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git 

echo -e "\e[1;44m get freetype  \e[0m"
git clone --depth 1 https://gitlab.freedesktop.org/freetype/freetype.git 

echo -e "\e[1;44m get harfbuzz  \e[0m"
git clone --depth 1 https://github.com/harfbuzz/harfbuzz.git

echo -e "\e[1;44m get fribidi  \e[0m"
git clone --depth 1 https://github.com/fribidi/fribidi.git

echo -e "\e[1;44m get fontconfig  \e[0m"
git clone --depth 1 https://gitlab.freedesktop.org/fontconfig/fontconfig.git

echo -e "\e[1;44m get openjpeg  \e[0m"
git clone --depth 1 https://github.com/uclouvain/openjpeg.git

#echo -e "\e[1;44m get libyuv  \e[0m"
#git clone --depth 1 https://chromium.googlesource.com/libyuv/libyuv

#echo -e "\e[1;44m get libvpx  \e[0m"
#git clone --depth 1 https://chromium.googlesource.com/webm/libvpx

echo -e "\e[1;44m get fdk-aac  \e[0m"
git clone --depth 1 https://github.com/mstorsjo/fdk-aac.git

echo -e "\e[1;44m get libpng  \e[0m"
git clone --deptn 1 https://github.com/glennrp/libpng.git
