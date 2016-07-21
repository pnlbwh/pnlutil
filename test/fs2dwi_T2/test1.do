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
export ANTSSRC=/projects/schiz/software/ANTS-git/
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
dirOut=fsindwi1

rm -rf $dirOut || true
echo "PATH=$PATH"
run $SCRIPT --mri $fs --dwi $dwied --dwimask $dwiedmask --t2 $t2 --t1 $t1align --t1mask $alignmask -o $dirOut
verify $dirOut/wmparc-in-bse.nrrd 95eefebd155669e551814fd5afa6dd97
