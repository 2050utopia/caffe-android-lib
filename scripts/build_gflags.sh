#!/usr/bin/env sh
[[ -n $DEBUG_BUILD ]] && set -ex

if [ -z "$ANDROID_NDK" ] && [ "$#" -eq 0 ]; then
    echo 'Either $ANDROID_NDK should be set or provided as argument'
    echo "e.g., 'export ANDROID_NDK=/path/to/ndk' or"
    echo "      '${0} /path/to/ndk'"
    exit 1
else
    ANDROID_NDK="${1:-${ANDROID_NDK}}"
fi

GFLAGS_LINK="https://github.com/gflags/gflags/archive/v2.1.2.tar.gz"
GFLAGS_TARBALL=gflags_v2.1.2.tar.gz
DOWNLOAD_DIR=${WD}/download
if [ -d "$_WD/gflags-2.1.2" ] ; then
    export GFLAGS_ROOT=${_WD}/gflags-2.1.2
else
    export GFLAGS_ROOT=${WD}/gflags-2.1.2
fi    
export GFLAGS_BUILD_DIR=${GFLAGS_ROOT}/build/${ANDROID_ABI_SHORT}
export GFLAGS_INSTALL_DIR=${WD}/android_lib/${ANDROID_ABI_SHORT}

[ ! -d ${DOWNLOAD_DIR} ] && mkdir -p ${DOWNLOAD_DIR}

cd ${DOWNLOAD_DIR}
if [ ! -f ${GFLAGS_TARBALL} ]; then
    wget ${GFLAGS_LINK} -O ${GFLAGS_TARBALL}
fi

if [ ! -d ${GFLAGS_ROOT} ]; then
    tar zxf ${GFLAGS_TARBALL} -C "${WD}"
fi

rm -rf "${GFLAGS_BUILD_DIR}"
mkdir -p "${GFLAGS_BUILD_DIR}"
cd "${GFLAGS_BUILD_DIR}"

cmake -DCMAKE_TOOLCHAIN_FILE="${WD}/android-cmake/android.toolchain.cmake" \
      -DANDROID_NDK="${ANDROID_NDK}" \
      -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -DANDROID_ABI="${ANDROID_ABI}" \
      -DANDROID_NATIVE_API_LEVEL=21 \
      -DANDROID_TOOLCHAIN_NAME=$TOOLCHAIN_NAME \
      -DCMAKE_INSTALL_PREFIX="${GFLAGS_INSTALL_DIR}/gflags" \
      ../..

make -j
rm -rf "${GFLAGS_INSTALL_DIR}/gflags"
make install/strip

cd "${WD}"
