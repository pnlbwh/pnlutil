#!/bin/bash -eu

source util.sh

case=${2##*/} && source ./data.sh
[ -z "${fs-}" ] && { log_error "'fs' not set in ./data.sh"; exit 1; }

[ -d "$fs" ] && run "fsstats.sh $fs/stats $case > $3" || { log_error "'$fs' doesn't exist, skipping."; exit 1; }
log_success "Made '$1'"
