#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}
source "$SCRIPTDIR/util.sh"

usage() {
echo -e "Usage:

    mask.sh <img> <mask> <out>

Masks <img> (including DWI's) with <mask>.
"
}

isdwi() {
    unu head $1 | egrep -q 'dimension.*4'
}

[ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && { usage; exit 1; }
[ "$#" -ne 3 ] && { usage; exit 1; }
read -r img mask out <<<"$@"

if [[ $img == *.nhdr || $img == *.nrrd ]] && isdwi $img; then
    run "unu 3op ifelse -w 1 $mask $img 0 | unu save -e gzip -f nrrd -o $out"
    log_success "Made '$out'"
    exit 0
fi

tmp=$(mktemp -d)
tmpimg=$tmp/${img##*/}.nrrd
tmpmask=$tmp/${mask##*/}.nrrd
tmpout=$tmp/${out##*/}.nrrd

run ConvertBetweenFileFormats "$img" "$tmpimg" >/dev/null
run ConvertBetweenFileFormats "$mask" "$tmpmask" >/dev/null
run "unu 3op ifelse -w 1 $tmpmask $tmpimg 0 | unu save -e gzip -f nrrd -o $tmpout"
run ConvertBetweenFileFormats "$tmpout" "$out" >/dev/null
log_success "Made '$out'"
