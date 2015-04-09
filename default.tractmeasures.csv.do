#!/bin/bash -eu

source util.sh
inputvars="\
    tractmeasures_tracts \
    "
setupdo $@

run "measureTracts.py -i $tractmeasures_tracts/*.vtk -o $3" 
# prepend caseid column
tmp=$(mktemp) && cp $3 $tmp
cat $tmp | awk -v case=$case -F"," 'BEGIN { OFS="," } NR==1 {$1="case" FS $1; print} NR>1 {$1=case FS $1; print}' > $3 
log_success "Made '$1'"
