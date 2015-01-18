#!/usr/bin/env bash -e

source util.sh

case=${2##*/}
input_vars="\
    epi_dwi \
    epi_dwimask \
    epi_t2"
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars
epi.sh "$epi_dwi" "$epi_dwimask" "$epi_t2" $3
log_success "Made '$1'"
