#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="\
    fsindwi_dwi \
    fsindwi_dwimask \
    fsindwi_fssubjectdir"
setupdo $@

outputdir=$(mktemp -d)/$case.fsindwi_output

if [ -n "${fsindwi_t2-}" ]; then  # use t2 in registration
    inputvarsExtra="fsindwi_t1mask fsindwi_t1"
    for var in $inputvarsExtra; do
        [ -n "${!var-}" ] || { log_error "'${var}' needs to be set in SetUpData.sh"; exit 1; }
    done
    redo-ifchange $t1mabs
    run scripts-pipeline/fs2dwi_T2.sh --mri $fsindwi_fssubjectdir/mri \
                                    --dwi $fsindwi_dwi \
                                    --dwimask $fsindwi_dwimask \
                                    --t2 $fsindwi_t2 \
                                    --t1 $fsindwi_t1 \
                                    --t1mask $t1mabs \
                                    -o $outputdir
    run "mv $outputdir/wmparc-in-bse.nrrd $3"
else  # register t1 directly to dwi
    run scripts-pipeline/fs2dwi.sh $fsindwi_dwi $fsindwi_dwimask $fsindwi_fssubjectdir/mri $outputdir
    run "mv $outputdir/wmparc-in-bse-1mm.nrrd $3"
fi

mv "$outputdir/log" "$1.log"
log_success "Made '$1'"
