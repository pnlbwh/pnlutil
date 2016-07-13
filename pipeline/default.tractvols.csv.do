#!/bin/bash -eu
# Requires `tract_math` from tract_querier (wmql)

dirScripts="scripts-pipeline/tractvols"
source "$dirScripts"/util.sh
export PYTHONPATH=$dirScripts/tract_querier/lib:${PYTHONPATH:-}
BIN=$dirScripts/tract_querier/scripts-2.7

inputvars="\
    tractvols_tracts \
"
setupdo $@

header="case,tract,tract volume"
echo "$header" > $3
for tract in $tractvols_tracts/*.vtk; do
    vol=$($BIN/tract_math $tract tract_volume 1 | sed -n 2p)
    echo "$case,$tract,$vol" >> $3
done
log_success "Made '$1'"
