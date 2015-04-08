#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPT_DIR=$(dirname ${SCRIPT})      
source "$SCRIPT_DIR/util.sh"

usage() {
    echo -e "ANTS registration.  Default is non-linear warp.

Usage:
    ${0##*/} [-a|-r] [-f] [-x] [-s MI|CC] <moving> <fixed> <out>

-a     Affine only
-r     Rigid only
-x     Save transform
-s     Similarity metric (default: 'MI')
-f     Fast registration, for debugging

If '-x' is passed, the transform is saved as 
'\${out%.*}-Affine.txt' for linear transforms and  
'\${out%.*}-transform.nii.gz' for non-linear warps.
"

}

SAVE=false
FAST=false
LINEAR=false
DORIGID=""
DOFAST=""
METRIC="MI"
while getopts "hfraxs:" flag; do
    case "$flag" in
        h) usage 1;;
        f) FAST=true;;
        r) LINEAR=true; RIGID="--do-rigid";;
        a) LINEAR=true;;
        x) SAVE=true;;
        s) METRIC=$OPTARG;; 
    esac
done
shift $((OPTIND-1))

[ $# -eq 3 ] || { usage; exit 1; }
inputvars="moving fixed out"
read -r $inputvars <<< "$@"
startlogging 

makeabs $inputvars
printvars $inputvars ANTSPATH
checkexists moving fixed
checkvars ANTSPATH

tmp=$(mktemp -d)
run pushd $tmp
pre=$(base $moving)-to-$(base $fixed)-

if $LINEAR; then
    $FAST && DOFAST="--number-of-affine-iterations 1"
    run ${ANTSPATH}/ANTS 3 -m $METRIC[$fixed,$moving,1,32] -i 0 -o $pre $DORIGID $DOFAST
    transform="${pre}Affine.txt"
    outtransform="${out%.*}-Affine.txt"
else
    $FAST && DOFAST="-m 1x1x1"
    checkvars ANTSSRC
    run $ANTSSRC/Scripts/antsIntroduction.sh -d 3 -i $moving -r $fixed -o $pre -s $METRIC $DOFAST
    transforms="${pre}Warp.nii.gz ${pre}Affine.txt"
    transform="${pre}warp.nii.gz"
    run "$ANTSPATH/ComposeMultiTransform 3 "$transform" -R "$fixed" $transforms || true"  
    outtransform="${out%.*}-transform.nii.gz"
fi
log "Made '$transform'"
log "Transform moving to fixed space to make '$out'"
run WarpImageMultiTransform 3 "$moving" "$out" -R "$fixed" "$transform" 
run popd

if $SAVE; then
    mv $tmp/$transform $outtransform
    log_success "Made '$outtransform'"
fi
log_success "Made '$out'"
stoplogging "$out.log"
rm -rf $tmp
log_success "Made '$out.log'"
