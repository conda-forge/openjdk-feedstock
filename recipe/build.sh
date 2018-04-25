#!/bin/bash -euo

chmod +x bin/*
chmod +x lib/jexec

mv bin/* $PREFIX/bin/

mv lib/jli/*.so lib
mv lib/*.so lib
rm -r lib

mkdir -p jre/lib/fonts
cd jre/lib/fonts
curl -L -O -C - http://sourceforge.net/projects/dejavu/files/dejavu/2.36/dejavu-fonts-ttf-2.36.tar.bz2
tar -xjvpf dejavu-fonts-ttf-2.36.tar.bz2
mv dejavu-fonts-ttf-*/ttf/* .
rm -rf dejavu-fonts-ttf-*
cd ../../../


mv lib/* $PREFIX/lib
mv src.zip $PREFIX/

mkdir -p $PREFIX/etc/conda/activate.d
mkdir -p $PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/scripts/activate.sh $PREFIX/etc/conda/activate.d/java_home.sh
cp $RECIPE_DIR/scripts/deactivate.sh $PREFIX/etc/conda/deactivate.d/java_home.sh
