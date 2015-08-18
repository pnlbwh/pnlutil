#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="\
    t1mabs_target \
    "
setupdo $@

startlogging
run scripts-pipeline/mabs.sh -t t1mabs_trainingdata.csv -i "$t1mabs_target" -o $3
log_success "Made '$1'"
stoplogging "$1.log"
