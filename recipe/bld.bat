setlocal EnableDelayedExpansion

move bin\* %LIBRARY_BIN%
if errorlevel 1 exit 1

move include\* %LIBRARY_INC%
if errorlevel 1 exit 1

move include\win32 %LIBRARY_INC%\win32
if errorlevel 1 exit 1

move jre %LIBRARY_PREFIX%\jre
if errorlevel 1 exit 1

move lib\* %LIBRARY_LIB%
if errorlevel 1 exit 1

move src.zip %LIBRARY_PREFIX%\jre\src.zip
if errorlevel 1 exit 1

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    if not exist %PREFIX%\etc\conda\%%F.d MKDIR %PREFIX%\etc\conda\%%F.d
    if errorlevel 1 exit 1
    copy %RECIPE_DIR%\scripts\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
    if errorlevel 1 exit 1
)
