#!/bin/bash -eu

source util.sh
inputvars="\
    atlas_target \
    atlas_trainingstructs \
    atlas_traininglabels"
setupdo $@

startlogging
run mainANTSAtlasWeightedOutputProbability "$atlas_target" "$3" "$atlas_trainingstructs" "$atlas_traininglabels"
log "Threshold the mask at 50"
run unu 2op gt $3 50 | unu save -e gzip -f nrrd -o $3
log_success "Made '$1'"
stoplogging "$1.log"
