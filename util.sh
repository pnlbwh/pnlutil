#!/usr/bin/env bash
#--------------------------------------------------------------------------------------------------
# log4bash - Makes logging in Bash scripting suck less
# Copyright (c) Fred Palmer
# Licensed under the MIT license
# http://github.com/fredpalmer/log4bash
#--------------------------------------------------------------------------------------------------
set -e  # Fail on first error

# Useful global variables that users may wish to reference
SCRIPT_ARGS="$@"
SCRIPT_NAME="$0"
SCRIPT_NAME="${SCRIPT_NAME#\./}"
SCRIPT_NAME="${SCRIPT_NAME##/*/}"
SCRIPT_BASE_DIR="$(cd "$( dirname "$0")" && pwd )"

# This should probably be the right way - didn't have time to experiment though
# declare -r INTERACTIVE_MODE="$([ tty --silent ] && echo on || echo off)"
#declare -r INTERACTIVE_MODE=$([ "$(uname)" == "Darwin" ] && echo "on" || echo "off")
declare -r INTERACTIVE_MODE="on"

#--------------------------------------------------------------------------------------------------
# Begin Help Section

HELP_TEXT=""

# This function is called in the event of an error.
# Scripts which source this script may override by defining their own "usage" function
usage() {
    retcode=${1:-0}
    echo -e "${HELP_TEXT}";
    exit $retcode;
}

# End Help Section
#--------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------
# Begin Logging Section
if [[ "${INTERACTIVE_MODE}" == "off" ]]
then
    # Then we don't care about log colors
    declare -r LOG_DEFAULT_COLOR=""
    declare -r LOG_ERROR_COLOR=""
    declare -r LOG_INFO_COLOR=""
    declare -r LOG_SUCCESS_COLOR=""
    declare -r LOG_WARN_COLOR=""
    declare -r LOG_DEBUG_COLOR=""
else
    declare -r LOG_DEFAULT_COLOR="\033[0m"
    declare -r LOG_ERROR_COLOR="\033[1;31m"
    declare -r LOG_INFO_COLOR="\033[1m"
    declare -r LOG_SUCCESS_COLOR="\033[1;32m"
    declare -r LOG_WARN_COLOR="\033[1;33m"
    declare -r LOG_DEBUG_COLOR="\033[1;34m"
fi

# This function scrubs the output of any control characters used in colorized output
# It's designed to be piped through with text that needs scrubbing.  The scrubbed
# text will come out the other side!
prepare_log_for_nonterminal() {
    # Essentially this strips all the control characters for log colors
    sed "s/[[:cntrl:]]\[[0-9;]*m//g"
}

log() {
    local log_text="$1"
    local log_level="${2:-"INFO"}"
    local log_color="${3:-"$LOG_INFO_COLOR"}"

    echo -e "${log_color}[$(date +"%Y-%m-%d %H:%M:%S %Z")] [${log_level}] [$SCRIPT_NAME] ${log_text} ${LOG_DEFAULT_COLOR}" >&2;
    return 0;
}

log_info()      { log "$@"; }

log_speak()     {
    if type -P say >/dev/null
    then
        local easier_to_say="$1";
        case "${easier_to_say}" in
            studionowdev*)
                easier_to_say="studio now dev ${easier_to_say#studionowdev}";
                ;;
            studionow*)
                easier_to_say="studio now ${easier_to_say#studionow}";
                ;;
        esac
        say "${easier_to_say}";
    fi
    return 0;
}

log_success()   { log "$1" "SUCCESS" "${LOG_SUCCESS_COLOR}"; }
log_error()     { log "$1" "ERROR" "${LOG_ERROR_COLOR}"; log_speak "$1"; }
log_warning()   { log "$1" "WARNING" "${LOG_WARN_COLOR}"; }
log_debug()     { log "$1" "DEBUG" "${LOG_DEBUG_COLOR}"; }
log_captains()  {
    if type -P figlet >/dev/null;
    then
        figlet -f computer -w 120 "$1";
    else
        log "$1";
    fi
    
    log_speak "$1";

    return 0;
}

run() {
    log "$*"
    eval "$@"
}


# ------------------------------------------
# Helper functions

base() {
    filename=$(basename $1)
    echo ${filename%.*}
}

readconfig() {
    local var=$1
    local config=$2
    local firstline
    read firstline < $config && [ -n "$firstline" ] || { log_error "Error getting path from $config, see README.md"; exit 1; }
    eval "$var="$firstline""
}

readconfigcase() {
    local var=$1
    local config=$2
    local case=$3
    local pattern
    readconfig pattern $config
    filename=$(cd $(dirname $config) && readlink -f ${pattern/\$case/$case})
    eval "$var=$filename"
}

antspath() {
    ANTSCONFIG="$SCRIPT_DIR/../config/ANTS"
    if [ -f "$ANTSCONFIG" ]; then
        readconfig retvalue "$ANTSCONFIG"
        retvalue="$retvalue/bin/$1"
    else
        retvalue=$(type -P $1)
    fi
    echo $retvalue
}
