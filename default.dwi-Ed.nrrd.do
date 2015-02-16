#!/bin/bash -eu

source util.sh

if [[ -f "$1" ]]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="dwipipeline_dwi"
checkset_local_SetUpData $inputvars

log "Make '$1'"
run dwiPipeline-nofilt.py "$dwiraw" $3
log_success "Made '$1'"
