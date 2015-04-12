#!/bin/bash -eu

source SetUpData.sh

redo-ifchange ../warp.sh

verify $t1 b3414e6fd18eec3440c3fd73308cf0f7
verify $t1align 2d9e31d707421c024bccb19df1e56708

run ../warp.sh -x -r $t1 $t1align $output/rigid.nrrd 
verify $output/rigid.nrrd e2ca83b715611cf6ce247f569e18863b

run ../warp.sh -x $t1 $t1align $output/warped.nrrd 
verify $output/warped.nrrd 36785119c152442c04bd8f4c0db9888b
