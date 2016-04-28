#!/bin/bash -eu

dirScripts="scripts-pipeline/t2xc"
source "$dirScripts"/util.sh
inputvars="t2xc_t2"
setupdo $@

log "Axis align and center '$t2xc_t2' to make '$1'"
run "$dirScripts"/axis_align_nrrd.py -i $t2xc_t2 -o $3
run "$dirScripts"/center.py -i $3 -o $3
log_success "Made '$1'"
