# First backup the varialbles if they are set.
# The variables are allowed to be empty (Null).
# Then set the variables to the location of this package.
# The deactivate script restores the backed up variables.

if [ "${JAVA_HOME+x}" ] ; then
  export JAVA_HOME_CONDA_BACKUP="${JAVA_HOME}"
fi
export JAVA_HOME="${CONDA_PREFIX}/lib/jvm"

if [ "${JAVA_LD_LIBRARY_PATH+x}" ] ; then
  export JAVA_LD_LIBRARY_PATH_BACKUP="${JAVA_LD_LIBRARY_PATH}"
fi
export JAVA_LD_LIBRARY_PATH="${JAVA_HOME}/lib/server"
