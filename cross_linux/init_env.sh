#!/bin/bash

sudo apt install cmake ninja-build nasm meson

if [  -d "/opt/llvm-mingw-ucrt-x86_64" ]; then
        sudo rm -rf /opt/llvm-mingw-ucrt-x86_64
fi

wget https://github.com/mstorsjo/llvm-mingw/releases/download/20250114/llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64.tar.xz
tar xf llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64.tar.xz
rm llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64.tar.xz

sudo mv llvm-mingw-20250114-ucrt-ubuntu-20.04-x86_64/ /opt/llvm-mingw-ucrt-x86_64

echo -e '\nPATH="/opt/llvm-mingw-ucrt-x86_64/bin:$PATH"' >> ~/.profile

source .profile
