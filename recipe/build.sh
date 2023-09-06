#!/bin/bash

set -exuo pipefail

# Remove code signatures from osx-64 binaries as they will be invalidated in the later process.
if [[ "${target_platform}" == "osx-64" ]]; then
  for b in `ls bin`; do
    /usr/bin/codesign --remove-signature bin/$b
  done
  for b in `ls jre/bin`; do
    /usr/bin/codesign --remove-signature jre/bin/$b
  done
  for b in `ls jre/lib/*.dylib jre/lib/*.dylib.* jre/lib/**/*.dylib`; do
    /usr/bin/codesign --remove-signature $b
  done
  /usr/bin/codesign --remove-signature jre/lib/jspawnhelper
fi

chmod +x bin/*
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/
ls -la $PREFIX/bin

mkdir -p $PREFIX/include
mv include/* $PREFIX/include
if [ -e ./jre/lib/jspawnhelper ]; then
    chmod +x ./jre/lib/jspawnhelper
fi

if [[ "${target_platform}" == linux-* ]]; then
  if [[ "${target_platform}" == "linux-aarch64" ]]; then
    JDK_ARCH=aarch64
  else
    JDK_ARCH=amd64
  fi
  mv lib/${JDK_ARCH}/jli/*.so lib
  mv lib/${JDK_ARCH}/*.so lib
  rm -r lib/${JDK_ARCH}
  # libnio.so does not find this within jre/lib/amd64 subdirectory
  cp jre/lib/${JDK_ARCH}/libnet.so lib

  # Include dejavu fonts to allow java to work even on minimal cloud
  # images where these fonts are missing (thanks to @chapmanb)
  mkdir -p lib/fonts
  mv ./fonts/ttf/* ./lib/fonts/
  rm -rf ./fonts
fi

mkdir -p $PREFIX/jre
mv jre/* $PREFIX/jre

mkdir -p $PREFIX/lib
mv lib/* $PREFIX/lib

mkdir -p $PREFIX/man
mv man/* $PREFIX/man

mv src.zip $PREFIX/src.zip

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
