#!/bin/bash -eu

source SetUpData.sh
source ../util.sh

redo-ifchange ../bse.sh

verify $dwied 8687e26d3cd24c0a016cef1f8908a8f1
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
out=$output/bse.nrrd 

run ../bse.sh -m $dwimask $dwi $out
verify $out 4d2d34a7c69cfa6df315c80d35a8e98b 
