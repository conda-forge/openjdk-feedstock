@echo off
setlocal EnableDelayedExpansion
set "NEW_PATH=!PATH:%JAVA_HOME%\bin;=!"
endlocal & set "PATH=%NEW_PATH%"
set "NEW_PATH="
set "JAVA_HOME=%JAVA_HOME_CONDA_BACKUP%"
set "JAVA_HOME_CONDA_BACKUP="
