#!/bin/bash

base_path="$(pwd)/../../work"
sources_path="$base_path/sources"

if [ -d "${sources_path}" ]; then
    rm -rf "${sources_path}"
fi

mkdir -p $sources_path

cd $sources_path

X264_git="https://code.videolan.org/videolan/x264.git"
X264_ver="stable"
git clone --depth 1 $X264_git -b $X264_ver x264

X265_git="https://bitbucket.org/multicoreware/x265_git.git"
X265_ver="3.5"
git clone $X265_git -b $X265_ver x265

ffmpeg_git="https://git.ffmpeg.org/ffmpeg.git"
ffmpeg_ver="n6.1"
git clone --depth 1 $ffmpeg_git -b $ffmpeg_ver ffmpeg

fdk_git="https://github.com/mstorsjo/fdk-aac.git"
fdk_ver="v2.0.3"
git clone --depth 1 $fdk_git -b $fdk_ver fdk-aac

lame_download="https://versaweb.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
curl $lame_download -o lame.tar.gz
tar -xvzf lame.tar.gz --directory lame --strip-components=1
rm lame.tar.gz
