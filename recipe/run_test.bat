IF NOT "%JAVA_HOME%" == "%PREFIX%\Library\lib\jvm"             exit 1

"%JAVA_HOME%/bin/java" -version                             || exit 1

pushd test-nio
  java -version                                             || exit 1
  javac TestFilePaths.java                                  || exit 1
  jar cfm TestFilePaths.jar manifest.mf TestFilePaths.class || exit 1
  java -jar TestFilePaths.jar TestFilePaths.java            || exit 1
popd
