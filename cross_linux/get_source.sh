#!/bin/bash
set -x

sources_path="$(pwd)/sources"

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
ffmpeg_release="n6.1"
git clone --depth 1 $ffmpeg_git -b $ffmpeg_release ffmpeg
