#!/bin/bash -eu

source SetUpData.sh

redo-ifchange ../warp.sh ../fs2dwi_T2.sh

verify $(which ConvertBetweenFileFormats) 7784ba3f1d0f74d2c37d1ceb8a08bbd2
verify $dwied 8687e26d3cd24c0a016cef1f8908a8f1
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
verify $t2 94596b5c1564cd18dbb1dd822feb77be
verify $origmask e39852262e15a684b9174314e167acce
verify $t1align 2d9e31d707421c024bccb19df1e56708
verify $alignmask 3bead4ca05eaf45c5e589ca38deb07a8

out=$output/fs2dwi_T2 && rm -rf $out || true
run ../fs2dwi_T2.sh $fs/mri $dwied $dwiedmask $t2 $origmask $t1align $alignmask $out
verify $out/wmparc-in-bse.nrrd 4e0ff77364410c839a572f8cecb7b849

