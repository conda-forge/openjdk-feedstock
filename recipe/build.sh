#!/bin/bash -euo

chmod +x bin/*
mv bin/* $PREFIX/bin/
ls -la $PREFIX/bin

mv include/* $PREFIX/include
if [ -e ./lib/jspawnhelper ]; then
    chmod +x ./lib/jspawnhelper
fi

if [[ `uname` == "Linux" ]]
then
    mv lib/jli/*.so lib

    # Include dejavu fonts to allow java to work even on minimal cloud
    # images where these fonts are missing (thanks to @chapmanb)
    mkdir -p lib/fonts
    cd lib/fonts
    curl -L -O -C - http://sourceforge.net/projects/dejavu/files/dejavu/2.36/dejavu-fonts-ttf-2.36.tar.bz2
    tar -xjvpf dejavu-fonts-ttf-2.36.tar.bz2
    mv dejavu-fonts-ttf-*/ttf/* .
    rm -rf dejavu-fonts-ttf-*
    cd ../../
fi

mv lib/* $PREFIX/lib

# Ensure that JAVA_HOME is set correctly
mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/scripts/activate.sh $PREFIX/etc/conda/activate.d/java_home.sh
cp $RECIPE_DIR/scripts/deactivate.sh $PREFIX/etc/conda/deactivate.d/java_home.sh
