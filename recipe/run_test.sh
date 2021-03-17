#!/bin/bash

set -ex

if [[ "${target_platform}" != "${build_platform}" ]] && [[ "${target_platform}" == "osx-arm64" ]]; then
  echo "Not running tests on osx-arm64 when cross-compiling."
else
  if [ "${JAVA_HOME}" != "${PREFIX}" ]; then
    echo "ERROR: JAVA_HOME (${JAVA_HOME}) not equal to PREFIX (${PREFIX})"
    exit 1
  fi

  pushd test-nio
    javac TestFilePaths.java
    jar cfm TestFilePaths.jar manifest.mf TestFilePaths.class
    java -jar TestFilePaths.jar TestFilePaths.java
  popd
fi
