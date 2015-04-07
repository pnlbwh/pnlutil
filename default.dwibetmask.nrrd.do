#!/bin/bash -eu

source util.sh
inputvars="dwibetmask_dwi"
setupdo $@
run dwibetmask "$dwibetmask_dwi" $3
log_success "Made '$1'"
