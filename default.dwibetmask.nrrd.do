#!/bin/bash -eu

source util.sh

if [[ -f "$1" ]]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="dwi"
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars

log "Make '$1'"
run dwibetmask "$dwi" $3
log_success "Made '$1'"
