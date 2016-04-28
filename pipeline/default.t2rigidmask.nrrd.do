#!/bin/bash -eu

dirScripts="scripts-pipeline/t2rigidmask"
source "$dirScripts"/util.sh
inputvars="\
    t2rigidmask_t1mask \
    t2rigidmask_t1 \
    t2rigidmask_t2 \
    "
setupdo $@

# make_rigid_mask.sh <labelmap> <moving> <fixed> <out>
run "$dirScripts"/make_rigid_mask.sh "$t2rigidmask_t1mask" "$t2rigidmask_t1" "$t2rigidmask_t2" "$3"
log_success "Made '$1'"
