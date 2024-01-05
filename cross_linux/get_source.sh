#!/bin/bash
set -x

sources_path="$(pwd)/sources"

mkdir -p $sources_path

cd $sources_path

x264_git="https://code.videolan.org/videolan/x264.git"
x264_ver="stable"
git clone --depth 1 $x64_git -b $x264_ver x264

x265_git="https://bitbucket.org/multicoreware/x265_git.git"
x265_ver="3.5"
git clone $265_git -b $x65_ver x265

ffmpeg_git="https://git.ffmpeg.org/ffmpeg.git"
ffmpeg_release="n6.1"
git clone --depth 1 $ffmpeg_git -b $ffmpeg_release ffmpeg
