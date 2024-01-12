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

#set BROTLI_BUILD_TOOLS=FALSE
#set BROTLI_DISABLE_TESTS=TRUE

options=" -Ddoc=disabled \
     -Dtests=disabled \
     -Dtools=disabled \
     --wrap-mode=nofallback"

meson_compile "fontconfig" "${options}"

#set BROTLI_BUILD_TOOLS=
#set BROTLI_DISABLE_TESTS=

