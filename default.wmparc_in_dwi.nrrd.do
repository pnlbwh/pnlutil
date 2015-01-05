#!/bin/bash -eu

source util.sh

if [[ -f "$1" ]]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="fs2dwi_dwi \
    fs2dwi_dwimask \
    fs2dwi_fssubjectdir"
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars

outputdir=$(mktemp -d)/$case.fs2dwi_output

if [ -n "${fs2dwi_t2-}" ]; then  # use t2 in registration
    inputvars2="fs2dwi_t2 \
        fs2dwi_t2mask \
        fs2dwi_t1 \
        fs2dwi_t1mask"
    for var in $inputvars2; do
        [ -n "${!var-}" ] || { log_error "If using a t2, then also set '$var' SetUpData.sh"; exit 1; }
    done
    redo_ifchange_vars $inputvars2
    log "Make '$case.wmparc-in-bse.nrrd'"
    run fs2dwi_T2.sh $fs2dwi_fssubjectdir/mri $fs2dwi_dwi $fs2dwi_dwimask $fs2dwi_t2 $fs2dwi_t2mask $fs2dwi_t1 $fs2dwi_t1mask $outputdir
else  # register t1 directly to dwi
    log "Make '$case.wmparc-in-bse.nrrd'"
    run fs2dwi.sh $fs2dwi_dwi $fs2dwi_dwimask $fs2dwi_fssubjectdir/mri $outputdir
fi

run "mv $outputdir/wmparc-in-bse.nrrd $3"
log_success "Made '$1'"
