#!/bin/bash -eu

usage() {
    echo -e "
Usage:
    ${0##*/} <tractmeasures.csv>
"
}

[ $# -gt 0 ] && [[ $1 != -h* ]] || { usage; exit 1; }

cat $@ | grep "ioff" | cut -d, -f1,2,15
cat $@ | grep "af" | cut -d, -f1,2,15
cat $@ | grep "_slf" | cut -d, -f1,2,15
cat $@ | grep "_uf" | cut -d, -f1,2,15
