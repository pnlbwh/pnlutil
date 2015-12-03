#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# -----------------------------------------------------------------
## Freesurfer
# Input
FREESURFER_HOME=path/to/freesurfer 
fs_t1=\$case/\$case-t1.nrrd 
fs_mask=\$case/\$case-t1mask.nrrd  # optional
# Output
fs=\$case/strct/\$case.freesurfer
# -----------------------------------------------------------------"
doscript="default.freesurfer.do"
scripts=fs

source $SCRIPTDIR/add.sh
