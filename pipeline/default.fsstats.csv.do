#!/bin/bash -eu

dirScripts="scripts-pipeline/fsstats"
source "$dirScripts"/util.sh
inputvars="\
    fsstats_fs\
"
setupdo $@

"$dirScripts"/fsstats.sh $case $fs > $3
log_success "Made '$1'"
