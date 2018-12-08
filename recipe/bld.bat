setlocal EnableDelayedExpansion

XCOPY bin\* %LIBRARY_BIN% /s /i /y
if errorlevel 1 exit 1

XCOPY include\* %LIBRARY_INC% /s /i /y
if errorlevel 1 exit 1

XCOPY lib\* %LIBRARY_LIB% /s /i /y
if errorlevel 1 exit 1

XCOPY DISCLAIMER %LIBRARY_PREFIX% /s /i /y
if errorlevel 1 exit 1

if not exist "%LIBRARY_PREFIX%\conf\" mkdir %LIBRARY_PREFIX%\conf\
XCOPY conf\* %LIBRARY_PREFIX%\conf\ /s /i /y
if errorlevel 1 exit 1

if not exist "%LIBRARY_PREFIX%\jmods\" mkdir %LIBRARY_PREFIX%\jmods\
XCOPY jmods\* %LIBRARY_PREFIX%\jmods\ /s /i /y
if errorlevel 1 exit 1

if not exist "%LIBRARY_PREFIX%\legal\" mkdir %LIBRARY_PREFIX%\legal\
XCOPY legal\* %LIBRARY_PREFIX%\legal\ /s /i /y
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
    if errorlevel 1 exit 1
)
