#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="dwied_dwi"
setupdo $@
run scripts-pipeline/dwiPipeline-nofilt.py "$dwied_dwi" $3
log_success "Made '$1'"
