#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# --------------------------------------------------------------------------
# Tract measures
# Inputs
tractmeasures_tracts=\$wmqltracts
# Output
tractmeasures=\$case/diff/\$case.tractmeasures.csv
# --------------------------------------------------------------------------"

doscript="default.tractmeasures.csv.do"
var=tractmeasures
source $SCRIPTDIR/add.sh
