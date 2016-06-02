#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
export PYTHONPATH=$SCRIPTDIR/tract_querier/lib
