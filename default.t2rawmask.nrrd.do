#!/bin/bash -eu

source util.sh

if [[ -f "$1" ]]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="t2raw t1alignmask t1align" 
checkset_local_SetUpData $inputvars

log "Create '$1'"
run "make_rigid_mask.sh $t1alignmask $t1align $t2raw $3"
log_success "Made '$1'"
