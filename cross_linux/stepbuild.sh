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

mkdir -p bzip2
pushd bzip2

cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
 	-DZLIB_SHARED=OFF \
	$sources_path/bzip2
ninja && cmake --install . 
popd
