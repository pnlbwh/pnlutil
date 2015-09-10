#!/bin/bash -eu

source ../../scripts-pipeline/util.sh 

function verify() {
if md5sum $1 | cut -d' ' -f1 | diff - <(echo $2); then
    log_success "$1 PASS"
else
    log_error "$1 FAIL"
    return 1
fi
}
redo clean
export ANTSPATH=/projects/schiz/software/ANTS-git-build/bin/
case=01010 && source $threet/SetUpData.sh
dwiednrrd=/projects/schiz/3Tdata/case01010/diff/01010-dwi-Ed.nrrd
verify $dwiednrrd 27efed220e8f131d67ccddd88f3ade4b
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
verify $t2 94596b5c1564cd18dbb1dd822feb77be
verify $origmask e39852262e15a684b9174314e167acce
SCRIPT=../../scripts-pipeline/epi.sh
redo-ifchange $SCRIPT ../../scripts-pipeline/antsApplyTransformsDWI.sh 
run $SCRIPT $dwiednrrd $dwiedmask $t2 $origmask dwiepi.nrrd
verify dwiepi.nrrd 6d8dea6c5014de216ee9451b40cf3340
