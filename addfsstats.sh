#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# -----------------------------------------------------------------
## Freesurfer Stats
# Input
fsstats_fs=\$fs
# Output
fsstats=\$case/strct/\$case.fsstats.csv
# -----------------------------------------------------------------"
doscript="default.fsstats.csv.do"
var=fsstats

source $SCRIPTDIR/add.sh

cp $SCRIPTDIR/pipeline/fsstats.csv.do "$dirProj"
