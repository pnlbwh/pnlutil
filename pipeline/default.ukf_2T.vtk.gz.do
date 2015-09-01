#!/bin/bash -eu

source scripts-pipeline/util.sh
inputvars="ukf_dwi ukf_dwimask"
setupdo $@

[ -n "${ukf_params-}" ] || ukf_params=""

defaultparams="\
--numTensor 2  \
--seedsPerVoxel 10  \
--Qm 0.001 \
--Ql 70 \
--Rs 0.015 \
--stepLength 0.3 \
--seedFALimit 0.18 \
--recordLength 1.7"

vtkout=${3%.gz}

cmd="UKFTractography \
    --dwiFile $ukf_dwi \
    --maskFile $ukf_dwimask \
    --seedsFile $ukf_dwimask \
    $defaultparams \
    --recordTensors \
    --tracts $vtkout"

startlogging
log "Make '$vtkout'"
run "$cmd"
log "Made $vtkout"
log "Gzip '$3'"
gzip "$vtkout"
log_success "Made '$1'"
