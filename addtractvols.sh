#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# --------------------------------------------------------------------------
# WMQL tract volumes
# Inputs
tractvols_tracts=\$wmqltracts
# Output
tractvols=\$case/diff/\$case.tractvols.csv
# --------------------------------------------------------------------------"

doscript="default.tractvols.csv.do"
var=tractvols
source $SCRIPTDIR/add.sh
