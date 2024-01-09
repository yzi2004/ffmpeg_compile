#!/bin/bash

function cmake_compile(){
	if [ -d "${build_path}/$1" ]; then
	    rm -rf "$build_path/$1"
	fi
	
	mkdir -p $1
	pushd $1
	
	cmake -G "Ninja" \
	        -DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	        -DCMAKE_INSTALL_PREFIX=$dist_path \
	        $2 \
	        $sources_path/$1
	
	ninja && cmake --install .
	popd
}
