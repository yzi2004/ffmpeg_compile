#!/bin/bash

base_path="$(pwd)/../../work"
sources_path="$base_path/sources"

patch_dir="$(pwd)/patches"

if [ -d "${sources_path}" ]; then
    rm -rf "${sources_path}"
fi

mkdir -p $sources_path

cd $sources_path

echo -e "\e[1;44m ----x264-----  \e[0m"
X264_git="https://code.videolan.org/videolan/x264.git"
X264_ver="stable"
git clone --depth 1 $X264_git -b $X264_ver x264

#echo -e "\e[1;44m ----x265-----  \e[0m"
#X265_git="https://bitbucket.org/multicoreware/x265_git.git"
#X265_ver="3.5"
#git clone $X265_git -b $X265_ver x265

echo -e "\e[1;44m ---fdk-aac---  \e[0m"
fdk_git="https://github.com/mstorsjo/fdk-aac.git"
fdk_ver="v2.0.3"
git clone --depth 1 $fdk_git -b $fdk_ver fdk-aac

echo -e "\e[1;44m -----mp3----  \e[0m"
lame_download="https://versaweb.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
curl $lame_download -o lame.tar.gz
tar xzf lame.tar.gz && mv lame-3.100 lame
rm lame.tar.gz

echo -e "\e[1;44m -----aom----  \e[0m"
libaom_git="https://aomedia.googlesource.com/aom"
libaom_ver="v3.8.0"
git clone --depth 1 $libaom_git -b $libaom_ver libaom

echo -e "\e[1;44m ----zlib----  \e[0m"
zlib_git="https://github.com/madler/zlib.git"
zlib_ver="v1.3"
git clone --depth 1 $zlib_git -b $zlib_ver zlib

pushd zlib
mv CMakeLists.txt CMakeLists.txt.orig
cp $patch_dir/zlib-1.3/CMakeLists.txt .
popd

echo -e "\e[1;44m ----bzip2----  \e[0m"
bzip2_git="https://sourceware.org/git/bzip2.git"
bzip2_ver="bzip2-1.0.8"
git clone --depth 1 $bzip2_git -b $bzip2_ver bzip2

pushd bzip2
patch -p0 < $patch_dir/bzip2-1.0.8/bzip2-1.0.8.diff
cp $patch_dir/bzip2-1.0.8/CMakeLists.txt .
cp $patch_dir/bzip2-1.0.8/CMakeOptions.txt .
cp $patch_dir/bzip2-1.0.8/bz2.pc.in .
popd

echo -e "\e[1;44m ----libpng----  \e[0m"
libpng_git="https://github.com/glennrp/libpng.git"
libpng_ver="v1.6.40"
git clone --depth 1 $libpng_git -b $libpng_ver libpng

echo -e "\e[1;44m ----brotli----  \e[0m"
brotli_git="https://github.com/google/brotli.git"
brotli_ver="v1.1.0"
git clone --depth 1 $brotli_git -b $brotli_ver brotli

echo -e "\e[1;44m --freetype2-  \e[0m"
libfreetype2_git="https://gitlab.freedesktop.org/freetype/freetype.git"
libfreetype2_ver="VER-2-13-2"
git clone --depth 1 $libfreetype2_git -b $libfreetype2_ver libfreetype2

echo -e "\e[1;44m --harfbuzz-  \e[0m"
harfbuzz_git="https://github.com/harfbuzz/harfbuzz.git"
harfbuzz_ver="8.3.0"
git clone --depth 1 $harfbuzz_git -b $harfbuzz_ver harfbuzz

echo -e "\e[1;44m --fribidi-  \e[0m"
fribidi_git="https://github.com/fribidi/fribidi.git"
fribidi_ver="v1.0.13" 
git clone --depth 1 $fribidi_git -b $fribidi_ver fribidi

echo -e "\e[1;44m --fontconfig-  \e[0m"
fontconfig_git="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
fontconfig_ver="2.15.0"
git clone --depth 1 $fontconfig_git -b $fontconfig_ver fontconfig

echo -e "\e[1;44m -----ass----  \e[0m"
libass_git="https://github.com/libass/libass.git"
libass_ver="0.17.1" 
git clone --depth 1 $libass_git -b $libass_ver libass

echo -e "\e[1;44m ---ffmpeg----  \e[0m"
ffmpeg_git="https://git.ffmpeg.org/ffmpeg.git"
ffmpeg_ver="n6.1"
git clone --depth 1 $ffmpeg_git -b $ffmpeg_ver ffmpeg
