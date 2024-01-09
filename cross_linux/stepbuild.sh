#!/bin/bash

host="x86_64-w64-mingw32"
build="x86_64-linux-gnu"

base_path="$(pwd)/../../work"
sources_path="$base_path/sources"
build_path="$base_path/ff_build"
dist_path="$base_path/ff_dist"

patch_dir="$(pwd)/patches"
config_dir="$(pwd)/config"

threads="8" 

export PKG_CONFIG_PATH="$dist_path/lib/pkgconfig"

cd $build_path

if [ -d "${build_path}/zlib" ]; then
    rm -rf "${build_path}/zlib"
fi

mkdir -p zlib
pushd zlib

cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
 	-DBUILD_SHARED_LIBS=false \
	$sources_path/zlib
ninja && cmake --install . 
popd
