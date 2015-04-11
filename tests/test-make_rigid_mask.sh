#!/bin/bash -eu

source util.sh

case=003_GNX_007
source $intrust/SetUpData.sh
export ANTSPATH=/projects/schiz/software/ANTS-git-build2/bin/

verify $t1raw 1c4454df7605e94879225c4867fabe5c
verify $t1alignmask 00ae1b96a67c00c1e4f1b682dbe23859
verify $t1align 9632de486db4e7e7a09b68a67b322873
verify $t1rawmask 5cb72388770f33d573f77f5bfc3b6045

d=make_rigid_mask && mkdir -p $d
../make_rigid_mask.sh $t1alignmask $t1align $t1raw $d/rigidmask.nrrd
verify $d/rigidmask.nrrd f1d6d42f4869da701db10b6e61889ccd
