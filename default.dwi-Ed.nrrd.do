#!/bin/bash -eu

source util.sh
inputvars="dwied_dwi"
setupdo $@
log "Make '$1'"
run dwiPipeline-nofilt.py "$dwied_dwi" $3
log_success "Made '$1'"
