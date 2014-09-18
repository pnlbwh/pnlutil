#!/usr/bin/env bash

#set -eu

HELP_TEXT="Usage:
        
    $(basename $0) [-s] <CASELIST> <filepattern1> <filepattern2> ... <filepatternN>

Prints a summary of which files exist (e.g. generated) and which ones remain to
be computed for each case in the <CASELIST> text file.
"

usage() {
    retcode=${1:-0}
    echo -e "${HELP_TEXT}";
    exit $retcode;
}

test_remote() {
    local test_flag=$1
    local target=$2
    IFS=":" read -r server path <<<"$target"
    ssh -n "$server" "test $test_flag $path"
}

is_target_remote() {
    IFS=":" read -r server path <<<"$1"
    retvalue="false"
    test -n "$path"
}

completed() {
    local case=$1 && shift
    local filepatterns="$@"
    for filepattern in $filepatterns; do
        filepath=${filepattern//\$case/$case}
        test_fn="test"
        if is_target_remote "$filepath"; then 
            test_fn="test_remote"
        fi
        if ! $test_fn -e "$filepath"; then
            return 1
        fi
    done
    return 0
}

ratio_percent() {
    echo "scale=1; ($1 * 100)/$2" | bc
}

summary=false
[ -n "${1-}" ] && [[ $1 == '-h' || $1 == '--help' ]] && usage 0
[ -n "${1-}" ] && [ "$1" == "-s" ] && { summary=true; shift; }
[ $# -lt 2 ] && usage 1
caselist=$1 && [ -f "$caselist" ] || { echo "'$caselist' doesn't exist"; usage 1; }
shift && filepatterns="$@"

num_completed=0
$summary || printf "%-15s %-15s\n" Case Status
while read case; do
    if completed $case $filepatterns; then 
        num_completed=$((num_completed+1))
        $summary || printf "%-15s %-15s\n" $case "done"
    else
        $summary || printf "%-15s %-15s\n" $case "incomplete"
    fi
done < $caselist

total=$(wc -l < $caselist)
$summary || echo -e "\nProgress:"
printf "%i/%s  %s%%\n" $num_completed $total $(ratio_percent $num_completed $total)
