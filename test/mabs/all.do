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
../../scripts-pipeline/mabs.sh -t t1trainingdata.csv -i $t1 -o $case-t1mask.nrrd
# last run output had md5sum = 427c31224b05b91dece8a9c97a645bd6
