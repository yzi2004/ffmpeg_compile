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

mkdir -p $build_path
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
mkdir -p x265
pushd x265

mkdir -p 8bit 10bit 12bit 

#12bit
cd 12bit
cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
	-DENABLE_SHARED=OFF \
	-DENABLE_CLI=OFF \
	-DEXPORT_C_API=ON \
	-DSTATIC_LINK_CRT=OFF \
	-DHIGH_BIT_DEPTH=ON \
	-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
	-DENABLE_ASSEMBLY=ON \
	-DMAIN12=ON \
	$sources_path/x265/source 
ninja 

#10bit
cd ../10bit
cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
	-DENABLE_SHARED=OFF \
	-DENABLE_CLI=OFF \
	-DEXPORT_C_API=ON \
	-DSTATIC_LINK_CRT=OFF \
	-DHIGH_BIT_DEPTH=ON \
	-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
	-DENABLE_ASSEMBLY=ON \
	-DMAIN12=OFF \
	$sources_path/x265/source 
ninja 

#8bit
cd ../8bit
ln -sf ../10bit/libx265.a libx265_main10.a
ln -sf ../12bit/libx265.a libx265_main12.a
cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
	-DENABLE_SHARED=OFF \
	-DENABLE_CLI=OFF \
	-DEXPORT_C_API=OFF \
	-DSTATIC_LINK_CRT=ON \
	-DEXTRA_LIB="x265_main10.a;x265_main12.a" \
	-DEXTRA_LINK_FLAGS=-L. \
	-DLINKED_10BIT=ON  \
	-DLINKED_12BIT=ON \
	$sources_path/x265/source 
ninja

sed -i.orig "s/ -lx265/ -lc++ -lx265/" x265.pc
sed -i.orig "s/ -lunwind -lunwind//" x265.pc
mv libx265.a libx265_main.a
ar -M <$patch_dir/x265.mri
cmake --install .
popd

#■■■■■■■compile fdk-aac
mkdir -p fdk-aac
pushd fdk-aac

cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
	-DBUILD_SHARED_LIBS=OFF \
	$sources_path/fdk-aac
ninja && cmake --install . 
popd

#■■■■■■■compile libaom
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

#■■■■■■■compile zlib
mkdir -p zlib && pushd zlib

cmake -G "Ninja" \
	-DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
	-DCMAKE_INSTALL_PREFIX=$dist_path \
 	-DZLIB_SHARED=OFF \
	$sources_path/zlib
ninja && cmake --install . 

#■■■■■■■compile bzip2
mkdir -p bzip2 && pushd bzip2

cmake -G "Ninja" \
        -DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
        -DCMAKE_INSTALL_PREFIX=$dist_path \
        -DENABLE_SHARED_LIB=OFF \
        $sources_path/bzip2
ninja && cmake --install .
popd

mkdir -p libng
pushd libpng

cmake -G "Ninja" \
        -DCMAKE_TOOLCHAIN_FILE="$config_dir/cross_for_windows.cmake" \
        -DCMAKE_INSTALL_PREFIX=$dist_path \
        -DPNG_SHARED=OFF \
        -DPNG_EXECUTABLES=OFF \
        -DPNG_TESTS=OFF \
        $sources_path/libpng

ninja && cmake --install .
popd

#■■■■■■■compile freetype
mkdir -p freetype 
pushd freetype

meson setup --prefix=$dist_path \
	--cross-file=$config_dir/cross_meson.txt \
     --buildtype=release \
     --default-library=static \
     -Dharfbuzz=disabled \
     -Dbrotli=disabled \
     --wrap-mode=nofallback \
     $sources_path/libfreetype2
#ninja && meson install 
popd


#■■■■■■■compile ffmpeg

mkdir -p ffmpeg
pushd ffmpeg

$sources_path/ffmpeg/configure --prefix=$dist_path \
	--arch=x86_64 \
	--target-os=mingw32 \
	--cross-prefix=$host- \
	--pkg-config=pkg-config \
	--pkg-config-flags=--static \
	--enable-small \
	--enable-asm \
	--disable-w32threads \
	--enable-libx264 \
	--enable-libx265 \
	--disable-debug \
	--disable-optimizations \
	--enable-version3 \
	--enable-gpl \
	--disable-doc \
	--enable-nonfree \
	--disable-ffplay \
	--disable-ffprobe \
	--extra-libs=-static \
	--extra-ldflags="-LIBPATH:${dist_path}/lib" \
	--extra-cflags="--static"

make -j $threads
make install
