#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# --------------------------------------------------------------------------
# DWI BET mask
# Inputs:
dwibetmask_dwi=\$dwied
# Output
dwibetmask=\$diff/\$case.dwibetmask.nrrd  
# --------------------------------------------------------------------------
"
doscript="default.dwibetmask.nrrd.do"

var="dwibetmask"
source $SCRIPTDIR/add.sh
