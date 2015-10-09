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
../../trainingDataT1/mktrainingfiles.sh
rm masks.txt t1s.txt
../../scripts-pipeline/mabs.sh -t trainingDataT1.csv -i $t1 -o $case-t1mask.nrrd
