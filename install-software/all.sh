#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)

"$SCRIPTDIR"/redo.sh
"$SCRIPTDIR"/measuretracts.sh
"$SCRIPTDIR"/UKFTractography.sh
"$SCRIPTDIR"/BRAINSTools.sh
# "$SCRIPTDIR"/VTK.sh
