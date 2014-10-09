#!/usr/bin/env bash

set -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=$(dirname $SCRIPT)
source $SCRIPTDIR/util.sh

usage() {
    echo "Usage: $(basename $SCRIPT) <moving_labelmap> <moving> <fixed> <out>"
    exit $1
}

[ $# -lt 4 ] && usage 1
[[ -n ${1-} ]] && [[ $1 == "-h" || $1 == "--help" ]] && usage 0

labelmap=$1
moving=$2
fixed=$3
out=$4

tmp=$(mktemp -d)

tmpmoving=$tmp/$(base $moving).nrrd
run $SCRIPTDIR/center.py -i $moving -o $tmpmoving

tmpfixed=$tmp/$(base $fixed).nrrd
run $SCRIPTDIR/center.py -i $fixed -o $tmpfixed

tmplabelmap=$tmp/$(base $labelmap).nrrd
run $SCRIPTDIR/center.py -i $labelmap -o $tmplabelmap

transform=$tmp/"$(base $moving)-to-$(base $fixed)-rigid.txt"

run $SCRIPTDIR/rigid.sh $tmpmoving $tmpfixed $transform

run $(antspath antsApplyTransforms) -d 3 -i $tmplabelmap -r $tmpfixed -n NearestNeighbor -t $transform -o $out
