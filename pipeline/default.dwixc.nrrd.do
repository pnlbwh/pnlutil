#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="dwixc_dwi"
setupdo $@

log "Axis align and center '$dwixc_dwi' to make '$1'"
run scripts-pipeline/axis_align_nrrd.py -i $dwixc_dwi -o $3
run scripts-pipeline/center.py -i $3 -o $3
log_success "Made '$1'"
