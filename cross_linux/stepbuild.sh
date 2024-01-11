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

. compiler.sh

prj="freetype"


cd $build_path

#options="-DFT_REQUIRE_ZLIB=TRUE \
#        -DFT_REQUIRE_PNG=TRUE \
#        -DFT_DISABLE_HARFBUZZ=FALSE \
#        -DFT_DISABLE_BROTLI=FALSE"
#cmake_compile "libfreetype2" "${options}"
options="-Dharfbuzz=disabled \
        -Dbrotli=disabled \
        --wrap-mode=nofallback"

meson_compile "libfreetype2" "${options}"
