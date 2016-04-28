#!/bin/bash -eu

dirScripts="scripts-pipeline/t2mabs"
source "$dirScripts"/util.sh
inputvars="\
    t2mabs_trainingcsv \
    t2mabs_target \
"

case=000 && source SetUpData.sh
[ -n "${t2mabs_target-}" ] || { echo "If you're running this as part of the full pipeline, make sure you set 't2' in SetUpData_config.sh"; }
setupdo $@

startlogging
run "$dirScripts"/mabs.sh -t "$t2mabs_trainingcsv" -i "$t2mabs_target" -o $3
log_success "Made '$1'"
stoplogging "$1.log"
