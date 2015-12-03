#!/bin/bash -eu

source scripts-pipeline/util.sh

input=${2}.nrrd
log "Axis align and center '$input' to make '$1'"
run axis_align_nrrd.py -i $input -o $3
run center.py -i $3 -o $3
log_success "Made '$1'"
