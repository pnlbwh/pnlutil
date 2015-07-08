#!/bin/bash -eu

source SetUpData.sh
source ../util.sh
source ./util.sh
outdir="out" && mkdir -p $outdir

SCRIPT=../scripts-pipeline/bse.sh
redo-ifchange $SCRIPT

verify $dwied 8687e26d3cd24c0a016cef1f8908a8f1
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
out=$outdir/bse.nrrd 

run $SCRIPT -m $dwimask $dwi $out
#verify $out 4d2d34a7c69cfa6df315c80d35a8e98b
verify $out 93a1ba4aaa1e0d43d7b746765754e029
