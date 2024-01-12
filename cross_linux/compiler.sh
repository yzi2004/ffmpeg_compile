#!/bin/bash

function cmake_compile(){
	echo -e "\e[1;44m .......................... $1 .......................  \e[0m"

	if [ -d "${build_path}/$1" ]; then
	    rm -rf "$build_path/$1"
	fi
	
	mkdir -p $1
	pushd $1

	src_path=$3
        if [ -z "$src_path" ]
        then
	       src_path=$1
        fi

	cmake -G "Ninja" \
	        -DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	        -DCMAKE_INSTALL_PREFIX=$dist_path \
		-DCMAKE_BUILD_TYPE=Release \
	        $2 \
	        $sources_path/$src_path
	
	ninja && cmake --install .
	popd
}

function cmake_compile_only(){
        cmake -G "Ninja" \
                -DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
                -DCMAKE_INSTALL_PREFIX=$dist_path \
                $2 \
                $sources_path/$1

        ninja
}


function meson_compile(){

	echo -e "\e[1;44m .......................... $1 .......................  \e[0m"

        if [ -d "${build_path}/$1" ]; then
            rm -rf "$build_path/$1"
        fi

	src_path=$3
        if [ -z "$src_path" ]
        then
               src_path=$1
        fi

        mkdir -p $1
        pushd $1
	
	meson setup --prefix=$dist_path \
		--cross-file=$config_dir/cross_for_windows_meson.txt \
	        --buildtype=release \
		--default-library=static \
		$2 \
		$sources_path/$src_path

	ninja && meson install
	popd
}
