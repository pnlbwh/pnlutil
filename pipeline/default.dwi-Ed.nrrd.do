#!/bin/bash -eu

dirScripts="scripts-pipeline/dwied"
source "$dirScripts"/util.sh
inputvars="dwied_dwi"
setupdo $@
run "$dirScripts"//dwiPipeline-nofilt.py "$dwied_dwi" $3
log_success "Made '$1'"
