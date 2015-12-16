#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

SetUpData_vars="\
# --------------------------------------------------------------------------
# WMQL
# Inputs
wmqltracts_tractography=\$ukf
wmqltracts_wmparc=\$fsindwi
wmqltracts_query=wmql_query.txt
# Output
wmqltracts=\$case/diff/\$case.wmqltracts
# --------------------------------------------------------------------------"

doscript="default.wmqltracts.do"
var=wmqltracts

source $SCRIPTDIR/add.sh

cp $SCRIPTDIR/pipeline/wmql_query.txt "$dirProj"
