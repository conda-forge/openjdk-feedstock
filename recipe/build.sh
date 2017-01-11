#!/bin/bash -euo

chmod +x bin/*
chmod +x jre/bin/*
mv bin/* $PREFIX/bin/
ls -la $PREFIX/bin
mv include $PREFIX/include
if [ -e jre/lib/jspawnhelper ]; then
    chmod +x jre/lib/jspawnhelper
fi

if [[ `uname` == "Linux" ]]
then
    mv lib/amd64/jli/*.so lib
    mv lib/amd64/*.so lib
    rm -r lib/amd64
    # libnio.so does not find this within jre/lib/amd64 subdirectory
    cp jre/lib/amd64/libnet.so lib

    # include dejavu fonts to allow java to work even on minimal cloud images where these fonts are missing
    # (thanks to @chapmanb)
    mkdir -p jre/lib/fonts
    cd jre/lib/fonts
    curl -L -O -C - http://sourceforge.net/projects/dejavu/files/dejavu/2.36/dejavu-fonts-ttf-2.36.tar.bz2
    tar -xjvpf dejavu-fonts-ttf-2.36.tar.bz2
    mv dejavu-fonts-ttf-*/ttf/* .
    rm -rf dejavu-fonts-ttf-*
    cd ../../../
fi

mv jre $PREFIX/
mv lib $PREFIX/lib

# ensure that JAVA_HOME is set correctly
mkdir -p $PREFIX/etc/conda/activate.d
echo 'export JAVA_HOME_CONDA_BACKUP=$JAVA_HOME' > "$PREFIX/etc/conda/activate.d/java_home.sh"
echo 'export JAVA_HOME=$CONDA_PREFIX' >> "$PREFIX/etc/conda/activate.d/java_home.sh"
mkdir -p $PREFIX/etc/conda/deactivate.d
echo 'export JAVA_HOME=$JAVA_HOME_CONDA_BACKUP' > "$PREFIX/etc/conda/deactivate.d/java_home.sh"
