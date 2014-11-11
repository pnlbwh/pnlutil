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
check_antspath

# Start piping output to a log file
tmp="$(mktemp -d)"
log="$tmp/log"
exec > >(tee "$log") 2>&1  # pipe stderr and stdout to logfile as well as console

# Read in args
input_vars="labelmap moving fixed out"
read -r $input_vars <<<"$@"

log "List input arguments"
print_vars $input_vars

log "Check that inputs exist and download any remote ones"
get_remotes ${input_vars% *}

log "First convert inputs to nrrd and center"
tmpmoving=$tmp/$(base $moving).nrrd
tmpfixed=$tmp/$(base $fixed).nrrd
tmplabelmap=$tmp/$(base $labelmap).nrrd
ConvertBetweenFileFormats $moving $tmpmoving >/dev/null
ConvertBetweenFileFormats $fixed $tmpfixed >/dev/null
ConvertBetweenFileFormats $labelmap $tmplabelmap >/dev/null
run $SCRIPTDIR/center.py -i $tmpmoving -o $tmpmoving
run $SCRIPTDIR/center.py -i $tmpfixed -o $tmpfixed
run $SCRIPTDIR/center.py -i $tmplabelmap -o $tmplabelmap
log_success "Done centering inputs"

log "Compute rigid registration"
pre=$tmp/"$(base $moving)-to-$(base $fixed)"
rigid $tmpmoving $tmpfixed $pre
run ${ANTSPATH}/antsApplyTransforms -d 3 -i $tmplabelmap -r $tmpfixed -n NearestNeighbor -t ${pre}Affine.txt -o $out
[[ $out == *nrrd || $out == *nhdr ]] && run unu save -e gzip -f nrrd -i "$out" -o "$out"
if [ -f "$out" ]; then  # need to check because ants does not exit with an error code
    log_success "Created new mask: '$out'"
else
    log_error "Failed to create '$out'"; exit 1
fi

mv "$log" "$out.log"
