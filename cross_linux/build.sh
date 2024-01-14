#!/bin/bash

host="x86_64-w64-mingw32"
build="x86_64-linux-gnu"

base_path="/tmp"
sources_path="$base_path/sources"
build_path="$base_path/ff_build"
dist_path="$base_path/ff_dist"

patch_dir="$(pwd)/patches"
config_dir="$(pwd)/config"

threads="8" 

export PKG_CONFIG_PATH="$dist_path/lib/pkgconfig"

. compiler.sh

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
      --disable-win32thread \
      --cross-prefix=$host- \
      --prefix=$dist_path
make -j $threads
make install
popd

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
cmake_compile_only "x265/source" "${options}"

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

cmake_compile_only "x265/source" "${options}"

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

cmake_compile_only "x265/source" "${options}"

sed -i.orig "s/ -lx265/ -lc++ -lx265/" x265.pc
sed -i.orig "s/ -lunwind -lunwind//" x265.pc
mv libx265.a libx265_main.a
ar -M <$patch_dir/x265.mri
cmake --install .
popd

#■■■■■■■compile fdk-aac
options="-DBUILD_SHARED_LIBS=OFF"
cmake_compile "fdk-aac" "${options}"

#■■■■■■■compile mp3lame
options=""
cmake_compile "lame" "${options}"

#■■■■■■■compile libaom
options="-DENABLE_NASM=ON \
       	-DAOM_TARGET_CPU=x86_64 \
       	-DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
       	-DENABLE_DOCS=OFF \
       	-DENABLE_EXAMPLES=OFF \
       	-DENABLE_TESTDATA=OFF \
       	-DENABLE_TESTS=OFF \
       	-DENABLE_TOOLS=OFF"
cmake_compile "libaom" "${options}"

options="-DZLIB_SHARED=OFF" 
cmake_compile "zlib" "${options}"

options=""
cmake_compile "bzip2" "${options}"

options="-DEXPAT_BUILD_TOOLS=OFF \
	-DEXPAT_BUILD_EXAMPLES=OFF \
	-DEXPAT_BUILD_TESTS=OFF \
	-DEXPAT_SHARED_LIBS=OFF \
	-DEXPAT_BUILD_DOCS=OFF"

cmake_compile "libexpat" "${options}" "libexpat/expat"

options="-DPNG_SHARED=OFF \
        -DPNG_EXECUTABLES=OFF \
        -DPNG_TESTS=OFF"
cmake_compile "libpng" "${options}"

options="-Dharfbuzz=disabled \
	-Dbrotli=disabled \
	-Dbzip2=enabled \
	-Dpng=enabled \
	-Dtests=disabled \
	-Dzlib=enabled \
	--wrap-mode=nofallback"

meson_compile "libfreetype2" "${options}"

options="-Dfreetype=enabled \
        -Dgdi=disabled \
        -Dtests=disabled \
        -Ddocs=disabled \
        --wrap-mode=nofallback"

meson_compile "harfbuzz" "${options}"

options="-Dharfbuzz=enabled \
        -Dbrotli=disabled \
        -Dbzip2=enabled \
        -Dpng=enabled \
        -Dtests=disabled \
        -Dzlib=enabled \
        --wrap-mode=nofallback"

meson_compile "libfreetype2" "${options}"

options="-Ddocs=false \
        -Dbin=false \
        -Dtests=false \
        --wrap-mode=nofallback"

meson_compile "fribidi" "${options}"

options=" -Ddoc=disabled \
     -Dtests=disabled \
     -Dtools=disabled \
     --wrap-mode=nofallback"

meson_compile "fontconfig" "${options}"

options="-Dtest=false"

meson_compile "libass" "${options}"

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
        --enable-libass \
	--enable-libmp3lame \
	--enable-libfdk-aac \
    	--enable-libaom \
    	--enable-libfreetype \
    	--enable-libfribidi \
        --disable-debug \
        --disable-optimizations \
        --enable-version3 \
        --enable-gpl \
        --disable-doc \
        --enable-nonfree \
        --disable-ffplay \
        --disable-ffprobe \
        --extra-cflags="-static -O3 -I${dist_path}/include " \
    	--extra-cxxflags="-static -O3 " \
    	--extra-ldflags="-static -O3 -s -L${dist_path}/lib" 

make 
make install
popd
