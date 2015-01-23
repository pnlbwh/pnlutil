#!/usr/bin/env bash

set -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=$(dirname $SCRIPT)
source $SCRIPTDIR/util.sh

HELP="
Creates new mask by rigid alignment.

Usage:

    $(basename $0) <labelmap> <moving> <fixed> <out>

where <out> is the new labelmap in <fixed> space.
"

# Check args are ok
[ $# -lt 4 ] && usage 1
[[ -n ${1-} ]] && [[ $1 == "-h" || $1 == "--help" ]] && usage 0
[ -n "ANTSPATH" ] || { log_error "ANTSPATH not set"; exit 1; }

# Start piping output to a log file
tmp="$(mktemp -d)"
start_logging $tmp/log

# Read in args
input_vars="labelmap moving fixed out"
read -r $input_vars <<<"$@"

log "List input arguments"
print_vars $input_vars

log "Check that inputs exist and download any remote ones"
get_if_remote ${input_vars% *}

log "First convert inputs to nrrd and center"
tmpmoving=$tmp/$(base $moving).nrrd
tmpfixed=$tmp/$(base $fixed).nrrd
tmplabelmap=$tmp/$(base $labelmap).nrrd
run ConvertBetweenFileFormats $moving $tmpmoving >/dev/null
run ConvertBetweenFileFormats $fixed $tmpfixed >/dev/null
run ConvertBetweenFileFormats $labelmap $tmplabelmap >/dev/null
run $SCRIPTDIR/center.py -i $tmpmoving -o $tmpmoving
run $SCRIPTDIR/center.py -i $tmpfixed -o $tmpfixed
run $SCRIPTDIR/center.py -i $tmplabelmap -o $tmplabelmap
log_success "Done centering inputs"

log "Compute rigid registration"
rigidtransform=$tmp/"$(base $moving)-to-$(base $fixed).txt"
run $SCRIPTDIR/rigidtransform $tmpmoving $tmpfixed $rigidtransform
log "Apply rigid transformation to mask/labelmap"
run ${ANTSPATH}/antsApplyTransforms -d 3 -i $tmplabelmap -r $tmpfixed -n NearestNeighbor -t $rigidtransform -o $out
if [[ $out == *nrrd || $out == *nhdr ]]; then
    run unu save -e gzip -f nrrd -i "$out" -o "$out"
fi
if [ -f "$out" ]; then  # need to check because ants does not exit with an error code
    log_success "Created new mask: '$out'"
else
    log_error "Failed to create '$out'"; exit 1
fi

mv "$tmp/log" "$out.log"
