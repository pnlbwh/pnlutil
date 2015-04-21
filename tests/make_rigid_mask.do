#!/bin/bash -eu

source SetUpData.sh

read -r t1align_md5 t1align <<< "e785ea85135687e842ed95ba69d4df99  ../pipeline-trainingdata/017_NA3_025-t1w-realign.nrrd"
read -r t1align2_md5 t1align2 <<< "6f6aeb75e73a6884b3fd7325fe49a099  ../pipeline-trainingdata/017_NAA_010-t1w-realign.nrrd"
read -r t1alignmask_md5 t1alignmask <<< "eb2423e13476d645c4363a39c34b3f19  ../pipeline-trainingdata/017_NA3_025.atlasmask.thresh50.edited.nrrd"
read -r out_md5 out <<< "58a88e5cb56a38db3d14b2237d284415  $output/rigidmask.nrrd"

verify $t1align $t1align_md5
verify $t1align2 $t1align2_md5
verify $t1alignmask $t1alignmask_md5
verify $(which ConvertBetweenFileFormats) 7784ba3f1d0f74d2c37d1ceb8a08bbd2

redo-ifchange ../make_rigid_mask.sh ../center.py ../rigid ../rigidtransform

run ../make_rigid_mask.sh $t1alignmask $t1align $t1align2 $output/rigidmask.nrrd
verify $out $out_md5
test -f $output/rigidmask.nrrd.log
