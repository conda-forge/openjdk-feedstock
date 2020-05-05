#!/bin/bash -euo

ls -lah
ls -lah lib/*

echo " "

chmod +x bin/*
mkdir -p $PREFIX/bin
mv bin/* $PREFIX/bin/
ls -la $PREFIX/bin

mkdir -p $PREFIX/include
mv include/* $PREFIX/include
if [ -e ./jre/lib/jspawnhelper ]; then
    chmod +x ./jre/lib/jspawnhelper
fi

if [[ "$target_platform" == linux* ]]
then

    if [[ "$target_platform" == *aarch64* ]]; then
      plat=aarch64
    elif [[ "$target_platform" == *ppc64* ]]; then
      plat=ppc64
    else
      plat=amd64
    fi
    mv lib/${plat}/jli/*.so lib
    mv lib/${plat}/*.so lib
    rm -r lib/${plat}
    # libnio.so does not find this within jre/lib/amd64 subdirectory
    cp jre/lib/${plat}/libnet.so lib
    # libjvm.so isn't found
    cp jre/lib/${plat}/server/libjvm.so lib

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
    if [[ "$target_platform" == linux* ]]; then
      echo -e "plat=${plat}\n" > "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
    fi
    cat "${RECIPE_DIR}/scripts/${CHANGE}.sh" >> "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
