#!/bin/bash -eu

source util.sh
inputvars="\
    dwiepi_dwi \
    dwiepi_dwimask \
    dwiepi_t2 \
    "
setupdo $@
epi.sh $(varvalues $inputvars) $3
log_success "Made '$1'"
