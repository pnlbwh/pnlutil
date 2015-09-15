#!/bin/bash -eu

case=01011
source $threet/SetUpData.sh

function verify() {
if md5sum $1 | cut -d' ' -f1 | diff - <(echo $2); then
    echo "$1 PASS"
else
    echo "$1 FAIL"
    return 1
fi
}

verify $t1 c1a0cf7373ba930988442c8492054e11
#redo clean
../../pipeline/trainingdata/mktrainingfiles.sh  # makes t1s.txt and masks.txt
atlas_target=$t1
atlas_trainingstructs=t1s.txt
atlas_traininglabels=masks.txt
maskOut=t1mask.nrrd
mainANTSAtlasWeightedOutputProbability "$atlas_target" "$maskOut" "$atlas_trainingstructs" "$atlas_traininglabels"
unu 2op gt $maskOut 50 | unu save -e gzip -f nrrd -o $maskOut
