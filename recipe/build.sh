#!/bin/bash -euo

chmod +x bin/*
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/
ls -la $PREFIX/bin

mkdir -p $PREFIX/include
mv include/* $PREFIX/include
if [ -e ./jre/lib/jspawnhelper ]; then
    chmod +x ./jre/lib/jspawnhelper
fi

if [[ `uname` == "Linux" ]]
then
    mv lib/amd64/jli/*.so lib
    mv lib/amd64/*.so lib
    rm -r lib/amd64
    # libnio.so does not find this within jre/lib/amd64 subdirectory
    cp jre/lib/amd64/libnet.so lib

    # Include dejavu fonts to allow java to work even on minimal cloud
    # images where these fonts are missing (thanks to @chapmanb)
    mkdir -p lib/fonts
    mv ./fonts/ttf/* ./lib/fonts/
    rm -rf ./fonts
    # Have libjvm.so show up in the right place
    ln -s $INSTALL_DIR/lib/server/libjvm.so $INSTALL_DIR/lib/libjvm.so
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
