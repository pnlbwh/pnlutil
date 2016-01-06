#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# -----------------------------------------------------------------
## Freesurfer to DWI registration
# Input
fsindwi_dwi=\$dwied
fsindwi_dwimask=\$dwimask
fsindwi_fssubjectdir=\$fs
fsindwi_t1=\$t1
fsindwi_t1mask=\$t1mabs
fsindwi_t2=\$t2
# Output
fsindwi=\$case/diff/\$case.fsindwi.nrrd
# -----------------------------------------------------------------"
doscript="default.fsindwi.nrrd.do"
var=fsindwi

source $SCRIPTDIR/add.sh
