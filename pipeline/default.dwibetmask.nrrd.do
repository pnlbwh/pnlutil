#!/bin/bash -eu

dirScripts="scripts-pipeline/dwibetmask/"
source "$dirScripts"/util.sh
inputvars="dwibetmask_dwi"
setupdo $@
run "$dirScripts"/dwibetmask "$dwibetmask_dwi" $3
log_success "Made '$1'"
