#!/bin/bash -eu

source util.sh

case='*' && source ./data.sh
[ -z "${fsstats-}" ] && { log_error "'fsstats' not set in ./data.sh"; exit 1; }

log "Joining all \$fsstats to make '$1'"
joincsvs.sh $3 $fsstats
log_success "Made '$1'"
