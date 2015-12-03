#!/bin/bash -eu

dirScripts="scripts-pipeline/dwixc/"
source "$dirScripts"/util.sh
inputvars="dwixc_dwi"
setupdo $@

log "Axis align and center '$dwixc_dwi' to make '$1'"
run "$dirScripts"/axis_align_nrrd.py -i $dwixc_dwi -o $3
run "$dirScripts"/center.py -i $3 -o $3
log_success "Made '$1'"
