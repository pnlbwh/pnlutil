#!/usr/bin/env bash

set -eu

HELP_TEXT="Usage:
        
    $(basename $0) <CASELIST> <filepattern1> <filepattern2> ... <filepatternN>

Prints a summary of which files exist (e.g. generated) and which ones remain to
be computed for each case in the <CASELIST> text file.
"

usage() {
    retcode=${1:-0}
    echo -e "${HELP_TEXT}";
    exit $retcode;
}

completed() {
    local case=$1 && shift
    local filepatterns="$@"
    for filepattern in $filepatterns; do
        [ ! -f ${filepattern/\$case/$case} ] && return 1
    done
    return 0
}

ratio_percent() {
    echo "scale=1; ($1 * 100)/$2" | bc
}


[ -n "${1-}" ] && [[ $1 == '-h' || $1 == '--help' ]] && usage 0
[ $# -lt 2 ] && usage 1
caselist=$1 && [ -f "$caselist" ] || { echo "'$caselist' doesn't exist"; usage 1; }
shift && filepatterns="$@"

num_completed=0
printf "%-10s %-20s\n" Case Status
while read case; do
    if completed $case $filepatterns; then 
        num_completed=$((num_completed+1))
        printf "%-10s done\n" $case
    else
        printf "%-10s incomplete\n" $case
    fi
done < $caselist

total=$(wc -l < $caselist)
echo -e "\nProgress:"
printf "%i/%s (%s%%)\n" $num_completed $total $(ratio_percent $num_completed $total)
