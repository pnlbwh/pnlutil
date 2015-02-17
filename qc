#!/bin/bash -e

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}      
source $SCRIPTDIR/util.sh

HELP="
For each case, loads <var1> .. <varN> file paths into Slicer.
Run in directory with 'SetUpData.sh' that has '<var>=/path/to/\$case-file'
defined in it.  The set of cases must either be defined in SetUpData.sh (e.g.
as caselist=mycaselist.txt or cases=\"case1 case2.. caseN\"), or on the
commandline (see below).

    ${0##*/} [-f <caselist>] <var1> .. <varN> 

-f <caselist>           Uses case id's from <caselist> (one per line, but can include comments)

Examples:
    ${0##*/} -f caseslist_notchecked.txt t1raw t2raw dwiraw
    ${0##*/} t1align t1alignmask dwi fsindwi
"

parseargs() {
    selectcases=false
    while getopts "hf:l:" flag; do
        case "$flag" in
            h) usage 1;;
            f) argcaselist=$OPTARG;;
            l) argcases=$OPTARG;;
        esac
    done
    shift $((OPTIND-1))

    # get positional arguments
    IFS=" " read vars <<<"$@"
    [ -n "${vars-}" ] || { echo -e "Specify variables <var>..<varN>"; usage 1; }

    # check input is ok
    checkset_SetUpData $vars
    [ ! -n "${argcaselist-}" ] || caselist=$argcaselist
    [ ! -n "${argcases-}" ] || cases=$argcases
    checkset_cases
}

parseargs "$@"

# Set path to Slicer
if [ -e "$SCRIPTDIR/config.sh" ]; then
    source $SCRIPTDIR/config.sh
else
    slicer=Slicer
fi

for case in $cases; do
    echo -e "\n== $case =="
    source "$SetUpData"
    paths=""
    vars_exist=""
    for var in $vars; do
        if [ -e "${!var}" ]; then
            echo "Found '$var: ${!var}'"
            paths="$paths ${!var}"
            vars_exist="$vars_exist $var"
        else
            echo "Not found '$var: ${!var}' (skipping)"
        fi
    done
    if [ -n "$paths" ]; then
        log "Loading file paths for '${vars_exist# *}'"
        run $slicer "$paths"
        for var in $vars_exist; do
            caselist_qc=caselist_qcpass_${var}
            echo "Did '$var: ${!var}' pass?"
            select yn in "Yes" "No"; do
                case $yn in
                    Yes ) 
                        if [ ! -e "$caselist_qc" ] || ! grep -q "$case" $caselist_qc; then 
                            echo $case >> $caselist_qc; 
                        fi 
                        break;;
                    No ) break;;
                esac
            done
        done
    else
        echo "No files to load for case '$case'"
    fi
done
