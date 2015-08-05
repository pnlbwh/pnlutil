#!/bin/bash -eu

source ../../util.sh

function verify() {
    if md5sum $1 | cut -d' ' -f1 | diff - <(echo $2); then
        log_success "$1 PASS"
    else
        log_error "$1 FAIL"
        return 1
    fi
}

case=01010 && source $threet/SetUpData.sh
export ANTSPATH=/projects/schiz/software/ANTS-git-build/bin/
export ANTSSRC=/projects/schiz/software/ANTS-git-build/bin/
export PATH=/bin:/usr/bin:/usr/sbin:/projects/pnl/software/NEP/bin:/projects/schiz/software/redo-mildred/
SCRIPT=../../scripts-pipeline/fs2dwi_T2.sh
DEPS="../../scripts-pipeline/warp.sh\
    ../.././scripts-pipeline/mask\
    ../../scripts-pipeline/bse.sh\
    "
redo-ifchange $SCRIPT $DEPS
#verify $(which ConvertBetweenFileFormats) 7784ba3f1d0f74d2c37d1ceb8a08bbd2
verify $dwied 8687e26d3cd24c0a016cef1f8908a8f1
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
verify $t2 94596b5c1564cd18dbb1dd822feb77be
verify $origmask e39852262e15a684b9174314e167acce
verify $t1align 2d9e31d707421c024bccb19df1e56708
verify $alignmask 3bead4ca05eaf45c5e589ca38deb07a8

rm -rf fsindwi || true
echo "PATH=$PATH"
run $SCRIPT $fs/mri $dwied $dwiedmask $t2 $origmask $t1align $alignmask fsindwi
verify fsindwi/wmparc-in-bse.nrrd dd291fbe3728f311e23e4adb8e7f8f84
#verify fsindwi/wmparc-in-bse.nrrd 64c8d74111997484bfe2e15b7466de78
#verify fsindwi/wmparc-in-bse-1mm.nrrd e40500603b23f101382cca74cbcb9ecc
