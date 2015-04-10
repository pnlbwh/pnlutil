#!/bin/bash -eu

source util.sh

export FREESURFER_HOME=/projects/schiz/ra/eli/freesurfer5.3
export ANTSPATH=/projects/schiz/software/ANTS-git-build2/bin/
export ANTSSRC=/projects/schiz/software/ANTS-git/
case=01010
source $threet/SetUpData.sh

out=fs2dwi_T2
rm -rf $out || true
../fs2dwi_T2.sh $fs/mri $dwied $dwiedmask $t2 $origmask $t1align $alignmask $out
verify $out/wmparc-in-bse.nrrd 4e0ff77364410c839a572f8cecb7b849
