#!/bin/bash

set -exuo pipefail

JVM_BUILD_LOG_LEVEL=warn

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

echo "--------------------------------------------------"
env | sort
echo "--------------------------------------------------"

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
    # use cp to copy file and not link
    cp DISCLAIMER $INSTALL_DIR/DISCLAIMER
  fi

  cp release $INSTALL_DIR/release

  mkdir -p $INSTALL_DIR/conf
  mv conf/* $INSTALL_DIR/conf

  mkdir -p $INSTALL_DIR/jmods
  mv jmods/* $INSTALL_DIR/jmods

  mkdir -p $INSTALL_DIR/legal
  mv legal/* $INSTALL_DIR/legal

  mkdir -p $INSTALL_DIR/man/man1
  mv man/man1/* $INSTALL_DIR/man/man1
  rm -rf man/man1

  # The man dir could be empty already so we can safely ignore this error
  set +e
  mv -f man/* $INSTALL_DIR/man
  set -e
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
      _TOOLCHAIN_ARGS="CC=${CC_FOR_BUILD} CXX=${CXX_FOR_BUILD} CPP=${CXX_FOR_BUILD//+/p}"
      _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS AR=$BUILD_PREFIX/bin/$BUILD-ar"
      _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_CXXFILT=$BUILD_PREFIX/bin/$BUILD-c++filt"
      _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS NM=$BUILD_PREFIX/bin/$BUILD-nm"
      _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS OBJCOPY=$BUILD_PREFIX/bin/$BUILD-objcopy"
      _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS OBJDUMP=$BUILD_PREFIX/bin/$BUILD-objdump"
      _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS READELF=$BUILD_PREFIX/bin/$BUILD-readelf"
      _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS STRIP=$BUILD_PREFIX/bin/$BUILD-strip"
      export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

      # CFLAGS, CXXFLAGS are intentionally empty
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
          --with-log=${JVM_BUILD_LOG_LEVEL} \
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
          --with-harfbuzz=system \
          --with-fontconfig=${BUILD_PREFIX} \
          --with-boot-jdk=$SRC_DIR/bootjdk \
          $_TOOLCHAIN_ARGS
        make JOBS=$CPU_COUNT $_TOOLCHAIN_ARGS images
      popd
    )
  fi


  export CPATH=$PREFIX/include
  export LIBRARY_PATH=$PREFIX/lib

  export -n CFLAGS
  export -n CXXFLAGS
  export -n LDFLAGS

  CONFIGURE_ARGS=""
  if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == 1 ]]; then
    CONFIGURE_ARGS="--with-build-jdk=$SRC_DIR/src/build-build/images/jdk"

    env | sort
    echo "=================================="
    echo "RUNNING CROSS COMPILE"
    echo "=================================="

  fi

  function printerror {
    if [ -f $SRC_DIR/src/build/linux-aarch64-server-release/make-support/failure-logs ]; then
      cat $SRC_DIR/src/build/linux-aarch64-server-release/make-support/failure-logs
    fi
    if [ -f $SRC_DIR/src/build/linux-ppc64le-server-release/make-support/failure-logs ]; then
      cat $SRC_DIR/src/build/linux-ppc64le-server-release/make-support/failure-logs
    fi
    exit 1
  }

  # We purposefully do NOT include LD here as the openjdk build system resolves that internally from
  # --build, --host, and --target in conjunction with BUILD_CC and CC
  _TOOLCHAIN_ARGS="BUILD_CC=${CC_FOR_BUILD} BUILD_CXX=${CXX_FOR_BUILD} BUILD_CPP=${CXX_FOR_BUILD//+/p}"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_AR=$BUILD_PREFIX/bin/$BUILD-ar"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_CXXFILT=$BUILD_PREFIX/bin/$BUILD-c++filt"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_NM=$BUILD_PREFIX/bin/$BUILD-nm"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_OBJCOPY=$BUILD_PREFIX/bin/$BUILD-objcopy"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_OBJDUMP=$BUILD_PREFIX/bin/$BUILD-objdump"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_READELF=$BUILD_PREFIX/bin/$BUILD-readelf"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS BUILD_STRIP=$BUILD_PREFIX/bin/$BUILD-strip"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS CC=${CC} CXX=${CXX} CPP=${CXX//+/p}"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS AR=$BUILD_PREFIX/bin/$HOST-ar"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS CXXFILT=$BUILD_PREFIX/bin/$HOST-c++filt"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS NM=$BUILD_PREFIX/bin/$HOST-nm"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS OBJCOPY=$BUILD_PREFIX/bin/$HOST-objcopy"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS OBJDUMP=$BUILD_PREFIX/bin/$HOST-objdump"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS READELF=$BUILD_PREFIX/bin/$HOST-readelf"
  _TOOLCHAIN_ARGS="$_TOOLCHAIN_ARGS STRIP=$BUILD_PREFIX/bin/$HOST-strip"

  ./configure \
    --prefix=$PREFIX \
    --build=${BUILD} \
    --host=${HOST} \
    --target=${HOST} \
    --with-extra-cflags="$CFLAGS" \
    --with-extra-cxxflags="$CXXFLAGS -fpermissive" \
    --with-extra-ldflags="$LDFLAGS" \
    --with-log=${JVM_BUILD_LOG_LEVEL} \
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
    --with-harfbuzz=system \
    --disable-warnings-as-errors \
    --with-boot-jdk=$SRC_DIR/bootjdk \
    --disable-javac-server \
    ${CONFIGURE_ARGS} \
    $_TOOLCHAIN_ARGS

  make JOBS=$CPU_COUNT $_TOOLCHAIN_ARGS || printerror
  make JOBS=$CPU_COUNT images $_TOOLCHAIN_ARGS || printerror
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
  # This is not present on AdoptOpenJDK>=17 and appears to have been replaced with $INSTALL_DIR/libjli.so
  # mv $INSTALL_DIR/lib/jli/*.so $INSTALL_DIR/lib/
    
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
