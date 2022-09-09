IF NOT "%JAVA_HOME%" == "%PREFIX%\Library\lib\jvm" exit 1

%JAVA_HOME%/bin/java -version

pushd test-nio
  java -version
  javac TestFilePaths.java
  jar cfm TestFilePaths.jar manifest.mf TestFilePaths.class
  java -jar TestFilePaths.jar TestFilePaths.java
  IF ERRORLEVEL 1 exit 1
popd
