#!/bin/bash -eu

usage() {
    echo -e "
Usage:
    ${0##*/}
"
}

checksumDir() {
    pushd "$1" >/dev/null
    find . -type f -exec md5sum {} \; | sort -k 2 | md5sum | awk -v dir="$1" '{print $1 dir}'
    popd >/dev/null
}

checksumFile() {
    md5sum "$1"
    raw=${1/%.nhdr/.raw}
    if [ -e "$raw" ]; then md5sum "$raw"; fi
    if [ -e "$raw".gz ]; then md5sum "$raw".gz; fi
}

md5() {
    if [ -f "$1" ]; then  # if file
        checksumFile "$1"
    elif [ -d "$1" ]; then # if directory
        checksumDir "$1"
    fi
}

[ -f SetUpData.sh ] || { echo "Run in directory with SetUpData.sh."; usage; exit 1; }
case="dummy" && source SetUpData.sh
[ -n "${snapshot_vars-}" ] || { echo "Add snapshot_vars to SetUpData.sh"; exit 1; }

for var in $snapshot_vars; do
    for case in $(completed -c "$var"); do
        source SetUpData.sh
        f="${!var}"
        >&2 echo "checksumming $f"
        md5 "$f" | awk -v var="$var" -v case=$case -v OFS="," '{$1=$1; print case OFS var OFS $0}'
    done
done > .snapshot.csv
