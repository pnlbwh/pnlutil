#!/bin/bash -eu

function verify() {
if md5sum $1 | cut -d' ' -f1 | diff - <(echo $2); then
    echo "$1 PASS"
else
    echo "$1 FAIL"
    return 1
fi
}

source env.sh
verify $dwied 8687e26d3cd24c0a016cef1f8908a8f1
verify ${dwied/nhdr/raw.gz} 70feed84ac11277c785b0b8ef65da371
./dwiPipeline-ants.py $dwied dwied.nrrd
