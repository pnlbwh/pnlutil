#!/bin/bash -eu

source util.sh
inputvars="ukf_dwi ukf_dwimask"
setupdo $@

vtkout=${3%.gz}

matlabparams="\
--numTensor 2  \
--seedsPerVoxel 5  \
--Qm 0.0030  \
--Rs 0.015  \
--Ql 100"
cmd="UKFTractography \
    --dwiFile $ukf_dwi \
    --maskFile $ukf_dwimask \
    --seedsFile $ukf_dwimask \
    $matlabparams \
    --recordTensors \
    --tracts $vtkout"

startlogging
log "Make '$vtkout'"
run "$cmd"
log "Made $vtkout"
log "Gzip '$3'"
gzip "$vtkout"
log_success "Made '$1'"
