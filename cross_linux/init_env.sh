#!/bin/bash

sudo apt install cmake ninja-build nasm meson

wget https://github.com/mstorsjo/llvm-mingw/releases/download/20231128/llvm-mingw-20231128-ucrt-ubuntu-20.04-x86_64.tar.xz
tar xf llvm-mingw-20231128-ucrt-ubuntu-20.04-x86_64.tar.xz
rm llvm-mingw-20231128-ucrt-ubuntu-20.04-x86_64.tar.xz

sudo mv llvm-mingw-20231128-ucrt-ubuntu-20.04-x86_64 /opt/llvm-mingw-ucrt-x86_64

echo -e '\nPATH="/opt/llvm-mingw-ucrt-x86_64/bin:$PATH"' >> .profile
