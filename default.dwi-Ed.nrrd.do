#!/bin/bash -eu

source util.sh
inputvars="dwied_dwi"
setupdo $@
run dwiPipeline-nofilt.py "$dwied_dwi" $3
log_success "Made '$1'"
