#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPT_DIR=$(dirname ${SCRIPT})      
source "$SCRIPT_DIR/util.sh"

usage() {
    echo -e "
    ${0##*/} [-a|-r] [-f] [-s] <moving> <fixed> <out>

-a     Affine only
-r     Rigid only
-s     Save transform
-f     Fast registration, for debugging
"
}

SAVE=false
FAST=false
DORIGID=""
LINEAR=false
while getopts "hfras" flag; do
    case "$flag" in
        h) usage 1;;
        f) FAST=true;;
        r) LINEAR=true; RIGID="--do-rigid";;
        a) LINEAR=true;;
        s) SAVE=true;;
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
    run ${ANTSPATH}/ANTS 3 -m MI[$fixed,$moving,1,32] -i 0 -o $pre $DORIGID $DOFAST
    transform="${pre}Affine.txt"
    outtransform="${out%.*}-Affine.txt"
else
    $FAST && DOFAST="-m 1x1x1"
    checkvars ANTSSRC
    run $ANTSSRC/Scripts/antsIntroduction.sh -d 3 -i $moving -r $fixed -o $pre -s MI
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
