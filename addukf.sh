#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# --------------------------------------------------------------------------
## UKF
# Input
ukf_dwi=\$case/\$case-dwi.nrrd  # edit this, if you already defined dwi make it ukf_dwi=\$dwi
ukf_dwimask=\$case/\$case-dwimask.nrrd # edit this, if you already defined dwimask make it ukf_dwimask=\$dwimask
# Output
ukf=\$case/diff/\$case.ukf_2T.vtk.gz 
# ---------------------------------------------------------------------------"
doscript="default.ukf_2T.vtk.gz.do"
var=ukf

source $SCRIPTDIR/add.sh
