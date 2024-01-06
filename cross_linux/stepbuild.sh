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

pushd bzip2

CC=$host-clang AR=$host-ar RANLIB=$host-ranlib make -j $threads libbz2.a
#install -m644 bzlib.h $include_path/bzlib.h
#install -m644 libbz2.a $library_path/libbz2.a
#install -m644 $bzip_pc_file_path $PKG_CONFIG_PATH
popd
