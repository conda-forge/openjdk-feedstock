#!/bin/bash

set -e
export 
if [ ! -d $JAVA_LD_LIBRARY_PATH ]; then
	echo "Did you remember to activate the conda environment?"
	exit -1
fi
os=$(uname -s | tr '[:upper:]' '[:lower:]')

if [ $os == 'darwin' ]; then
	export DYLD_LIBRARY_PATH=$JAVA_LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
elif [ $os == 'linux' ]; then
	export LD_LIBRARY_PATH=$JAVA_LD_LIBRARY_PATH:$JAVA_LD_LIBRARY_PATH
fi

gcc \
	-I$JAVA_HOME/include 			\
	-I$JAVA_HOME/include/$os		\
	-L$JAVA_LD_LIBRARY_PATH			\
	-ljvm					\
	-o vmtest				\
	test-jni/vmtest.c 
	
./vmtest
