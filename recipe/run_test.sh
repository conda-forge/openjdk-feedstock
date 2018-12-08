#!/bin/sh

if [[ $(uname -s) == CYGWIN* ]] || [[ $(uname -s) =~ M* ]];
then
    # Windows
    if [ "${JAVA_HOME}" != "${PREFIX}/Library" ]; then
      echo "ERROR: JAVA_HOME (${JAVA_HOME}) not equal to PREFIX (${PREFIX}/Library)"
      exit 1
    fi

else 
    # Linux / OSX
   if [ "${JAVA_HOME}" != "${PREFIX}" ]; then
     echo "ERROR: JAVA_HOME (${JAVA_HOME}) not equal to PREFIX (${PREFIX})"
     exit 1
   fi
fi

pushd test-nio
  javac TestFilePaths.java
  jar cfm TestFilePaths.jar manifest.mf TestFilePaths.class
  java -jar TestFilePaths.jar TestFilePaths.java
popd
