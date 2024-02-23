#!/bin/bash

host="x86_64-w64-mingw32"
build="x86_64-linux-gnu"

base_path="/tmp"
sources_path="$base_path/sources"
build_path="$base_path/ff_build"
libs_path="$base_path/ff_libs"
dist_path="$(pwd)/../../ff_dist"
flag_path="$base_path/ff_flags"

patch_dir="$(pwd)/patches"
config_dir="$(pwd)/config"

threads="8" 

export PKG_CONFIG_PATH="$libs_path/lib/pkgconfig"

. compiler.sh

if [ -d "${build_path}" ]; then
    rm -rf "${build_path}"
fi

if [ -d "${dist_path}" ]; then
    rm -rf "${dist_path}"
fi

if [ -d "${libs_path}" ]; then
    rm -rf "${libs_path}"
fi

if [ -d "${libs_path}" ]; then
    rm -rf "${libs_path}"
fi

if [ ! "$1" = "" ]; then
    if [ -d "${flag_path}" ]; then
        rm -rf "${flag_path}"
    fi
     mkdir -p $flag_path
else
    if [ ! -d "${flag_path}" ]; then
        mkdir -p $flag_path
    fi
fi

mkdir -p $build_path $libs_path 
cd $build_path

if [ ! -f "${flag_path}/zlib" ]; then
	options="-DZLIB_SHARED=OFF" 
	cmake_compile "zlib" "${options}" || exit 1
 	echo -n "" > $flag_path/zlib
 fi

if [ ! -f "${flag_path}/blip2" ]; then
	options=""
	cmake_compile "bzip2" "${options}" || exit 1
 	echo -n "" > $flag_path/bzip2
fi

if [ ! -f "${flag_path}/libexpat" ]; then
	options="-DEXPAT_BUILD_TOOLS=OFF \
		-DEXPAT_BUILD_EXAMPLES=OFF \
		-DEXPAT_BUILD_TESTS=OFF \
		-DEXPAT_SHARED_LIBS=OFF \
		-DEXPAT_BUILD_DOCS=OFF"
	cmake_compile "libexpat" "${options}" "libexpat/expat" || exit 1
 	echo -n "" > $flag_path/libexpat
fi

if [ ! -f "${flag_path}/libpng" ]; then
	options="-DPNG_SHARED=OFF \
	        -DPNG_EXECUTABLES=OFF \
	        -DPNG_TESTS=OFF"
	cmake_compile "libpng" "${options}"
	echo -n "" > $flag_path/libpng
fi

if [ ! -f "${flag_path}/openjpeg" ]; then
	options="-DBUILD_SHARED_LIBS=OFF \
	        -DBUILD_PKGCONFIG_FILES=ON"
	cmake_compile "openjpeg" "${options}"
	echo -n "" > $flag_path/openjpeg
fi
