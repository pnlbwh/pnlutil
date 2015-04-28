#!/bin/bash -e

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}      
source $SCRIPTDIR/util.sh

HELP="
For each case, loads <var1> .. <varN> file paths into Slicer.  Run in directory
with 'SetUpData.sh' that has '<var>=/path/to/\$case-file' defined for each
<var>.  The set of cases must either be defined in SetUpData.sh (e.g. as
caselist=mycaselist.txt or cases=\"case1 case2..  caseN\"), or on the
commandline (see below).

    ${0##*/} [-f <caselist>, -l \"<case1> .. <caseN>\"] <var1> .. <varN> 

-f <caselist>             Uses case id's from <caselist> (one per line, but can include comments)
-l \"<case1> .. <caseN>\"   List case id's within quotes

Examples:
    ${0##*/} -f caseslist_notchecked.txt t1raw t2raw dwiraw
    ${0##*/} t1align t1alignmask dwi fsindwi  # operate on the caselist file defined by '\$caselist' in SetUpData.sh
    ${0##*/} -l \"01009 01010\" t2 t2atlasmask
"

parseargs() {
    while getopts "hsr:f:l:" flag; do
        case "$flag" in
            h) usage 1;;
            r) reference_vars=$OPTARG;;
            f) argcaselist=$OPTARG;;
            l) argcases=$OPTARG;;
        esac
    done
    shift $((OPTIND-1))

    # get positional arguments
    IFS=" " read vars <<<"$@"
    [ -n "${vars-}" ] || { echo -e "Specify variables <var>..<varN>"; usage 1; }

    # check input is ok
    case=000 && setupvars $vars
    [ ! -n "${argcaselist-}" ] || caselist=$argcaselist
    [ ! -n "${argcases-}" ] || cases=$argcases
    setupcases
}

parseargs "$@"

# Set path to Slicer
if [ -e "$SCRIPTDIR/config.sh" ]; then
    source $SCRIPTDIR/config.sh
else
    slicer=Slicer
fi

#add_to_caselist() {
    #local _case=$1
    #local _caselist=$2
    #if [ ! -e "$_caselist" ] || ! grep -q "$_case" $_caselist; then 
        #echo $_case >> $_caselist; 
        #echo -e "\nAdded '$_case' to '$_caselist'"
    #else
        #echo -e "\n'$_case' already in '$_caselist', so doing nothing"
    #fi 
#}

for case in $cases; do
    echo -e "\n== $case =="
    source "SetUpData.sh"
    paths=""
    vars_exist=""
    skipcase=false
    for var in $vars; do
        if [ -e "${!var}" ]; then
            echo "Found '$var: ${!var}'"
            paths="$paths ${!var}"
            vars_exist="$vars_exist $var"
        else
            echo "Not found '$var: ${!var}'"
            [ ! -f "${!var/nrrd/qc.nrrd}" ] || { echo "Already QC'ed (passed)"; }
            [ ! -f "${!var/nrrd/qcfail.nrrd}" ] || { echo "Already QC'ed (failed)"; }
            echo "Skipping this case"
            skipcase=true
        fi
    done
    $skipcase && continue
    if [ -n "$paths" ]; then
        log "Loading file paths for '${vars_exist# *}'"
        sliceropts="--disable-cli-modules --disable-scripted-loadable-modules" 
        run $slicer $sliceropts "$paths"
        for var in $vars_exist; do
            if [[ $reference_vars == *$var* ]]; then
                continue
            fi
            #caselist_qcpass=caselist_qcpass_${var}
            #caselist_qcfail=caselist_qcfail_${var}
            prompt="
Did '$var: ${!var}' pass
[p]ass) make ${!var/nrrd/qc.nrrd}
[f]ail) make ${!var/nrrd/qcfail.nrrd}
[s]kip) 
[q]uit) 
? "
            read -r -n 1 -p "$prompt" response
            case $response in
                [pP]) echo; $SCRIPTDIR/qcaccept ${!var}; continue;;
                [fF]) echo; $SCRIPTDIR/qcreject ${!var}; continue;;
                [sS]) continue;;
                [qQ]) echo; exit;;
            esac
        done
    else
        echo "No files to load for case '$case'"
    fi
done
