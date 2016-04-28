#!/bin/bash -eu

dirScripts="scripts-pipeline/t1rigidmask"
source "$dirScripts"/util.sh
inputvars="\
    t1rigidmask_t2mask \
    t1rigidmask_t2 \
    t1rigidmask_t1 \
    "
setupdo $@

# make_rigid_mask.sh <labelmap> <moving> <fixed> <out>
run "$dirScripts"/make_rigid_mask.sh "$t1rigidmask_t2mask" "$t1rigidmask_t2" "$t1rigidmask_t1" "$3"
log_success "Made '$1'"
