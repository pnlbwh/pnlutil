##!/usr/bin/env bash

set -eu

SCRIPT_DIR="$(cd "$( dirname "$0")" && pwd )" 
source "$SCRIPT_DIR/scripts/util.sh"

# check to see if we should prevent a recompute
if [ -e "$1" ]; then 
    if [ -f config/NOUPDATE ]; then
        log_warning "\
$1 and config/NOUPDATE exists, so even though it's out of date we're not
going to recompute it.  Delete it or "config/NOUPDATE" to force an update"
        mv "$1" "$3"
        exit 0
    else
        mv "$1" $(mktemp -d)
    fi
fi

declare -r CASE=$2
declare -r CDIR="config"

redo-ifchange \
    "$CDIR/WMPARC_FILEPATTERN" \
    "$CDIR/TRACTOGRAPHY_FILEPATTERN" \
    "$CDIR/QUERY"

readconfigcase wmparc "$CDIR/WMPARC_FILEPATTERN" $CASE
readconfigcase vtk "$CDIR/TRACTOGRAPHY_FILEPATTERN" $CASE

redo-ifchange \
    "$wmparc" \
    "$vtk"

run "./scripts/maketracts.sh "$vtk" "$wmparc" "$(readlink -f $CDIR/QUERY)" $3 $CASE"
#outlog="$1.out"
#errlog="$1.err"
#(run $cmd | tee $outlog) 3>&1 1>&2 2>&3 | tee $errlog
log_success "Made '$1/'"
