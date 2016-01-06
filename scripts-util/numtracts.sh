#!/bin/bash -eu

usage() {
    echo -e "
Usage:
    ${0##*/} <bundle_name_pattern> <tractmeasures.csv>
"
}

[ $# -eq 2 ] && [[ $1 != -h* ]] || { usage; exit 1; }

cat "$2" | grep "$1" | cut -d, -f1,2,15
