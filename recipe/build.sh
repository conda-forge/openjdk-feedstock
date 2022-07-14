#!/bin/bash

set -exuo pipefail

# Remove code signatures from osx-64 binaries as they will be invalidated in the later process.
# TODO: Fix https://github.com/thefloweringash/sigtool to add --remove-signature support
if [[ "${target_platform}" == "osx-64" ]]; then
  for b in `ls bin`; do
    /usr/bin/codesign --remove-signature bin/$b
  done
  for b in `ls lib/*.dylib lib/*.dylib.* lib/**/*.dylib`; do
    /usr/bin/codesign --remove-signature $b
  done
  /usr/bin/codesign --remove-signature lib/jspawnhelper
fi

function jdk_install
{
  chmod +x bin/*
  mkdir -p $INSTALL_DIR/bin
  mv bin/* $INSTALL_DIR/bin/
  ls -la $INSTALL_DIR/bin

  mkdir -p $INSTALL_DIR/include
  mv include/* $INSTALL_DIR/include
  if [ -e ./lib/jspawnhelper ]; then
    chmod +x ./lib/jspawnhelper
  fi

  mkdir -p $INSTALL_DIR/lib
  mv lib/* $INSTALL_DIR/lib

  if [ -f "DISCLAIMER" ]; then
    mv DISCLAIMER $INSTALL_DIR/DISCLAIMER
  fi

  mkdir -p $INSTALL_DIR/conf
  mv conf/* $INSTALL_DIR/conf

  mkdir -p $INSTALL_DIR/jmods
  mv jmods/* $INSTALL_DIR/jmods

  mkdir -p $INSTALL_DIR/legal
  mv legal/* $INSTALL_DIR/legal

  mkdir -p $INSTALL_DIR/man/man1
  mv man/man1/* $INSTALL_DIR/man/man1
  rm -rf man/man1
  mv man/* $INSTALL_DIR/man
}

function source_build
{
  cd src

  chmod +x configure

  if [[ "$target_platform" == linux* ]]; then
    rm $PREFIX/include/iconv.h
  fi


  if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    (
      if [[ "$build_platform" == linux* ]]; then
        rm $BUILD_PREFIX/include/iconv.h
      fi

      export CPATH=$BUILD_PREFIX/include
      export LIBRARY_PATH=$BUILD_PREFIX/lib
      export CC=${CC_FOR_BUILD}
      export CXX=${CXX_FOR_BUILD}
      export CPP=${CXX_FOR_BUILD//+/p}
      export NM=$($CC_FOR_BUILD -print-prog-name=nm)
      export AR=$($CC_FOR_BUILD -print-prog-name=ar)
      export OBJCOPY=$($CC_FOR_BUILD -print-prog-name=objcopy)
      export STRIP=$($CC_FOR_BUILD -print-prog-name=strip)
      export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

      # CFLAGS and CXXFLAGS are intentionally empty
      export -n CFLAGS
      export -n CXXFLAGS
      unset CPPFLAGS

      CFLAGS=$(echo $CFLAGS | sed 's/-mcpu=[a-z0-9]*//g' | sed 's/-mtune=[a-z0-9]*//g' | sed 's/-march=[a-z0-9]*//g')
      CXXFLAGS=$(echo $CXXFLAGS | sed 's/-mcpu=[a-z0-9]*//g' | sed 's/-mtune=[a-z0-9]*//g' | sed 's/-march=[a-z0-9]*//g')

      ulimit -c unlimited
      mkdir build-build
        pushd build-build
        ../configure \
          --prefix=${BUILD_PREFIX} \
          --build=${BUILD} \
          --host=${BUILD} \
          --target=${BUILD} \
          --with-extra-cflags="${CFLAGS//$PREFIX/$BUILD_PREFIX}" \
          --with-extra-cxxflags="${CXXFLAGS//$PREFIX/$BUILD_PREFIX} -fpermissive" \
          --with-extra-ldflags="${LDFLAGS//$PREFIX/$BUILD_PREFIX}" \
          --with-stdc++lib=dynamic \
          --disable-warnings-as-errors \
          --with-x=${BUILD_PREFIX} \
          --with-cups=${BUILD_PREFIX} \
          --with-freetype=system \
          --with-giflib=system \
          --with-libpng=system \
          --with-zlib=system \
          --with-libjpeg=system \
          --with-lcms=system \
          --with-fontconfig=${BUILD_PREFIX} \
          --with-boot-jdk=$SRC_DIR/bootjdk
        make JOBS=$CPU_COUNT images
      popd
    )
  fi


  export CPATH=$PREFIX/include
  export LIBRARY_PATH=$PREFIX/lib
  export BUILD_CC=${CC_FOR_BUILD}
  export BUILD_CXX=${CXX_FOR_BUILD}
  export BUILD_CPP=${CXX_FOR_BUILD//+/p}
  export BUILD_NM=$($CC_FOR_BUILD -print-prog-name=nm)
  export BUILD_AR=$($CC_FOR_BUILD -print-prog-name=ar)
  export BUILD_OBJCOPY=$($CC_FOR_BUILD -print-prog-name=objcopy)
  export BUILD_STRIP=$($CC_FOR_BUILD -print-prog-name=strip)

  export -n CFLAGS
  export -n CXXFLAGS
  export -n LDFLAGS

  CONFIGURE_ARGS=""
  if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CONFIGURE_ARGS="--with-build-jdk=$SRC_DIR/src/build-build/images/jdk"
  fi

  ./configure \
    --prefix=$PREFIX \
    --build=${BUILD} \
    --host=${HOST} \
    --target=${HOST} \
    --with-extra-cflags="$CFLAGS" \
    --with-extra-cxxflags="$CXXFLAGS -fpermissive" \
    --with-extra-ldflags="$LDFLAGS" \
    --with-x=$PREFIX \
    --with-cups=$PREFIX \
    --with-freetype=system \
    --with-fontconfig=$PREFIX \
    --with-giflib=system \
    --with-libpng=system \
    --with-zlib=system \
    --with-libjpeg=system \
    --with-lcms=system \
    --with-stdc++lib=dynamic \
    --disable-warnings-as-errors \
    --with-boot-jdk=$SRC_DIR/bootjdk \
    ${CONFIGURE_ARGS}

  make JOBS=$CPU_COUNT
  make JOBS=$CPU_COUNT images
}

if [[ "$target_platform" == linux* ]]; then
  export INSTALL_DIR=$SRC_DIR/bootjdk/
  jdk_install
  source_build
  cd build/*/images/jdk
fi

export INSTALL_DIR=$PREFIX/lib/jvm
jdk_install

# Symlink java binaries
for i in $(find $INSTALL_DIR/bin -type f -printf '%P\n'); do
    mkdir -p "$PREFIX/bin/$(dirname $i)"
    ln -s -r -f "$INSTALL_DIR/bin/$i" "$PREFIX/bin/$i"
done
# Symlink man pages
for i in $(find $INSTALL_DIR/man -type f -printf '%P\n'); do
    mkdir -p "$PREFIX/man/$(dirname $i)"
    ln -s -r -f "$INSTALL_DIR/man/$i" "$PREFIX/man/$i"
done

if [[ "$target_platform" == linux* ]]; then
  mv $INSTALL_DIR/lib/jli/*.so $INSTALL_DIR/lib/
  # Include dejavu fonts to allow java to work even on minimal cloud
  # images where these fonts are missing (thanks to @chapmanb)
  mkdir -p $INSTALL_DIR/lib/fonts
  mv $SRC_DIR/fonts/ttf/* $INSTALL_DIR/lib/fonts/
fi
find $PREFIX -name "*.debuginfo" -exec rm -rf {} \;


# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
