#!/bin/bash -eu

function verify() {
if md5sum $1 | cut -d' ' -f1 | diff - <(echo $2); then
    echo "$1 PASS"
else
    echo "$1 FAIL"
    return 1
fi
}

mkdir _data || true
case=003_GNX_007 && source $intrust/SetUpData.sh
./dwiPipeline-nofilt.py $dwied _data/dwied-flirt.nrrd
#./dwiPipeline-ants.py $dwied dwied.nrrd
