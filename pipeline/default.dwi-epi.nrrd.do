#!/bin/bash -eu

dirScripts="scripts-pipeline/dwiepi/"
source "$dirScripts"/util.sh
inputvars="\
    dwiepi_dwi \
    dwiepi_dwimask \
    dwiepi_t2 \
    dwiepi_t2mask \
    "
setupdo $@
"$dirScripts"/epi.sh $(varvalues $inputvars) $3
log_success "Made '$1'"
