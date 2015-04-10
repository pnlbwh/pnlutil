#!/bin/bash -eu

source util.sh

case=01010
source $threet/SetUpData.sh
verify $t1 b3414e6fd18eec3440c3fd73308cf0f7
verify $t1align 2d9e31d707421c024bccb19df1e56708
d=warp && mkdir -p $d
run ../warp.sh -x -r $t1 $t1align $d/rigid.nrrd 
verify $d/rigid.nrrd e2ca83b715611cf6ce247f569e18863b
run ../warp.sh -x $t1 $t1align $d/warped.nrrd 
verify $d/warped.nrrd 36785119c152442c04bd8f4c0db9888b
