#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

HELP="
Usage:
    
    $(basename $0) [-f|--fast] <dwi> <dwimask> <t2> [out]

Epi correction of <dwi>.  [-f|--fast] is mainly for debugging.
"

DOFAST=false
if [[ -n ${1-} ]]; then
    [[ $1 == "-h" || $1 == "--help" ]] && usage 0
    [[ $1 == "-f" || $1 == "--fast" ]] && { DOFAST=true; shift; }
fi
[ $# -lt 3 ] && usage 1
dwi=$1
dwimask=$2
t2=$3
out=${4:-$(base dwi)-epi.nrrd}
outmask=$(base dwi)-epi-mask.nrrd

tmp=$(mktemp -d)
startlogging

check_vars ANTSPATH

bse="$tmp/$(base $dwi)-maskedbse.nrrd"
t2inbse="$tmp/$(base $t2)-in-bse-rigid.nrrd"
epiwarp="$tmp/$(base $dwi)_in_$(base $t2)-epiwarp.nii.gz"

log "1. Extract and mask the DWI baseline"
run "unu slice -a 3 -p 0 -i "$dwi" | unu 3op ifelse "$dwimask" - 0 -o "$bse""
log_success "1. Made masked baseline: '$bse'"

log "2. Compute a rigid registration from the T2 to the DWI baseline"
if $DOFAST; then
    #run $SCRIPTDIR/rigid -f "$t2" "$bse" "$t2inbse" 
    run $SCRIPTDIR/warp.sh -f -r "$t2" "$bse" "$t2inbse"
else
    #run $SCRIPTDIR/rigid "$t2" "$bse" "$t2inbse" 
    run $SCRIPTDIR/warp.sh -r "$t2" "$bse" "$t2inbse"  # -r for rigid
fi
log_success "2. Made rigidly registered T2: '$t2inbse'"

log "3. Compute 1d nonlinear registration from the DWI to the T2 along the phase direction"
if [ -n "${ANTSPATH_epi:-}" ]; then
    log "Found 'ANTSPATH_epi=$ANTSPATH_epi', using this as ANTSPATH"
    export ANTSPATH=$ANTSPATH_epi
fi
moving=$bse
fixed=$t2inbse
pre="$tmp/$(base $moving)_in_$(base $fixed)_warp"
if $DOFAST; then
    run $ANTSPATH/ANTS 3 -m CC[$fixed,$moving,1,5] -i 50x20x10 -r Gauss[3,0] -t SyN[1] -o $pre --Restrict-Deformation 0x1x0 --do-rigid --number-of-affine-iterations 1
else
    run $ANTSPATH/ANTS 3 -m CC[$fixed,$moving,1,5] -i 50x20x10 -r Gauss[3,0] -t SyN[1] -o $pre --Restrict-Deformation 0x1x0 --do-rigid
fi
run "$ANTSPATH/ComposeMultiTransform 3 "$epiwarp" -R "$fixed" "${pre}Warp.nii.gz" "${pre}Affine.txt" || true"  
# Note: composeMultiTransform has exit status 1 even when it completes successfully without an error message, hence the '|| true'
log_success "3. Made 1d epi corrective warp: '$epiwarp'"

log "4. Apply warp to the DWI"
run $SCRIPTDIR/warpdwi.sh "$dwi" "$dwimask" "$epiwarp" "$out" 

#log "5. Apply warp to DWI mask"
#run $ANTSPATH/WarpImageMultiTransform 3 "$dwimask" "$outmask" -R "$dwi" --use-NN "$epiwarp"

log_success "Made epi corrected DWI '$out'"
stoplogging $out.log
rm -rf "$tmp"
