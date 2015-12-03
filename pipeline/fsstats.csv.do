#!/bin/bash -eu

dirScripts="scripts-pipeline/fsstatsall"
source "$dirScripts"/util.sh

cp "$dirScripts"/fsstats_header.csv $3
for case in $(cases); do
    source SetUpData.sh
    [ -f "$fsstats" ] || { echo "'$fsstats' doesn't exist, skippping"; continue; }
    sed 1d $fsstats >> $3
done
log_success "Made '$1'"
