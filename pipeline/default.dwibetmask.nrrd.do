#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="dwibetmask_dwi"
setupdo $@
run scripts-pipeline/dwibetmask "$dwibetmask_dwi" $3
log_success "Made '$1'"
