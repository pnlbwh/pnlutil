#!/usr/bin/env bash

set -e  # Fail on first error

# Useful global variables that users may wish to reference
SCRIPT_ARGS="$@"
SCRIPT_NAME="$0"
SCRIPT_NAME="${SCRIPT_NAME#\./}"
SCRIPT_NAME="${SCRIPT_NAME##/*/}"
SCRIPT_NAME_DIR="$(cd "$( dirname "$0")" && pwd )"

# declare -r INTERACTIVE_MODE="$([ tty --silent ] && echo on || echo off)"
#declare -r INTERACTIVE_MODE=$([ "$(uname)" == "Darwin" ] && echo "on" || echo "off")
declare -r INTERACTIVE_MODE="on"

#--------------------------------------------------------------------------------------------------
# Begin Help Section

HELP=""
HELP_TEXT=""

usage() {
    retcode=${1:-0}
    if [ -n "$HELP" ]; then
        echo -e "${HELP}";
    elif [ -n "$HELP_TEXT" ]; then
        echo -e "$HELP_TEXT"
    else
        echo ""
    fi
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

    if [[ $log_level == "INFO" ]]; then
        log_text_color=$LOG_WARN_COLOR
    elif [[ $log_level == "SUCCESS" ]]; then
        log_text_color=$LOG_SUCCESS_COLOR
    else
        log_text_color=$log_color
    fi
    echo -e "${LOG_INFO_COLOR}[$(date +"%Y-%m-%d %H:%M:%S %Z")] [${log_level}] [$PWD] [$SCRIPT_NAME] ${log_text_color} ${log_text} ${LOG_DEFAULT_COLOR}" >&2;
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
    if [[ $filename == *.gz ]]; then
        echo ${filename%.*.gz}
    else
        echo ${filename%.*}
    fi
}

is_target_remote() {
    IFS=":" read -r server path <<<"$1"
    test -n "$path"
}

readconfig() {
    local var=$1
    local config=$2
    read $var < $config && [ -n "$var" ] || { log_error "Error getting path from $config, see README.md"; exit 1; }
}

readconfigcase() {
    local var=$1
    local config=$2
    local case=$3
    local pattern
    readconfig pattern $config
    pathinstance=${pattern/\$case/$case}
    if is_target_remote $pathinstance; then
        mkdir -p remote_files
        rsync -arv -e ssh "$pathinstance" remote_files
        if [[ $pathinstance = *nhdr ]]; then  # if .nhdr get .raw file as well
            rsync -arv -e ssh "${pathinstance%.*}.raw.gz" remote_files
        fi
        filename=$(readlink -m remote_files/$(basename $pathinstance))
        [ ! -e $filename ] && { log_error "From '$config': Failed to get remote file '$pathinstance'"; exit 1; }
    else
        filename=$(cd $(dirname $config) && readlink -m $pathinstance)
        [ ! -e $filename ] && { log_error "From '$config': '$filename' does not exist"; exit 1; }
    fi
    eval "$var=$filename"
}

get_remotes() {
    log "Check that inputs exist and if any are remote"
    for var in "$@"; do
        IFS=":" read -r server remotepath <<<"${!var}"
        if [ -n "$remotepath" ]; then # is remote
            log "<$var> is remote, fetch '${!var}'"
            mkdir -p remote_files
            run rsync -arv -e ssh "${!var}" remote_files
            if [[ $remotepath == *nhdr ]]; then  # if .nhdr get .raw file as well
                run rsync -arv -e ssh "${!var%.*}.raw.gz" remote_files
            fi
            filename="$(readlink -m remote_files/$(basename $remotepath))"
            [ ! -e $filename ] && { log_error "$var: Failed to get remote file '${!var}'"; exit 1; }
            eval "$var="$filename""
            log_success "Uploaded remote <$var>: '$filename'"
        else
            [ ! -e ${!var} ] && { log_error "<$var>:'${!var}' does not exist"; exit 1; }
            log_success "<$var>:'${!var}' is local and exists"
        fi
    done
}

antspath() {
    ANTSCONFIG="$SCRIPT_BASE_DIR/../config/ANTS"
    if [ -f "$ANTSCONFIG" ]; then
        readconfig retvalue "$ANTSCONFIG"
        retvalue="$retvalue/bin/$1"
    else
        retvalue=$(type -P $1)
    fi
    echo $retvalue
}

check_set_vars() {
    local var
    config="$SCRIPTDIR/env.cfg"
    [ -f "$config" ] && source "$config"
    for var in "$@"; do
        if [ -z "${!var-}" ]; then 
            log_error "Set '${var}' either in your bash environment or '$SCRIPTDIR/env.cfg'"
            exit 1
        fi
    done
}

mask() {
    local img=$1
    local mask=$2
    local _out=$(basename $img)
    _out="${_out%.*}-masked.nrrd"
    run ConvertBetweenFileFormats $img $_out >/dev/null
    run "unu 3op ifelse $mask $_out 0 -w 1 | unu save -e gzip -f nrrd -o "$_out""
    run $SCRIPTDIR/center.py -i "$_out" -o "$_out"
    eval "$3="$_out""
}

rigid() {
    local moving=$1
    local fixed=$2
    local prefix=$3
    check_set_vars ANTSPATH
    run ${ANTSPATH}/ANTS 3 -m MI[$fixed,$moving,1,32] -i 0 -o $prefix --do-rigid
    # from antsaffine.sh:
    #RIGID="--rigid-affine true  --affine-gradient-descent-option  0.5x0.95x1.e-4x1.e-4"
    #run $(antspath ANTS) 3 -m MI[${fixed},${moving},1,32] -o ${pre} -i 0 --use-Histogram-Matching --number-of-affine-iterations 10000x10000x10000x10000x10000 $RIGID
    log_success "Created rigid transform: '${prefix}Affine.txt'"
}

warp() {
    local moving=$1
    local fixed=$2
    local prefix=$3
    check_set_vars ANTSSRC ANTSPATH && export ANTSPATH=$ANTSPATH
    run $ANTSSRC/Scripts/antsIntroduction.sh -d 3 -i $moving -r $fixed -o $prefix -s MI 
    log_success "Created non-linear warp: '${prefix}Affine.txt', '${prefix}Warp.nii.gz'"
}

check_args() {
    local min_args=$1
    shift
    [ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && usage 0
    [ $# -lt $min_args ] && usage 1
    return 0
}

# ---------------
# .do script helpers

assert_vars_are_set() {
    for var in "$@"; do
        [ -z "${!var-}" ] && { log_error "'$var' not set in input.cfg"; exit 1; }
    done
    return 0
}

redo_ifchange_vars() {
    log "Check/update dependencies: $*"
    assert_vars_are_set "$@"
    local local_deps=""
    for var in "$@"; do
        if [[ ${!var} == *:* ]]; then # is remote
            local server remotepath
            IFS=":" read -r server remotepath <<<"${!var}"
            log "Updating remote file: '${!var}'"
            run ssh $server "redo-ifchange "$remotepath""
        else
            eval "$var="$(readlink -m ${!var})""
            local_deps="$local_deps ${!var}"
        fi
    done
    redo-ifchange $local_deps input.cfg
    log_success "Dependencies up to date"
}

export_vars() {
    assert_vars_are_set "$@"
    for var in "$@"; do
        export $var=${!var%/}/
    done
}
