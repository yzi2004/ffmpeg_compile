#!/bin/bash

BASE_PATH=$HOME/tmp
SOURCES_PATH=$BASE_PATH/sources
ENV=$MSYSTEM

BUILD_PATH="${BASE_PATH}/build_${ENV}"
INSTALL_PATH="${BASE_PATH}/installed_${ENV}"
PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$INSTALL_PATH/lib/pkgconfig

echo "BUILD_PATH=${BUILD_PATH}"
echo "INSTALL_PATH=${INSTALL_PATH}"

rm -rf $BUILD_PATH
rm -rf $INSTALL_PATH

####################
# install tools
####################
echo -e "\e[1;44m install tools \e[0m"
pacman -S --needed --noconfirm diffutils make nasm autoconf automake libtool git mercurial pkg-config

############################
# install compile toolchain
###########################
echo -e "\e[1;44m install compile toolschain:${ENV} \e[0m"
if [ $ENV = "MINGW64" ]; then
    pacman -S --needed --noconfirm mingw-w64-x86_64-toolchain mingw-w64-x86_64-meson mingw-w64-x86_64-cmake mingw-w64-x86_64-gperf
elif [ $ENV = "UCRT64" ]; then
    pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-toolchain mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-gperf
elif [ $ENV = "CLANG64" ]; then
    pacman -S --needed --noconfirm mingw-w64-clang-x86_64-toolchain mingw-w64-clang-x86_64-meson \
         mingw-w64-clang-x86_64-cmake mingw-w64-clang-x86_64-gperf mingw-w64-clang-x86_64-openjpeg2
else
    pacman -S --needed --noconfirm mingw-w64-clang-aarch64-toolchain mingw-w64-clang-aarch64-meson mingw-w64-clang-aarch64-cmake mingw-w64-clang-aarch64-gperf
fi

########################
# x264 compile         #
########################
echo -e "\e[1;44m COMPILE x264 \e[0m"
mkdir -p $BUILD_PATH/x264 && cd $BUILD_PATH/x264
$SOURCES_PATH/x264/configure --prefix=$INSTALL_PATH \
    --enable-static \
    --disable-cli \
    --disable-win32thread 
make -j 8 && make install

#######################
# x265 compile        #
#######################
echo -e "\e[1;44m COMPILE x265 \e[0m"
mkdir -p $BUILD_PATH/x265 && cd $BUILD_PATH/x265
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH \
      -DENABLE_CLI=off \
      -DENABLE_SHARED=off \
      -DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
      -DSTATIC_LINK_CRT=on \
      -DENABLE_ASSEMBLY=on \
      -DENABLE_HDR10_PLUS=on \
      $SOURCES_PATH/x265/source 
ninja && cmake --install . 
if [ $ENV = "CLANG64" ]; then
	sed -i.orig "s/ -lx265/ -lc++ -lx265/" $INSTALL_PATH/lib/pkgconfig/x265.pc
else
	sed -i.orig "s/ -lx265/  -lstdc++ -lgcc_s -lgcc -lx265/" $INSTALL_PATH/lib/pkgconfig/x265.pc
fi

################
# libvpx compile
################
echo -e "\e[1;44m COMPILE libvpx \e[0m"
$SOURCES_PATH/libvpx/configure --prefix=$INSTALL_PATH \
--disable-docs \
--disable-examples \
--disable-tools \
--enable-vp9-highbitdepth \
--enable-better-hw-compatibility \
--disable-install-docs \
--disable-install-bins \
--disable-unit-tests \
--enable-vp8 \
--enable-vp9 \
--enable-small
make -j 8 && make install

sed -i.orig "s/ -lvpx -lm/ -lpthread -lvpx -lm/" $INSTALL_PATH/lib/pkgconfig/vpx.pc

################
# fdk-aac compile
################
echo -e "\e[1;44m COMPILE fdk-aac \e[0m"
 mkdir -p $BUILD_PATH/fdk-aac &&  cd $BUILD_PATH/fdk-aac
 cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH \
     -DBUILD_SHARED_LIBS=off \
     $SOURCES_PATH/fdk-aac 
 ninja && cmake --install . 

################
# brotli compile
################
echo -e "\e[1;44m COMPILE brotli \e[0m"
mkdir -p $BUILD_PATH/brotli &&  cd $BUILD_PATH/brotli
export LDFLAGS="-static"
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH \
     -DBUILD_TESTING=off \
  $SOURCES_PATH/brotli
ninja && cmake --install . 

################
# aom compile
################
echo -e "\e[1;44m COMPILE aom \e[0m"
mkdir -p $BUILD_PATH/aom &&  cd $BUILD_PATH/aom
cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH \
       -DENABLE_NASM=on \
       -DCMAKE_POLICY_DEFAULT_CMP0091=NEW \
       -DENABLE_DOCS=off \
       -DENABLE_EXAMPLES=off  \
       -DENABLE_TESTDATA=off \
       -DENABLE_TESTS=off \
       -DENABLE_TOOLS=off \
       $SOURCES_PATH/aom 
ninja && cmake --install . 

################
# freetype + harfbuzz compile
################
echo -e "\e[1;44m COMPILE freetype + harfbuzz \e[0m"
mkdir -p $BUILD_PATH/freetype &&  cd $BUILD_PATH/freetype
meson setup --prefix=$INSTALL_PATH \
     --buildtype=release \
     --default-library=static \
     -Dharfbuzz=disabled \
     -Dbrotli=disabled \
     --wrap-mode=nofallback \
     $SOURCES_PATH/freetype 
ninja && meson install 

mkdir -p $BUILD_PATH/harfbuzz &&  cd $BUILD_PATH/harfbuzz
meson setup --prefix=$INSTALL_PATH \
    --buildtype=release \
    --default-library=static \
    -Dfreetype=enabled \
    -Dgdi=enabled \
    -Dtests=disabled \
    -Ddocs=disabled \
    --wrap-mode=nofallback \
    $SOURCES_PATH/harfbuzz 
ninja && meson install 

mkdir -p $BUILD_PATH/freetype_with_harfbuzz &&  cd $BUILD_PATH/freetype_with_harfbuzz
meson setup --prefix=$INSTALL_PATH \
     --buildtype=release \
     --default-library=static \
     --wrap-mode=nofallback \
     $SOURCES_PATH/freetype 
ninja && meson install 

sed -i.orig "s/ libbrotlidec/ libvpx/" $INSTALL_PATH/lib/pkgconfig/freetype2.pc

################
# fribidi compile
################
echo -e "\e[1;44m COMPILE fribidi \e[0m"
mkdir -p $BUILD_PATH/fribidi &&  cd $BUILD_PATH/fribidi
meson setup --prefix=$INSTALL_PATH \
    --buildtype=release \
    --default-library=static \
    -Ddocs=false \
    -Dbin=false \
    -Dtests=false \
    --wrap-mode=nofallback \
     $SOURCES_PATH/fribidi 
ninja && meson install 

################
# fontconfig compile
################
echo -e "\e[1;44m COMPILE fontconfig \e[0m"
mkdir -p $BUILD_PATH/fontconfig &&  cd $BUILD_PATH/fontconfig
meson setup --prefix=$INSTALL_PATH \
     --buildtype=release \
     --default-library=static \
     -Ddoc=disabled \
     -Dtests=disabled \
     -Dtools=disabled \
     --wrap-mode=nofallback \
     $SOURCES_PATH/fontconfig 
ninja && meson install 

################
# libass compile
################
echo -e "\e[1;44m COMPILE libass \e[0m"
cd $SOURCES_PATH/libass 
./autogen.sh

mkdir -p $BUILD_PATH/libass &&  cd $BUILD_PATH/libass
$SOURCES_PATH/libass/configure --prefix=$INSTALL_PATH \
     --disable-docs  \
     --enable-static=yes \
     --enable-shared=no 
make -j 8 && make install

################
# AMF install
################
echo -e "\e[1;44m install AMF \e[0m"
mkdir -p $INSTALL_PATH/include/AMF && cd $INSTALL_PATH/include/AMF
cp $SOURCES_PATH/AMF/amf/public/include/components . -r 
cp $SOURCES_PATH/AMF/amf/public/include/core . -r 

################
# ffmpeg compile
################
echo -e "\e[1;44m COMPILE ffmpeg \e[0m"

mkdir -p $BUILD_PATH/ffmpeg &&  cd $BUILD_PATH/ffmpeg
$SOURCES_PATH/ffmpeg/configure --prefix=$INSTALL_PATH \
    --enable-asm  \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libfdk-aac \
    --enable-libass \
    --enable-libaom \
    --enable-libvpx \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libopenjpeg \
    --enable-amf \
    --enable-gpl \
    --disable-debug \
    --disable-optimizations \
    --enable-version3 \
    --disable-doc \
    --enable-nonfree \
    --disable-ffplay \
    --disable-ffprobe \
    --extra-libs=-static \
    --extra-ldflags="-LIBPATH:${INSTALL_PATH}/lib" \
    --extra-cflags="-I${INSTALL_PATH}}/include/ --static"
make -j 8 && make install
