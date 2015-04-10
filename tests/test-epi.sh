#!/bin/bash -eu

source util.sh

case=01010
source $threet/SetUpData.sh
verify $dwied 8687e26d3cd24c0a016cef1f8908a8f1
verify $dwiedmask 60e63b09e4a674bb9b9fc51dbaf2b153
verify $t2masked 619f98c464cff30098ba03e193d9ff01
d=epi && mkdir -p $d
run epi.sh -d $dwied $dwiedmask $t2masked $d/dwiepi.nrrd
verify $d/dwiepi.nrrd 27efed220e8f131d67ccddd88f3ade4b
