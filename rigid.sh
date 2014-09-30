#!/usr/bin/env bash

set -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPT_DIR=$(dirname ${SCRIPT})      
source "$SCRIPT_DIR/util.sh"

HELP_TEXT="
Perform rigid registration using ANTS.

Usage:
    $(basename $0) [-f |--fast] <moving> <fixed> <outrigid>

where <moving> and <fixed> are 3D images. [-f | --fast] is mainly
for debugging.
"

DOFAST=""
if [[ -n ${1-} ]]; then
    [[  $1 == "-h" || $1 == "--help" ]] && usage 0
    [[  $1 == "-f" || $1 == "--fast" ]] && { DOFAST="--number-of-affine-iterations 1"; shift; }
fi
[ $# -lt 3 ] && usage 1

moving=$1
fixed=$2
outrigid=${3:-$(base $moving)_in_$(base $fixed)-rigid.txt}
pre=$(mktemp -d)/$(base $outrigid)
run $(antspath ANTS) 3 -m MI[$fixed,$moving,1,32] -i 0 -o $pre --do-rigid $DOFAST
#run $(antspath antsRegistration) -d 3 -o $pre -t Rigid -m MI[$fixed,$moving,1,32] $DOFAST
mv ${pre}Affine.txt "$outrigid"
log_success "Made $outrigid"
