XCOPY bin\* %LIBRARY_BIN% /s /i /y
if errorlevel 1 exit 1

XCOPY include\* %LIBRARY_INC% /s /i /y
if errorlevel 1 exit 1

XCOPY lib\* %LIBRARY_LIB% /s /i /y
if errorlevel 1 exit 1


:: ensure that JAVA_HOME is set correctly
mkdir %PREFIX%\etc\conda\activate.d
echo set "JAVA_HOME_CONDA_BACKUP=%%JAVA_HOME%%" > "%PREFIX%\etc\conda\activate.d\java_home.bat"
echo set "JAVA_HOME=%%CONDA_PREFIX%%\Library" >> "%PREFIX%\etc\conda\activate.d\java_home.bat"
mkdir %PREFIX%\etc\conda\deactivate.d
echo set "JAVA_HOME=%%JAVA_HOME_CONDA_BACKUP%%" > "%PREFIX%\etc\conda\deactivate.d\java_home.bat"
