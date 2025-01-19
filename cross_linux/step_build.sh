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

if [ ! "$1" = "" ]; then
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

if [ ! -f "${flag_path}/x264" ]; then
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
	make -j $threads || exit 1
	make install || exit 1
	popd
        echo -n "" > $flag_path/x264
fi

if [ ! -f "${flag_path}/x265" ]; then
	#■■■■■■■compile x265
	mkdir -p x265
	pushd x265
	
	mkdir -p 8bit 10bit 12bit 
	
	####12bit
	cd 12bit
	options="-DENABLE_CLI=OFF \
		-DENABLE_SHARED=OFF \
		-DEXPORT_C_API=ON \
		-DSTATIC_LINK_CRT=OFF \
		-DHIGH_BIT_DEPTH=ON \
		-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
		-DENABLE_ASSEMBLY=ON \
		-DMAIN12=ON"
	cmake_compile_only "x265/source" "${options}" || exit 1
	
	###10bit
	cd ../10bit
	options="-DENABLE_CLI=OFF \
		-DENABLE_SHARED=OFF \
		-DEXPORT_C_API=ON \
		-DSTATIC_LINK_CRT=OFF \
		-DHIGH_BIT_DEPTH=ON \
		-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
		-DENABLE_ASSEMBLY=ON \
		-DMAIN12=OFF"
	
	cmake_compile_only "x265/source" "${options}" || exit 1
	
	####8bit
	cd ../8bit
	ln -sf ../10bit/libx265.a libx265_main10.a
	ln -sf ../12bit/libx265.a libx265_main12.a
	
	options='-DENABLE_CLI=OFF \
		-DEXPORT_C_API=OFF \
		-DENABLE_SHARED=OFF \
		-DSTATIC_LINK_CRT=ON \
		-DEXTRA_LIB="x265_main10.a;x265_main12.a" \
		-DEXTRA_LINK_FLAGS=-L. \
		-DLINKED_10BIT=ON  \
		-DLINKED_12BIT=ON'
	
	cmake_compile_only "x265/source" "${options}" || exit 1
	
	sed -i.orig "s/ -lx265/ -lc++ -lx265/" x265.pc
	sed -i.orig "s/ -lunwind -lunwind//" x265.pc
	mv libx265.a libx265_main.a
	ar -M <$patch_dir/x265-3.5/x265.mri
	cmake --install . 
	popd
 	echo -n "" > $flag_path/x265
 fi

if [ ! -f "${flag_path}/fdk-aac" ]; then
	#■■■■■■■compile fdk-aac
	options="-DBUILD_SHARED_LIBS=OFF"
	cmake_compile "fdk-aac" "${options}" || exit 1
 	echo -n "" > $flag_path/fdk-aac
fi

if [ ! -f "${flag_path}/mp3lame" ]; then
	#■■■■■■■compile mp3lame
	options=""
	cmake_compile "lame" "${options}" || exit 1
 	echo -n "" > $flag_path/mp3lame
fi

if [ ! -f "${flag_path}/libaom" ]; then
	#■■■■■■■compile libaom
	options="-DENABLE_NASM=ON \
	       	-DAOM_TARGET_CPU=x86_64 \
	       	-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
	       	-DENABLE_DOCS=OFF \
	       	-DENABLE_EXAMPLES=OFF \
	       	-DENABLE_TESTDATA=OFF \
	       	-DENABLE_TESTS=OFF \
	       	-DENABLE_TOOLS=OFF"
	cmake_compile "libaom" "${options}" || exit 1
 	echo -n "" > $flag_path/libaom
fi

if [ ! -f "${flag_path}/zlib" ]; then
	options="-DZLIB_SHARED=OFF" 
	cmake_compile "zlib" "${options}" || exit 1
 	echo -n "" > $flag_path/zlib
 fi

if [ ! -f "${flag_path}/blip2" ]; then
	options=""
	cmake_compile "bzip2" "${options}" || exit 1
 	echo -n "" > $flag_path/bzip2
fi
