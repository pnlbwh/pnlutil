#!/bin/bash -eu

dirScripts="scripts-pipeline/t1mabs"
source "$dirScripts"/util.sh
inputvars="\
    t1mabs_trainingcsv \
    t1mabs_target \
    "
setupdo $@

startlogging
run "$dirScripts"/mabs.sh -t "$t1mabs_trainingcsv" -i "$t1mabs_target" -o $3
log_success "Made '$1'"
stoplogging "$1.log"
