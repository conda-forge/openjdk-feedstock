cl ^
	test-jni/vmtest.c                       ^
	/I"%JAVA_HOME%\include"			^
	/I"%JAVA_HOME%\include\win32"		^
	/link					^
	/LIBPATH:"%JAVA_HOME%\lib"		^
	/LIBPATH:"%JAVA_HOME%\jre\bin\server"	^
	jvm.lib
if errorlevel 1 exit 1

dir
if errorlevel 1 exit 1

.\vmtest.exe
if errorlevel 1 exit 1
