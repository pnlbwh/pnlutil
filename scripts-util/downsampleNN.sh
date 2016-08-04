#!/bin/bash -eu

SCRIPTDIR=$( cd $(dirname "$0") ; pwd -P )
source $SCRIPTDIR/loglib.sh
usage() {
echo -e "\

Usage:
    ${0##*/} -i <in> -r <ref> -o <out>
"
}


[ $# -gt 0 ] || { usage; exit 1; }
while getopts "hi:r:o:" flag; do
    case "$flag" in
        h) usage; exit 1;;
        i) in=$OPTARG;;
        r) ref=$OPTARG;;
        o) out=$OPTARG;;
    esac
done
shift $((OPTIND-1))

countwords() { echo $#; }

log "Downsample $in to resolution of $ref"
new_size=$(unu head $ref | grep "sizes:" | sed 's/sizes:\s*//')
numWords=$(countwords $new_size)
log "Reference image has dimension $numWords ($new_size)"
if [ "$numWords" -gt 3 ]; then
    log "Remove diffusion directions dimension"
    new_size=${new_size% *} # remove last dimension, the diffusion directions
fi
run "unu resample -k cheap -s $new_size -i $in | unu save -e gzip -f nrrd -o $out"
log_success "Made $out"


