#!/usr/bin/env bash

set -eu
#SCRIPT=$(readlink -m $(type -p "$0"))
#SCRIPTDIR=$(dirname $SCRIPT)
SCRIPTDIR=../scripts-pipeline/
source "$SCRIPTDIR/util.sh"

HELP="DWI EPI distortion correction.

Usage:
    ${0##*/} [-d] [-f|--fast] <dwi> <dwimask> <t2> <out>

-f     Fast registration, for debugging
-d     Debug, don't delete temporary output directory
"

DOFAST_rigid=""
DOFAST_warp=""
DEBUG=false
while getopts "hfd" flag; do
    case "$flag" in
        h) usage 1;;
        f) DOFAST_rigid="-f"; DOFAST_warp="--number-of-affine-iterations 1";;
        d) export DEBUG=true;;
    esac
done
shift $((OPTIND-1))

[ $# -lt 4 ] && usage 1
inputvars="dwi dwimask t2 out"
read -r $inputvars <<< "$@"
checkexists dwi dwimask t2
checkvars ANTSPATH
printvars $inputvars ANTSPATH DEBUG

tmp=$(mktemp -d)
startlogging

bse="$tmp/$(base $dwi)-maskedbse.nrrd"
t2inbse="$tmp/$(base $t2)-in-bse-rigid.nrrd"
epiwarp="$tmp/$(base $dwi)_in_$(base $t2)-epiwarp.nii.gz"


log "1. Extract and mask the DWI baseline"
run "unu slice -a 3 -p 0 -i "$dwi" | unu 3op ifelse "$dwimask" - 0 -o "$bse""
log_success "1. Made masked baseline: '$bse'"


log "2. Compute a rigid registration from the T2 to the DWI baseline"
run $SCRIPTDIR/warp.sh $DOFAST_rigid -r "$t2" "$bse" "$t2inbse"  # -r for rigid
log_success "2. Made rigidly registered T2: '$t2inbse'"


log "3. Compute 1d nonlinear registration from the DWI to the T2 along the phase direction"
moving=$bse
fixed=$t2inbse
pre="$tmp/$(base $moving)_in_$(base $fixed)_warp"
#run $ANTSPATH/ANTS 3 -m CC[$fixed,$moving,1,5] -i 50x20x10 -r Gauss[3,0] -t SyN[1] -o $pre --Restrict-Deformation 0x1x0 --do-rigid $DOFAST_warp
#run $ANTSPATH/ANTS 3 -m CC[$fixed,$moving,1,5] -i 50x20x10 -r Gauss[3,0] -t SyN[0.25] -o $pre --Restrict-Deformation 0x1x0 --do-rigid $DOFAST_warp
run $ANTSPATH/antsRegistration -d 3 --metric CC[$fixed,$moving,1,5] -r Gauss[3,0]  --convergence 50x20x10 -t SyN[0.25] -o $pre --restrict-deformation 0x1x0 
run "$ANTSPATH/ComposeMultiTransform 3 "$epiwarp" -R "$fixed" "${pre}Warp.nii.gz" "${pre}Affine.txt" || true"  
# Note: composeMultiTransform has exit status 1 even when it completes successfully without an error message, hence the '|| true'
log_success "3. Made 1d epi corrective warp: '$epiwarp'"


log "4. Apply warp to the DWI"
run $SCRIPTDIR/antsApplyTransformsDWI.sh "$dwi" "$dwimask" "$epiwarp" "$out" 
#log "5. Apply warp to DWI mask"
#run $ANTSPATH/WarpImageMultiTransform 3 "$dwimask" "$outmask" -R "$dwi" --use-NN "$epiwarp"


log_success "Made epi corrected DWI '$out'"
stoplogging $out.log

$DEBUG || rm -rf "$tmp"
