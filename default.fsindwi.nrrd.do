#!/bin/bash -eu

source util.sh
inputvars="\
    fsindwi_dwi \
    fsindwi_dwimask \
    fsindwi_fssubjectdir"
setupdo $@

outputdir=$(mktemp -d)/$case.fsindwi_output

if [ -n "${fsindwi_t2-}" ]; then  # use t2 in registration
    inputvars_extra="\
        fsindwi_t2 \
        fsindwi_t2mask \
        fsindwi_t1 \
        fsindwi_t1mask"
    for var in $inputvars_extra; do
        [ -n "${!var-}" ] || { log_error "If using a t2, then also set '$var' in SetUpData.sh"; exit 1; }
    done
    redo-ifchange $(varvalues $inputvars_extra)
    run fs2dwi_T2.sh $fsindwi_fssubjectdir/mri $fsindwi_dwi $fsindwi_dwimask $fsindwi_t2 $fsindwi_t2mask $fsindwi_t1 $fsindwi_t1mask $outputdir
    run "mv $outputdir/wmparc-in-bse.nrrd $3"  # TODO: not upsampled yet
else  # register t1 directly to dwi
    run fs2dwi.sh $fsindwi_dwi $fsindwi_dwimask $fsindwi_fssubjectdir/mri $outputdir
    run "mv $outputdir/wmparc-in-bse-1mm.nrrd $3"
fi

mv "$outputdir/log" "$1.log"
log_success "Made '$1'"
