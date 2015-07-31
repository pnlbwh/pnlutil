#!/bin/bash -eu

source SetUpData.sh
source ../util.sh # for 'run'
source ./util.sh  # for 'verify'

export ANTSPATH=/projects/schiz/software/ANTS-git-build/bin/

outdir=out && mkdir -p $outdir

dwiednrrd=/projects/schiz/3Tdata/case01010/diff/01010-dwi-Ed.nrrd

verify $dwiednrrd 27efed220e8f131d67ccddd88f3ade4b
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
verify $t2masked 619f98c464cff30098ba03e193d9ff01

SCRIPT=../scripts-pipeline/epi.sh
redo-ifchange $SCRIPT ../scripts-pipeline/antsApplyTransformsDWI.sh ../scripts-pipeline/warp.sh
#run $SCRIPT -d $dwiednrrd $dwiedmask $t2masked $outdir/dwiepi.nrrd
run $SCRIPT $dwiednrrd $dwiedmask $t2 $origmask $outdir/dwiepi.nrrd
verify $outdir/dwiepi.nrrd 3141becf500f2e9ac211e1b50a3b62bd
