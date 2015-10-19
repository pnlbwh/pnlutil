#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}
source "$SCRIPTDIR/util.sh"

usage () {
echo -e "
Extracts the baseline of a DWI.  Assumes the gradient
directions comprise the last (slowest index) axis.

Usage:
        
    ${0##*/} [-m <dwimask>] <dwi> <out>

    where <dwi> must be a nrrd volume (nrrd/nhdr). If <dwimask>
    is given then the baseline is also masked."
}

dwimask=""
[ $# -gt 0 ] || { usage; exit 1; }
while getopts "hm:" flag; do
    case "$flag" in
        h) usage 1;;
        m) dwimask=$OPTARG;;
    esac
done
shift $((OPTIND-1))
read -r dwi out <<<"$@"
checkexists dwi
[ -z "$dwimask" ] || checkexists dwimask

regex="DWMRI_gradient_0*\([0-9]*\):=  *0\(\.0*\)\{0,1\}  *0\(\.0*\)\{0,1\}  *0\(\.0*\)\{0,1\}"
direction=$(unu head $dwi | sed -n "s|$regex|\1|p" | head -n 1)
log "Found baseline at gradient direction '$direction'"
if [ -n "$dwimask" ]; then
    run "unu slice -a 3 -p $direction -i $dwi | unu 3op ifelse -w 1 $dwimask - 0 | unu save -e gzip -f nrrd -o $out"
else
    run "unu slice -a 3 -p $direction -i "$dwi" | unu save -e gzip -f nrrd -o "$out""
fi

log_success "Made $out'"
