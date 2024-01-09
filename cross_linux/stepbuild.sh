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

prj="freetype"


cd $build_path

if [ -d "${build_path}/${prj}" ]; then
    rm -rf "${build_path}/${prj}"
fi

mkdir -p ${prj} 
pushd ${prj}

cmake -G "Ninja" \
        -DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
        -DCMAKE_INSTALL_PREFIX=$dist_path \
        -DFT_REQUIRE_ZLIB=TRUE \
        -DFT_REQUIRE_PNG=TRUE \
        -DFT_DISABLE_HARFBUZZ=FALSE \
        -DFT_DISABLE_BROTLI=FALSE \
        $sources_path/libfreetype2

ninja && cmake --install .
popd

