setlocal EnableDelayedExpansion

set INSTALL_DIR=%LIBRARY_PREFIX%\lib\jvm

mkdir %INSTALL_DIR%\bin
XCOPY bin\* %INSTALL_DIR%\bin\ /s /i /y
if errorlevel 1 exit 1

mkdir %INSTALL_DIR%\include
XCOPY include\* %INSTALL_DIR%\include\ /s /i /y
if errorlevel 1 exit 1

mkdir %INSTALL_DIR%\lib
XCOPY lib\* %INSTALL_DIR%\lib\ /s /i /y
if errorlevel 1 exit 1

XCOPY release %INSTALL_DIR% /s /i /y
if errorlevel 1 exit 1

XCOPY DISCLAIMER %INSTALL_DIR% /s /i /y
if errorlevel 1 exit 1

if not exist "%INSTALL_DIR%\conf\" mkdir %INSTALL_DIR%\conf\
XCOPY conf\* %INSTALL_DIR%\conf\ /s /i /y
if errorlevel 1 exit 1

if not exist "%INSTALL_DIR%\jmods\" mkdir %INSTALL_DIR%\jmods\
XCOPY jmods\* %INSTALL_DIR%\jmods\ /s /i /y
if errorlevel 1 exit 1

if not exist "%INSTALL_DIR%\legal\" mkdir %INSTALL_DIR%\legal\
XCOPY legal\* %INSTALL_DIR%\legal\ /s /i /y
if errorlevel 1 exit 1

:: "Wannabe symlink" java binaries (Uses Bash just for convenient globbing.)
bash -euc "build-symlink-exe.sh ${INSTALL_DIR//\\\\//}/bin/*.exe ${LIBRARY_BIN}"
if errorlevel 1 exit 1

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d MKDIR %PREFIX%\etc\conda\%%F.d
    if errorlevel 1 exit 1
    copy %RECIPE_DIR%\scripts\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    :: We also copy .sh scripts to be able to use them
    :: with POSIX CLI on Windows.
    copy %RECIPE_DIR%\scripts\%%F-win.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
    :: Additionally copy .ps1 scripts to work with
    :: Windows PowerShell
    copy %RECIPE_DIR%\scripts\%%F.ps1 %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.ps1
    if errorlevel 1 exit 1
)
