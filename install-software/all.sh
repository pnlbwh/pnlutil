#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

"$SCRIPTDIR"/redo.sh
"$SCRIPTDIR"/measuretracts.sh
"$SCRIPTDIR"/tract_querier.sh
"$SCRIPTDIR"/UKFTractograpy.sh
"$SCRIPTDIR"/BRAINSTools.sh
"$SCRIPTDIR"/VTK.sh
