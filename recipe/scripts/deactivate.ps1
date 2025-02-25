<#
First check whether backup variable(s) is/are set.
Variables are allowed to be set empty (indicates unset).
If a backup variable is set, restore it and then unset the backup.
#>

<#
NB: if a backup is set to the literal "ENV_VAR_UNSET", that indicates we must
unset the corresponding variable. This distinguishes cases where the activate
script ran but the variable was unset from cases where the activate script has
not run.
#>

if ($env:JAVA_HOME_CONDA_BACKUP) {
    if ($env:JAVA_HOME_CONDA_BACKUP -eq "ENV_VAR_UNSET") {
        $Env:JAVA_HOME = ""
    } else {
        $Env:JAVA_HOME = "$env:JAVA_HOME_CONDA_BACKUP"
    }
    $Env:JAVA_HOME_CONDA_BACKUP = ""
}
