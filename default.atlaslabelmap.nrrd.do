#!/bin/bash -eu

source util.sh

if [[ -f "$1" ]]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
case=${case%%.*}

tmp=$(mktemp -d) && start_logging "$tmp/log" 
inputvars="\
    atlas_target \
    atlas_trainingstructs \
    atlas_traininglabels"
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars

log "Make '$1'"
run mainANTSAtlasWeightedOutputProbability "$atlas_target" "$3" "$atlas_trainingstructs" "$atlas_traininglabels"
log "Threshold the mask at 50"
run unu 2op gt $3 50 | unu save -e gzip -f nrrd -o $3
log_success "Made '$1'"
mv "$tmp/log" "$1.log" && rm -rf "$tmp"
