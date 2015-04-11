#!/bin/bash -eu

source util.sh

case=01010
source $threet/SetUpData.sh
verify $dwied 8687e26d3cd24c0a016cef1f8908a8f1
dwiednrrd=/projects/schiz/3Tdata/case01010/diff/01010-dwi-Ed.nrrd

verify $dwiednrrd 27efed220e8f131d67ccddd88f3ade4b
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
verify $t2masked 619f98c464cff30098ba03e193d9ff01

d=epi && mkdir -p $d

run epi.sh -d $dwiednrrd $dwiedmask $t2masked $d/dwiepi.nrrd
verify $d/dwiepi.nrrd 5c6692285a78a3f0e6cdd05dc4feecb8

#run epi.sh -d $dwied $dwiedmask $t2masked $d/dwiepi.nrrd
#verify $d/dwiepi.nrrd 27efed220e8f131d67ccddd88f3ade4b
