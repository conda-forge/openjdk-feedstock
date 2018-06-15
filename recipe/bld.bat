setlocal EnableDelayedExpansion

MOVE bin\* %LIBRARY_BIN%
MOVE include\* %LIBRARY_INC%
MOVE jre %LIBRARY_PREFIX%\jre
MOVE lib\* %LIBRARY_LIB%
MOVE src.zip %LIBRARY_PREFIX%\jre\src.zip

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
FOR %%F IN (activate deactivate) DO (
    IF NOT EXIST %PREFIX%\etc\conda\%%F.d MKDIR %PREFIX%\etc\conda\%%F.d
    COPY %RECIPE_DIR%\scripts\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
)
