#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="t1xc_t1"
setupdo $@

log "Axis align and center '$t1xc_t1' to make '$1'"
run scripts-pipeline/axis_align_nrrd.py -i $t1xc_t1 -o $3
run scripts-pipeline/center.py -i $3 -o $3
log_success "Made '$1'"
