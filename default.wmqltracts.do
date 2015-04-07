#!/bin/bash -eu

source util.sh
inputvars="\
    wmqltracts_tractography \
    wmqltracts_wmparc \
    wmqltracts_query \
    "
setupdo $@

run wmql.sh $(varvalues $inputvars) $3 $case
log_success "Made '$1'"
