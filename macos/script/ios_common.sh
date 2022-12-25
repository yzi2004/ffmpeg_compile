#!/bin/bash

export DOWNLOAD_DIR="${BASEDIR}/download"

download() {
  if [ ! -d "${DOWNLOAD_DIR}" ]; then
    mkdir -p "${DOWNLOAD_DIR}"
  fi

  (curl --fail --location $1 -o ${DOWNLOAD_DIR}/$2 1>>${BASEDIR}/build.log 2>&1)

  local RC=$?

  if [ ${RC} -eq 0 ]; then
    echo -e "\nDEBUG: Downloaded $1 to ${DOWNLOAD_DIR}/$2\n" 1>>${BASEDIR}/build.log 2>&1
  else
    rm -f ${DOWNLOAD_DIR}/$2 1>>${BASEDIR}/build.log 2>&1

    echo -e -n "\nINFO: Failed to download $1 to ${DOWNLOAD_DIR}/$2, rc=${RC}. " 1>>${BASEDIR}/build.log 2>&1

    if [ "$3" == "exit" ]; then
      echo -e "DEBUG: Build will now exit.\n" 1>>${BASEDIR}/build.log 2>&1
      exit 1
    else
      echo -e "DEBUG: Build will continue.\n" 1>>${BASEDIR}/build.log 2>&1
    fi
  fi

  echo ${RC}
}

get_arch_name() {
    case $1 in
        0) echo "arm64" ;;
        1) echo "arm64e" ;;
        2) echo "x86-64" ;;
    esac
}

get_target_host() {
      case ${ARCH} in
        x86-64-mac-catalyst)
            echo "x86_64-apple-ios13.0-macabi"
        ;;
        *)
            echo "$(get_target_arch)-ios-darwin"
        ;;
    esac
}

get_build_host() {
    echo "$(get_target_arch)-ios-darwin"
}

get_target_build_directory() {
    case ${ARCH} in
        x86-64)
            echo "ios-x86_64"
        ;;
        x86-64-mac-catalyst)
            echo "ios-x86_64-mac-catalyst"
        ;;
        *)
            echo "ios-${ARCH}"
        ;;
    esac
}

get_target_arch() {
    case ${ARCH} in
        arm64 | arm64e)
            echo "aarch64"
        ;;
        x86-64 | x86-64-mac-catalyst)
            echo "x86_64"
        ;;
        *)
            echo "${ARCH}"
        ;;
    esac
}

set_toolchain_clang_paths() {

    if [ ! -f "${DOWNLOAD_DIR}/gas-preprocessor.pl" ]; then

        DOWNLOAD_RESULT=$(download "https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl" "gas-preprocessor.pl" "exit")
        if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
            echo 'tt'
            exit 1
        fi
        (chmod +x ${DOWNLOAD_DIR}/gas-preprocessor.pl 1>>${BASEDIR}/build.log 2>&1) || exit 1

        # patch gas-preprocessor.pl against the following warning
        # Unescaped left brace in regex is deprecated here (and will be fatal in Perl 5.32), passed through in regex; marked by <-- HERE in m/(?:ld|st)\d\s+({ <-- HERE \s*v(\d+)\.(\d[bhsdBHSD])\s*-\s*v(\d+)\.(\d[bhsdBHSD])\s*})/ at /Users/taner/Projects/mobile-ffmpeg/.tmp/gas-preprocessor.pl line 1065.
        sed -i .tmp "s/s\+({/s\+(\\\\{/g;s/s\*})/s\*\\\\})/g" ${DOWNLOAD_DIR}/gas-preprocessor.pl
    fi
    
    if [ ! -d "${BASEDIR}/tools" ]; then
        mkdir -p "${BASEDIR}/tools"
    fi
    
    cp ${DOWNLOAD_DIR}/gas-preprocessor.pl ${BASEDIR}/tools/gas-preprocessor.pl
    
    LOCAL_GAS_PREPROCESSOR="${BASEDIR}/tools/gas-preprocessor.pl"
    if [ "$1" == "x264" ]; then
        LOCAL_GAS_PREPROCESSOR="${BASEDIR}/src/x264/tools/gas-preprocessor.pl"
    fi

    export AR="$(xcrun --sdk ${TARGET_SDK} -f ar)"
    export CC="$(xcrun --sdk ${TARGET_SDK} -f clang)"
    export OBJC="$(xcrun --sdk ${TARGET_SDK} -f clang)"
    export CXX="$(xcrun --sdk ${TARGET_SDK} -f clang++)"

echo $CC

    export LD="$(xcrun --sdk ${TARGET_SDK} -f ld)"
    export RANLIB="$(xcrun --sdk ${TARGET_SDK} -f ranlib)"
    export STRIP="$(xcrun --sdk ${TARGET_SDK} -f strip)"

}

