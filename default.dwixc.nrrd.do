#!/bin/bash -eu

source util.sh
inputvars="dwixc_dwi"
setupdo $@

log "Axis align and center '$dwixc_dwi' to make '$1'"
run axis_align_nrrd.py -i $dwixc_dwi -o $3
run center.py -i $3 -o $3
log_success "Made '$1'"
