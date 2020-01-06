#!/bin/bash -euo

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

  if [[ "$target_platform" == linux* ]]; then
    rm $PREFIX/include/iconv.h
  fi

  export CPATH=$PREFIX/include
  export LIBRARY_PATH=$PREFIX/lib

  export -n CFLAGS
  export -n CXXFLAGS
  export -n LDFLAGS

  if [[ "$CI" == "travis" ]]; then
    export CPU_COUNT=4
  fi

  chmod +x configure
  ./configure \
    --prefix=$PREFIX \
    --with-extra-cflags="$CFLAGS" \
    --with-extra-cxxflags="$CFLAGS" \
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
    --with-boot-jdk=$SRC_DIR/bootjdk

  make JOBS=$CPU_COUNT
  make images
}

if [[ "$target_platform" == linux* ]]; then 
  export INSTALL_DIR=$SRC_DIR/bootjdk/
  jdk_install
  source_build
  cd build/*/images/jdk
fi

export INSTALL_DIR=$PREFIX
jdk_install

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
