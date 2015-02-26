#!/bin/bash -eu
#
# Requires `tract_math` from tract_querier (wmql)

if [ -d "$1" ]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="\
    tractvols_tracts \
"
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars

echo "Make '$1'"
header="case,tract,tract volume"
echo "$header" > $3
for tract in $tractvols_tracts/*.vtk; do
    vol=$(tract_math $tract tract_volume 1 | sed -n 2p)
    echo "$case,$tract,$vol" >> $3
done
echo "Made '$1'"
