#!/bin/bash -eu

source util.sh

case=${2##*/}
source ./data.sh
inputvars="t2_raw t1_align t1_align_mask ANTSPATH" 
assert_vars_are_set $inputvars
export ANTSPATH

log "Create '$1'"
run "make_rigid_mask.sh $t1_align_mask $t1_align $t2_raw $3"
log_success "Made '$1'"
