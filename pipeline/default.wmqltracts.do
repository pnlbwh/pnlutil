#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="\
    wmqltracts_tractography \
    wmqltracts_wmparc \
    wmqltracts_query \
    "
setupdo $@

run scripts-pipeline/wmql.sh $(varvalues $inputvars) $3 $case
log_success "Made '$1'"
