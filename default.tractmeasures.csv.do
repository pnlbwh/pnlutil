#!/bin/bash -eu

source util.sh

if [ -d "$1" ]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="\
    tractmeasures_tracts \
    "
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars

log "Make '$1'"
run "measureTracts.py -i $tractmeasures_tracts/*.vtk -o $3" 
# prepend caseid column
tmp=$(mktemp) && cp $3 $tmp
cat $tmp | awk -v case=$case -F"," 'BEGIN { OFS="," } NR==1 {$1="case" FS $1; print} NR>1 {$1=case FS $1; print}' > $3 
echo "Made '$1'"
