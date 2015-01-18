#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p "$0"))
PNLUTIL=$(dirname $SCRIPT)
source "$PNLUTIL/util.sh"

HELP="
Applies a transformation to a dwi, with the option of masking
first.

Usage:

    $(basename $0) <dwi> [dwimask] <warp> <out>
"

[[ $# -lt 3 || $1 == -h* || $1 == --h* ]] && usage 1
if [ $# -eq 3 ]; then 
    read -r dwi warp out <<< "$@"
    dwimask=""
else
    read -r dwi dwimask warp out <<< "$@"
fi

tmp=$(mktemp -d)
pre="$tmp/$(base "$dwi")"

run "unu convert -t int16 -i "$dwi" | unu dice -a 3 -o $pre"
for slice in $pre*.nrrd; do 
    [ -n "$dwimask" ] && unu 3op ifelse $dwimask $slice 0 -o $slice
    warpslice=${slice%.nrrd}-warped.nrrd
    run $ANTSPATH/WarpImageMultiTransform 3 "$slice" "$warpslice" -R "$slice" "$warp"
    run unu convert -t int16 -i $warpslice -o $warpslice
done
run "unu join -a 3 -i $tmp/*-warped.nrrd | unu data - > $tmp/tmpdwi.raw.gz"
echo "Joining"
ls -1 $tmp/*-warped.nrrd
run "unu head "$dwi" > $tmp/tmpdwi.nhdr"
run sed \"s/data file.*$/data file: tmpdwi\.raw\.gz/\" -i $tmp/tmpdwi.nhdr
run unu save -e gzip -f nrrd -i $tmp/tmpdwi.nhdr -o "$out"
log_success "Made $out"
rm -rf $tmp
