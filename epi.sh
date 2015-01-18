#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p "$0"))
PNLUTIL=$(dirname $SCRIPT)
source "$PNLUTIL/util.sh"

HELP="
Usage:
    
    $(basename $0) [-f|--fast] <dwi> <dwimask> <t2> [out]

Epi correction of <dwi>.  [-f|--fast] is mainly for debugging.
"

DOFAST=""
if [[ -n ${1-} ]]; then
    [[ $1 == "-h" || $1 == "--help" ]] && usage 0
    [[ $1 == "-f" || $1 == "--fast" ]] && { DOFAST="-f"; shift; }
fi
[ $# -lt 3 ] && usage 1
dwi=$1; dwimask=$2; t2=$3; out=${4:-$(base dwi)-epi.nrrd}

tmp=$(mktemp -d)
start_logging "$tmp/log"

check_vars ANTSPATH

bse="$tmp/$(base $dwi)-maskedbse.nrrd"
t2inbse="$tmp/$(base $t2)-in-bse-rigid.nrrd"
epiwarp="$tmp/$(base $dwi)_in_$(base $t2)-epiwarp.nii.gz"

log "1. Extract and mask the DWI baseline"
run $PNLUTIL/maskbse "$dwi" "$dwimask" "$bse" 
log_success "1. Made masked baseline: '$bse'"

log "2. Compute a rigid registration from the T2 to the DWI baseline"
run $PNLUTIL/rigid $DOFAST "$t2" "$bse" "$t2inbse" 
log_success "2. Made rigidly registered T2: '$t2inbse'"

log "3. Compute 1d nonlinear registration from the DWI to the T2 along the phase direction"
moving=$bse
fixed=$t2inbse
pre="$tmp/$(base $moving)_in_$(base $fixed)_warp"
run $ANTSPATH/ANTS 3 -m CC[$fixed,$moving,1,5] -i 50x20x10 -r Gauss[3,0] -t SyN[1] -o $pre --Restrict-Deformation 0x1x0 --do-rigid $DOFAST
run $ANTSPATH/ComposeMultiTransform 3 "$epiwarp" -R "$fixed" "${pre}Warp.nii.gz" "${pre}Affine.txt"
log_success "3. Made 1d epi corrective warp: '$epiwarp'"

log "4. Apply warp to the DWI"
run $PNLUTIL/warpdwi.sh "$dwi" "$dwimask" "$epiwarp" "$out" 

log_success "Made epi corrected DWI: '$out'"
mv "$tmp/log" "$out.log"
rm -rf "$tmp"
