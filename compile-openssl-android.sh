#!/bin/bash


# _ANDROID_NDK_ROOT=$1
# _ANDROID_EABI=$2
# _ANDROID_ARCH=$3
# _ANDROID_API=$4
# _OPENSSL_ROOT=$5

# 需要配置的内容
# _ANDROID_NDK_ROOT="/Users/lsq/Desktop/work/android/adt-bundle-mac-x86_64-20140702/android-ndk-r8e"
# _OPENSSL_GCC_VERSION=4.7
# _ANDROID_API="android-14"
_ANDROID_NDK_ROOT="/Users/lsq/Desktop/work/android/adt-bundle-mac-x86_64-20140702/android-sdk-macosx/ndk-bundle"
_OPENSSL_GCC_VERSION=4.9
_ANDROID_API="android-27"
_OPENSSL_ROOT="/Users/lsq/Downloads/sag-word/openssl_android/未命名文件夹/openssl-1.0.2p"
_INSTALL_ROOT="/Users/lsq/Downloads/sag-word/openssl_android/未命名文件夹/result"
BUILD_SHARED=true
#BUILD_CLANG=true
TARGET_ARCHITECTURES=( "armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mip" "mip_64")
#TARGET_ARCHITECTURES=( "armeabi-v7a" )
#TARGET_ARCHITECTURES=( "arm64-v8a" )
#TARGET_ARCHITECTURES=( "x86_64" )
#TARGET_ARCHITECTURES=( "x86" )
#TARGET_ARCHITECTURES=( "mip_64" )
#TARGET_ARCHITECTURES=( "mip" )

# 
basepath=$(cd `dirname $0`; pwd)
. $basepath/Setenv-android-input.sh


PLATFORM_LIBRARY_PREFIX="lib"
STATIC_LIBRARY_SUFFIX=".a"
SHARED_LIBRARY_SUFFIX=".so"
OPENSSL_MODULES=( "crypto" "ssl" )
NCPU=8
#NCPU=1

OPENSSL_LIBRARIES=()
for OPENSSL_MODULE in "${OPENSSL_MODULES[@]}"; do
    OPENSSL_LIBRARIES+=( "${PLATFORM_LIBRARY_PREFIX}${OPENSSL_MODULE}${STATIC_LIBRARY_SUFFIX}" )
    if [ "${BUILD_SHARED}" ]; then
        OPENSSL_LIBRARIES+=( "${PLATFORM_LIBRARY_PREFIX}${OPENSSL_MODULE}${SHARED_LIBRARY_SUFFIX}" )
    fi
done


for TARGET_ARCHITECTURE in "${TARGET_ARCHITECTURES[@]}"; do

  INSTALL_DIR=$_INSTALL_ROOT/$TARGET_ARCHITECTURE
  SOURCE_DIR=$_OPENSSL_ROOT
  mkdir -p "${INSTALL_DIR}"

  ANDROID_EABI_PREFIX=arm-linux-androideabi
  ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}

  if [ "$TARGET_ARCHITECTURE" == "armeabi-v7a" ]
  then
    ANDROID_EABI_PREFIX=arm-linux-androideabi
    _ANDROID_ARCH=arch-arm
    CONFIGURE_SWITCH="android-armv7"
    #CONFIGURE_SWITCH="android"
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  elif [ "$TARGET_ARCHITECTURE" == "arm64-v8a" ]
  then
    ANDROID_EABI_PREFIX=aarch64-linux-android
    _ANDROID_ARCH=arch-arm64
    CONFIGURE_SWITCH="android"
    ANDROID_DEV_INCLUDE_ROOT=aarch64-linux-android
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  elif [ "$TARGET_ARCHITECTURE" == "x86" ]
  then
    _ANDROID_ARCH=arch-x86
    CONFIGURE_SWITCH="android-x86"
    #CONFIGURE_SWITCH="android-x86"
    _ANDROID_EABI=x86-${_OPENSSL_GCC_VERSION}
    ANDROID_EABI_PREFIX=i686-linux-android
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  elif [ "$TARGET_ARCHITECTURE" == "x86_64" ]
  then
    _ANDROID_ARCH=arch-x86_64
    #CONFIGURE_SWITCH="android-x86"
    CONFIGURE_SWITCH="android-x86_64"
    _ANDROID_EABI=x86_64-${_OPENSSL_GCC_VERSION}
    ANDROID_EABI_PREFIX=x86_64-linux-android
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  elif [ "$TARGET_ARCHITECTURE" == "mip" ]
  then
    ANDROID_EABI_PREFIX=mipsel-linux-android
    _ANDROID_ARCH=arch-mips
    CONFIGURE_SWITCH="android-mips"
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  elif [ "$TARGET_ARCHITECTURE" == "mip_64" ]
  then
    ANDROID_EABI_PREFIX=mips64el-linux-android
    _ANDROID_ARCH=arch-mips64
    CONFIGURE_SWITCH="android-mips64"
    _ANDROID_EABI=${ANDROID_EABI_PREFIX}-${_OPENSSL_GCC_VERSION}
    ANDROID_DEV_INCLUDE_ROOT=${ANDROID_EABI_PREFIX}
    ANDROID_TOOLS="${ANDROID_EABI_PREFIX}-gcc ${ANDROID_EABI_PREFIX}-ranlib ${ANDROID_EABI_PREFIX}-ld"
  else
      echo "Unsupported target ABI: $TARGET_ARCHITECTURE"
      exit 1
  fi

  # if [ "${BUILD_CLANG}" ]; then
  #   #_ANDROID_EABI=llvm
  #   #ANDROID_TOOLS="clang"
  #   export CC=clang
  # fi

  echo "OpenSSL ${TARGET_ARCHITECTURE} - setting results directory"
  pushd "${INSTALL_DIR}" || exit
  INSTALL_DIR=$( pwd )
  popd || exit

  echo "OpenSSL ${TARGET_ARCHITECTURE} - setting source directory"
  pushd "${SOURCE_DIR}" || exit
  SOURCE_DIR=$( pwd )

  echo "OpenSSL ${TARGET_ARCHITECTURE} - sourcing options"
  export CFLAGS
  CFLAGS=" -arch ${TARGET_ARCHITECTURE}"
  if [ "${BITCODE_ENABLED}" ]; then
      CFLAGS+=( "-fembed-bitcode" )
  fi
  if [ ! "${BUILD_SHARED}" ]; then
      CFLAGS+=( "-fvisibility=hidden" )
      CFLAGS+=( "-fvisibility-inlines-hidden" )
  fi

  OPTIONS=""
  if [ "${BUILD_SHARED}" ]; then
      OPTIONS+=( "shared " )
  fi
  if [ "$TARGET_ARCHITECTURE" == "x86_64" ]; then
      OPTIONS+=( "no-asm " )
  fi


  make clean

  echo "Android NDK ${TARGET_ARCHITECTURE} - configuring"

  # NDK_CONFIGURE_COMMAND="$basepath/Setenv-android-input.sh ${_ANDROID_NDK_ROOT} ${_ANDROID_EABI} ${_ANDROID_ARCH} ${_ANDROID_API} "
  # echo NDK_CONFIGURE_COMMAND:"${NDK_CONFIGURE_COMMAND}"
  # eval "${NDK_CONFIGURE_COMMAND}"

  say_hello ${_ANDROID_NDK_ROOT} ${_ANDROID_EABI} ${_ANDROID_ARCH} ${_ANDROID_API} 

  export ANDROID_DEV_INCLUDE_ROOT=$ANDROID_DEV_INCLUDE_ROOT
  ANDROID_DEV_INCLUDE="${ANDROID_DEV}/include -I${ANDROID_NDK_ROOT}/sysroot/usr/include -I${ANDROID_NDK_ROOT}/sysroot/usr/include/${ANDROID_DEV_INCLUDE_ROOT}/"
  export ANDROID_DEV_INCLUDE=$ANDROID_DEV_INCLUDE


  echo "Android NDK CONFIG PATH: $PATH"

  echo "OpenSSL ${TARGET_ARCHITECTURE} - configuring"

  CONFIGURE_COMMAND="${SOURCE_DIR}/Configure ${CONFIGURE_SWITCH} ${OPTIONS[*]} --prefix=${INSTALL_DIR} --openssldir=${INSTALL_DIR}"
  echo "${CONFIGURE_COMMAND}"
  eval "${CONFIGURE_COMMAND}"


  echo "OpenSSL ${TARGET_ARCHITECTURE} - building"

  make depend
  make -j"${NCPU}" build_libcrypto build_libssl


  LIB_INSTALL_DIR="${INSTALL_DIR}/lib"
  INCLUDE_INSTALL_DIR="${INSTALL_DIR}/include"
  mkdir -p "${LIB_INSTALL_DIR}"
  mkdir -p "${INCLUDE_INSTALL_DIR}"


  echo "OpenSSL ${TARGET_ARCHITECTURE} - validating and installing"
  OPENSSL_INCLUDE_DIR="${SOURCE_DIR}/include"
  SUCCESS=1
  for OPENSSL_LIBRARY in "${OPENSSL_LIBRARIES[@]}"; do
      OPENSSL_LIBRARY_PATH=$( find "${SOURCE_DIR}" -name "${OPENSSL_LIBRARY}" -print | head -n 1 )

      cp "${OPENSSL_LIBRARY_PATH}" "${LIB_INSTALL_DIR}"
  done
  cp -LR "${OPENSSL_INCLUDE_DIR}/" "${INCLUDE_INSTALL_DIR}/"

  RESULT="success"
  if [ "${SUCCESS}" -ne 0 ]; then
      RESULT="failure"
  fi
  echo "OpenSSL ${TARGET_ARCHITECTURE} - ${RESULT}"

  popd || exit
done