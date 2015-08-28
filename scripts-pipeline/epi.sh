#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

HELP="DWI EPI distortion correction.

Usage:
    ${0##*/} [-d] [-f|--fast] <dwi> <dwimask> <t2> <t2mask> <out>

-f     Fast registration, for debugging
-d     Debug, don't delete temporary output directory
"

DOFAST_rigid=""
DEBUG=false
while getopts "hfd" flag; do
    case "$flag" in
        h) usage 1;;
        f) DOFAST_rigid="-f";;
        d) export DEBUG=true;;
    esac
done
shift $((OPTIND-1))

# Get args
[ $# -lt 4 ] && usage 1
inputvars="dwi dwimask t2 t2mask out"
read -r $inputvars <<< "$@"

# Check args and ANTS paths and print 
checkexists dwi dwimask t2 t2mask
checkvars ANTSPATH 
printvars DEBUG ANTSPATH $inputvars

# Set derived data paths
tmp=$(mktemp -d)
startlogging
bse="$tmp/$(base "$dwi")-maskedbse.nrrd"
t2masked="$tmp/$(base "$t2")-masked.nrrd"
t2inbse="$tmp/$(base "$t2")-in-bse-rigid.nrrd"
epiwarp="$tmp/$(base "$dwi")_in_$(base "$t2")-epiwarp.nii.gz"

log "1. Extract and mask the DWI baseline"
run "unu slice -a 3 -p 0 -i "$dwi" | unu 3op ifelse "$dwimask" - 0 -o "$bse""
log_success "1. Made masked baseline: '$bse'"

log "2. Mask the T2"
run "unu 3op ifelse "$t2mask" "$t2" 0 -o "$t2masked""
log_success "1. Made masked baseline: '$t2masked'"

log "3. Compute a rigid registration from the T2 to the DWI baseline"
#run \"$SCRIPTDIR/warp.sh\" $DOFAST_rigid -r "$t2masked" "$bse" "$t2inbse"  # -r for rigid
run $ANTSPATH/antsRegistrationSyN.sh -d 3 -f $bse -m $t2masked -t r -o $tmp/t2tobse_rigid
run $ANTSPATH/antsApplyTransforms -d 3 -i "$t2masked" -o "$t2inbse" -r "$bse" -t "$tmp/t2tobse_rigid0GenericAffine.mat"
log_success "2. Made rigidly registered T2: '$t2inbse'"

log "4. Compute 1d nonlinear registration from the DWI to the T2 along the phase direction"
moving=$bse
fixed=$t2inbse
pre="$tmp/$(base $moving)_in_$(base $fixed)_warp"
#run $ANTSPATH/ANTS 3 -m CC[$fixed,$moving,1,5] -i 50x20x10 -r Gauss[3,0] -t SyN[1] -o $pre --Restrict-Deformation 0x1x0 --do-rigid $DOFAST_warp
#run "$ANTSPATH/ComposeMultiTransform 3 "$epiwarp" -R "$fixed" "${pre}Warp.nii.gz" "${pre}Affine.txt" || true"  
# Note: composeMultiTransform has exit status 1 even when it completes successfully without an error message, hence the '|| true'
run $ANTSPATH/antsRegistrationSyN.sh -d 3 -f $fixed -m $moving -t r -o $tmp/rigid_init
run "$ANTSPATH/antsRegistration -d 3 --initial-moving-transform $tmp/rigid_init0GenericAffine.mat \
    -m cc[$fixed,$moving,1,2] -t SyN[0.25,3,0] -c 50x50x10 -f 4x2x1 \
    -s 2x1x0 --restrict-deformation 0x1x0 -v 1 -o $pre"
run "$ANTSPATH/ComposeMultiTransform 3 "$epiwarp" -R "$fixed" "${pre}1Warp.nii.gz" $tmp/rigid_init0GenericAffine.mat || true"  
log_success "3. Made 1d epi corrective warp: '$epiwarp'"

log "5. Apply warp to the DWI"
run \"$SCRIPTDIR/antsApplyTransformsDWI.sh\" "$dwi" "$dwimask" "$epiwarp" "$out" 

log_success "Made epi corrected DWI '$out'"
stoplogging $out.log

$DEBUG || rm -rf "$tmp"
