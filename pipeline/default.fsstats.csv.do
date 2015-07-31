#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="\
    fsstats_fs\
"
setupdo $@

./scripts-pipeline/fsstats.sh $case $fs > $3
log_success "Made '$1'"
