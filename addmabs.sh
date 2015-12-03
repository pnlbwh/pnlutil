#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# -----------------------------------------------------------------
## T1 mask generation
# Input
t1mabs_target=\$t1  # make sure you define t1 above
t1mabs_trainingcsv=trainingDataT1.csv
# Output
t1mabs=\$case/strct/\$case.t1mabs.nrrd
# -----------------------------------------------------------------
"
doscript="default.t1mabs.nrrd.do"
var=t1mabs

source $SCRIPTDIR/add.sh
$SCRIPTDIR/trainingDataT1/mktrainingfiles.sh "$dirProj"
