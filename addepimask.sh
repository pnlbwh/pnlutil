#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# --------------------------------------------------------------------------
# EPI mask
# Input
dwiepimask_dwi=\$dwiepi
# Output
dwiepimask=\$case/diff/\$case.dwi-epi-mask.nrrd
# ---------------------------------------------------------------------------"
doscript="default.dwi-epi-mask.nrrd.do"

var="dwiepimask"
source $SCRIPTDIR/add.sh
