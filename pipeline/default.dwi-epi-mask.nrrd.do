#!/bin/bash -eu

source scripts-pipeline/dwiepimask/util.sh
inputvars="dwiepimask_dwi"
setupdo $@
run "unu slice -a 3 -p 0 -i "$dwiepimask_dwi" | unu 3op ifelse - 1 0 | unu save -e gzip -f nrrd -o $3"
log_success "Made '$1'"
