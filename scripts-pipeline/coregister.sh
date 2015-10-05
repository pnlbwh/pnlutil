#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}
source "$SCRIPTDIR/util.sh"

usage() {
    echo -e "
Coregisters t2 to t1 using flirt rigid registration.

Usage: 

    ${0##*/} t2 t1 out
"
}

[ $# -eq 3 ] && [[ $1 != "-h" ]] || { usage; exit 1; }
t2=$1
t1=$2
out=$3

tmpdir=$(mktemp -d)
t2nii="$tmpdir/t2.nii.gz"
t1nii="$tmpdir/t1.nii.gz"
outnii="$tmpdir/t2-co.nii.gz"

log "Rigid register '$t2' to '$t1' to make '$out'"
run ConvertBetweenFileFormats $t1 $t1nii
run ConvertBetweenFileFormats $t2 $t2nii
# sometimes we need to swap t2 dims, see coregisterAndMask.py

run flirt -dof 6 -in $t2nii -ref $t1nii -out $outnii
run ConvertBetweenFileFormats $outnii $out

log_success "Made '$out'"
rm -rf "$tmpdir"
