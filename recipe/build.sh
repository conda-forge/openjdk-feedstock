#!/bin/bash -euo

chmod +x bin/*
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/
ls -la $PREFIX/bin

mkdir -p $PREFIX/include
mv include/* $PREFIX/include
if [ -e ./lib/jspawnhelper ]; then
    chmod +x ./lib/jspawnhelper
fi

if [[ `uname` == "Linux" ]]
then
    mv lib/jli/*.so lib/

    # Include dejavu fonts to allow java to work even on minimal cloud
    # images where these fonts are missing (thanks to @chapmanb)
    mkdir -p lib/fonts
    mv ./fonts/ttf/* ./lib/fonts/
    rm -rf ./fonts
fi

mkdir $PREFIX/lib
mv lib/* $PREFIX/lib

# Use this as the license file
mv DISCLAIMER $PREFIX/DISCLAIMER

mkdir -p $PREFIX/conf
mv conf/* $PREFIX/conf

mkdir -p $PREFIX/jmods
mv jmods/* $PREFIX/jmods

mkdir -p $PREFIX/legal
mv legal/* $PREFIX/legal

mkdir -p $PREFIX/man
mv man/* $PREFIX/man

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
