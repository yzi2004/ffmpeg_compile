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

if [ -d "${build_path}" ]; then
    rm -rf "${build_path}"
fi

if [ -d "${dist_path}" ]; then
    rm -rf "${dist_path}"
fi

mkdir -p $build_path $dist_path
cd $build_path

#■■■■■■■compile x264
mkdir -p x264
pushd x264
    $sources_path/x264/configure \
          --host=$host \
          --enable-static \
          --disable-cli \
          --cross-prefix=$host- \
          --prefix=$dist_path
    make -j $threads
    make install
popd

#■■■■■■■compile x265
#mkdir -p x265
#pushd x265

#mkdir -p 8bit 10bit 12bit 

#12bit
#cd 12bit
#cmake -G "Ninja" \
#	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
#	-DCMAKE_INSTALL_PREFIX=$dist_path \
#	-DENABLE_SHARED=OFF \
#	-DENABLE_CLI=OFF \
#	-DEXPORT_C_API=ON \
#	-DSTATIC_LINK_CRT=OFF \
#	-DHIGH_BIT_DEPTH=ON \
#	-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
#	-DENABLE_ASSEMBLY=ON \
#	-DMAIN12=ON \
#	$sources_path/x265/source 
#ninja 

#10bit
#cd ../10bit
#cmake -G "Ninja" \
#	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
#	-DCMAKE_INSTALL_PREFIX=$dist_path \
#	-DENABLE_SHARED=OFF \
#	-DENABLE_CLI=OFF \
#	-DEXPORT_C_API=ON \
#	-DSTATIC_LINK_CRT=OFF \
#	-DHIGH_BIT_DEPTH=ON \
#	-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
#	-DENABLE_ASSEMBLY=ON \
#	-DMAIN12=OFF \
#	$sources_path/x265/source 
#ninja 

#8bit
#cd ../8bit
#ln -sf ../10bit/libx265.a libx265_main10.a
#ln -sf ../12bit/libx265.a libx265_main12.a
#cmake -G "Ninja" \
#	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
#	-DCMAKE_INSTALL_PREFIX=$dist_path \
#	-DENABLE_SHARED=OFF \
#	-DENABLE_CLI=OFF \
#	-DEXPORT_C_API=OFF \
#	-DSTATIC_LINK_CRT=ON \
#	-DEXTRA_LIB="x265_main10.a;x265_main12.a" \
#	-DEXTRA_LINK_FLAGS=-L. \
#	-DLINKED_10BIT=ON  \
#	-DLINKED_12BIT=ON \
#	$sources_path/x265/source 
#ninja

#sed -i.orig "s/ -lx265/ -lc++ -lx265/" x265.pc
#sed -i.orig "s/ -lunwind -lunwind//" x265.pc
#mv libx265.a libx265_main.a
#ar -M <$patch_dir/x265.mri
#cmake --install .
#popd

#■■■■■■■compile fdk-aac
cmake_compile "fdk-aac" "-DBUILD_SHARED_LIBS=OFF"

cmake_compile(){
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




