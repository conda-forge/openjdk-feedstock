#!/bin/bash

set -e
os=$(uname -s | tr '[:upper:]' '[:lower:]')
JAVA_LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/amd64/server
if [ $os == 'darwin' ]; then
	JAVA_LD_LIBRARY_PATH=$JAVA_HOME/jre/lib/server
fi

gcc \
	-I$JAVA_HOME/include 			\
	-I$JAVA_HOME/include/$os		\
	-L$JAVA_LD_LIBRARY_PATH			\
	-ljvm					\
	-o vmtest				\
	test-jni/vmtest.c 
	
if [ $os == 'darwin' ]; then
	DYLD_LIBRARY_PATH=$JAVA_LD_LIBRARY_PATH ./vmtest
elif [ $os == 'linux']; then
	LD_LIBRARY_PATH=$JAVA_LD_LIBRARY_PATH ./vmtest
fi
