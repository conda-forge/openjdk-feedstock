@echo off
rem First, back up the JAVA_HOME variable if it is set.
rem If it's not set, use the literal string "ENV_VAR_UNSET" as a marker.

if defined JAVA_HOME (
    set "JAVA_HOME_CONDA_BACKUP=%JAVA_HOME%"
) else (
    set "JAVA_HOME_CONDA_BACKUP=ENV_VAR_UNSET"
)

rem Set JAVA_HOME to the appropriate location for this package.
set "JAVA_HOME=%CONDA_PREFIX%\Library\lib\jvm"
