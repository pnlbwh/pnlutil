#!/bin/bash -eu

export ANTSPATH=/projects/schiz/software/ANTS-git-build/bin/
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
redo clean
../../scripts-pipeline/mabs.sh -t trainingData.csv -i $t1 -o $case-t1mask.nrrd
