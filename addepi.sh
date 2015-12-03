#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# --------------------------------------------------------------------------
# EPI
# Input
dwiepi_dwi=\$dwied
dwiepi_dwimask=\$dwimask
dwiepi_t2=\$t2raw
dwiepi_t2mask=\$t2rawmask
# Output
dwiepi=\$case/diff/\$case.dwi-epi.nrrd
# ---------------------------------------------------------------------------"
doscript="default.dwi-epi.nrrd.do"

var="dwiepi"
source $SCRIPTDIR/add.sh
