#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

usage() {
    cat <<EOF
    Usage :

    mask.sh <img> <mask> <out>

    Masks <img> (including DWI's) with <mask>.
EOF
}

isdwi() {
    unu head $1 | egrep -q 'dimension.*4'
}

mask_dwi() {
    local dwi=$1
    local mask=$2
    local out=$3
    tmpdir=$(mktemp -d)
    run unu dice -i $dwi -a 3 -o $tmpdir/dwi
    for slice in $tmpdir/dwi*nrrd; do
        run unu 3op ifelse $mask $slice 0 -o ${slice%.nrrd}-masked.nrrd
    done
    run "unu join -a 3 -i $tmpdir/*-masked.nrrd | unu data - > $tmpdir/tmpdwi.raw.gz"
    run "unu head $dwi > $tmpdir/tmpdwi.nhdr"
    run "sed "s/data file.*$/data file: tmpdwi\.raw\.gz/" -i $tmpdir/tmpdwi.nhdr"
    run "unu save -e gzip -f nrrd -i $tmpdir/tmpdwi.nhdr -o $out"
    run rm -rf $tmpdir
}

[ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && { usage; exit 0; }
[ $# -lt 3 ]  && { usage >&2; exit 1; }

img=$1
mask=$2
out=$3

tmp=$(mktemp -d)
tmpimg=$tmp/$(base $img).nrrd
tmpmask=$tmp/$(base $mask).nrrd
tmpout=$tmp/$(base $out).nrrd

ConvertBetweenFileFormats "$img" "$tmpimg"
ConvertBetweenFileFormats "$mask" "$tmpmask"

if isdwi $tmpimg; then
    mask_dwi $tmpimg $tmpmask $tmpout
else
    run "unu 3op ifelse $tmpmask $tmpimg 0 -w 1 | unu save -e gzip -f nrrd -o $tmpout"
fi

ConvertBetweenFileFormats "$tmpout" "$out"
log_success "Made $out"
