#!/bin/bash
set -x

sources_path="$(pwd)/sources"

mkdir -p $sources_path

bzip2_git="git://sourceware.org/git/bzip2.git"
bzip2_release="bzip2-1.0.8"
bzip_patchfile_path="$patch_dir/bzip2-1.0.8_brokenstuff.diff" #From https://raw.githubusercontent.com/rdp/ffmpeg-windows-build-helpers/master/patches/bzip2-1.0.8_brokenstuff.diff
bzip_pc_file_path="$patch_dir/bzip2.pc"
zlib_git="https://github.com/madler/zlib.git"
zlib_release="v1.2.13"

libpng_git="https://github.com/glennrp/libpng.git"
libpng_release="v1.6.39"
libxml2_git="https://gitlab.gnome.org/GNOME/libxml2.git"
libxml2_release="v2.10.3"
libzimg_git="https://github.com/sekrit-twc/zimg.git"
libzimg_release="release-3.0.4"

lame_download="https://versaweb.dl.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz"
fdk_git="https://github.com/mstorsjo/fdk-aac.git"
fdk_release="v2.0.2"

x264_git="https://code.videolan.org/videolan/x264.git"
x264_release="stable"
x265_hg="http://hg.videolan.org/x265"
x265_mri_path="$patch_dir/x265.mri"
libopenjpeg_git="https://github.com/uclouvain/openjpeg.git"
libopenjpeg_release="v2.5.0"
libaom_git="https://aomedia.googlesource.com/aom"
libaom_version="v3.6.0"

libfreetype2_git="https://gitlab.freedesktop.org/freetype/freetype.git"
libfreetype2_release="VER-2-13-1"
harfbuzz_git="https://github.com/harfbuzz/harfbuzz.git"
harfbuzz_release="8.0.1"
fribidi_git="https://github.com/fribidi/fribidi.git"
fribidi_release="v1.0.13" #Upgrade to v1.0.10 causes fribidi to not be found by ffmpeg; maybe due to https://github.com/fribidi/fribidi/issues/156?
fontconfig_git="https://gitlab.freedesktop.org/fontconfig/fontconfig.git"
fontconfig_release="2.14.2"
libass_git="https://github.com/libass/libass.git"
libass_release="0.17.1" 

ffmpeg_git="https://git.ffmpeg.org/ffmpeg.git"
ffmpeg_release="n6.1"

