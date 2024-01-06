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

mkdir -p libaom
pushd libaom

cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
	-DENABLE_NASM=ON \
 	-DAOM_TARGET_CPU=x86_64 \
	-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
	-DENABLE_DOCS=OFF \
	-DENABLE_EXAMPLES=OFF  \
	-DENABLE_TESTDATA=OFF \
	-DENABLE_TESTS=OFF \
	-DENABLE_TOOLS=OFF \
	$sources_path/libaom
ninja && cmake --install . 
popd
