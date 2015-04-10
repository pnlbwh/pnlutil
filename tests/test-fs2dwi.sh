#!/bin/bash -eu

source util.sh

export FREESURFER_HOME=/projects/schiz/ra/eli/freesurfer5.3
export ANTSPATH=/projects/schiz/software/ANTS-git-build2/bin/
export ANTSSRC=/projects/schiz/software/ANTS-git/
case=01010
source $threet/SetUpData.sh

out=fs2dwi
rm -rf $out || true
../fs2dwi.sh $dwied $dwiedmask $fs/mri $out
verify $out/wmparc-in-bse.nrrd 64c8d74111997484bfe2e15b7466de78
verify $out/wmparc-in-bse-1mm.nrrd e40500603b23f101382cca74cbcb9ecc
