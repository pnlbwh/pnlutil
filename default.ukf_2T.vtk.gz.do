#!/bin/bash -eu

source util.sh

if [[ -f "$1" ]]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="ukf_dwi ukf_dwimask"
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars

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

log "Run ukf tractography to make '$vtkout'"
run "$cmd | tee $1.log"
log "Made $vtkout"

log "Gzip '$3'"
gzip "$vtkout"
log_success "Made '$1'"
