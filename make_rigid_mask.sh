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

tmpmoving=$(mktemp -d)/$(base $moving).nrrd
run $SCRIPTDIR/center.py -i $moving -o $tmpmoving
tmpfixed=$(mktemp -d)/$(base $fixed).nrrd
run $SCRIPTDIR/center.py -i $fixed -o $tmpfixed

transform="$(base $moving)-to-$(base $fixed)-rigid.txt"
run $SCRIPTDIR/rigid.sh $tmpmoving $tmpfixed $transform
run $(antspath antsApplyTransforms) -d 3 -i $labelmap -r $tmpfixed -n NearestNeighbor -t $transform -o $out
