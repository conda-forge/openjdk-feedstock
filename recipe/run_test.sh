#!/bin/sh
set -e

# Linux / OSX
if [ "${JAVA_HOME}" != "${PREFIX}" ]; then
  echo "ERROR: JAVA_HOME (${JAVA_HOME}) not equal to PREFIX (${PREFIX})"

  # Windows
  if [ "${JAVA_HOME}" != "${PREFIX}/Library" ]; then
    echo "ERROR: JAVA_HOME (${JAVA_HOME}) not equal to PREFIX (${PREFIX}/Library)"
    exit 1
  fi
fi

${JAVA_HOME}/bin/java -version

pushd test-nio
  javac TestFilePaths.java
  jar cfm TestFilePaths.jar manifest.mf TestFilePaths.class
  java -jar TestFilePaths.jar TestFilePaths.java
popd
