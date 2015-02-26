##!/usr/bin/env bash

source util.sh

if [ -d "$1" ]; then
    echo "'$1' exists and is out of date, delete it if you want to recompute it."
    mv $1 $3
    exit 0
fi

case=${2##*/}
inputvars="\
    wmql_tractography \
    wmql_wmparc \
    wmql_query \
    "
checkset_local_SetUpData $inputvars
redo_ifchange_vars $inputvars

log "Make '$1'"
run wmql.sh  $wmql_tractography  $wmql_wmparc $wmql_query $3 $case
log_success "Made '$1'"
