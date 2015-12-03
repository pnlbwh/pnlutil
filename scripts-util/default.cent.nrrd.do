#!/bin/bash -eu

source scripts-pipeline/util.sh
pre=$2

if [ -e "$pre.nhdr" ]; then
    log "Center '$pre.nhdr'"
    run center.py -i $pre.nhdr -o $3
    log_success "Made '$1'"
elif [ -e "$pre.nrrd" ]; then
    log "Center '$pre.nrrd'"
    run center.py -i $pre.nrrd -o $3
    log_success "Made '$1'"
else
    log_error "'$pre.nhdr' and '$pre.nrrd' don't exist"
fi
