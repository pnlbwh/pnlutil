#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# -----------------------------------------------------------------
## T2 mask generation
# Input
t2mabs_target=\$t2  # make sure you define t1 above
t2mabs_trainingcsv=trainingDataT2Masks.csv
# Output
t2mabs=\$case/strct/\$case.t2mabs.nrrd
# -----------------------------------------------------------------
"
doscript="default.t2mabs.nrrd.do"
var=t2mabs

source $SCRIPTDIR/add.sh
$SCRIPTDIR/trainingDataT2Masks/mktrainingcsv.sh "$dirProj"
