#!/bin/bash -eu

source util.sh
inputvars="t1xc_t1"
setupdo $@

log "Axis align and center '$t1xc_t1' to make '$1'"
run axis_align_nrrd.py -i $t1xc_t1 -o $3
run center.py -i $3 -o $3
log_success "Made '$1'"
