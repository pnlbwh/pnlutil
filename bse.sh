#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}
source "$SCRIPTDIR/util.sh"

usage () {
echo -e "
Extracts the baseline of a DWI.  Assumes the gradient
directions comprise the last (slowest index) axis.

Usage:
        
    ${0##*/} <dwi> <out>

where <dwi> must be a nrrd volume."
}

dwimask=""
while getopts "hm:" flag; do
    case "$flag" in
        h) usage 1;;
        m) dwimask=$OPTARG;;
    esac
done
shift $((OPTIND-1))
read -r dwi out <<<"$@"

regex="DWMRI_gradient_\([0-9]*\):= *0\(\.0*\)\{0,1\} 0\(\.0*\)\{0,1\} 0\(\.0*\)\{0,1\}"
dir=$(unu head $dwi | sed -n "s|$regex|\1|p" | head -n 1)
log "Found baseline at gradient direction '$dir'"
if [ -n "$dwimask" ]; then
    run "unu slice -a 3 -p $dir -i $dwi | unu 3op ifelse -w 1 $dwimask - 0 -o $out"
else
    run unu slice -a 3 -p $dir -i "$dir" -o "$out"
fi
