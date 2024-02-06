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

if [ ${1} -ne "" ]; then
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

if [ -f "${flag_path}/x264" ]; then
	#■■■■■■■compile x264
	mkdir -p x264
	pushd x264
	$sources_path/x264/configure \
	      --host=$host \
	      --enable-static \
	      --disable-cli \
	      --disable-win32thread \
	      --cross-prefix=$host- \
	      --prefix=$libs_path
	make -j $threads
	make install
	popd
        echo -n "" > $flag_path/x264
fi

