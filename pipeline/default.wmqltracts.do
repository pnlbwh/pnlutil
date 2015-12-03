#!/bin/bash -eu

dirScripts="scripts-pipeline/wmqltracts"
source "$dirScripts"/util.sh
inputvars="\
    wmqltracts_tractography \
    wmqltracts_wmparc \
    wmqltracts_query \
    "
setupdo $@

run "$dirScripts"/wmql.sh $(varvalues $inputvars) $3 $case
log_success "Made '$1'"
