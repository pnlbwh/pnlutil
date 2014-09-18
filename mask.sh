#!/usr/bin/env bash

set -e
set -u

usage() {
    cat <<EOF
Usage :

    mask.sh <img> <mask> <out>

Masks <img> (including DWI's) with <mask>.  Both must be in either nrrd or nifti format.
EOF
}

isnrrd()
{
    [[ $1 = *nrrd || $1 = *nhdr ]]
}

isnifti()
{
    [[ $1 = *nii || $1 = *nii.gz ]]
}

isdwi() {
    unu head $1 | egrep -q 'dimension.*4'
}

mask_dwi() {
    local dwi=$1
    local mask=$2
    local out=$3
    tmpdir=$(mktemp -d)
    unu dice -i $dwi -a 3 -o $tmpdir/dwi
    for slice in $tmpdir/dwi*nrrd; do 
        unu 3op ifelse $mask $slice 0 -o ${slice%.nrrd}-masked.nrrd
    done
    unu join -a 3 -i $tmpdir/*-masked.nrrd | unu data - > $tmpdir/tmpdwi.raw.gz
    unu head $dwi > $tmpdir/tmpdwi.nhdr
    sed "s/data file.*$/data file: tmpdwi\.raw\.gz/" -i $tmpdir/tmpdwi.nhdr
    unu save -e gzip -f nrrd -i $tmpdir/tmpdwi.nhdr -o $out
    rm -rf $tmpdir
}

[ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && { usage; exit 0; }
[ $# -lt 3 ]  && { usage >&2; exit 1; }

img=$1
mask=$2
out=$3

if  isnrrd $img && isnrrd $mask && isnrrd $out; then
    if isdwi $img; then
        mask_dwi $img $mask $out
    else
        unu 3op ifelse $mask $img 0 -w 1 | unu save -e gzip -f nrrd -o $out
    fi
elif isnifti $img && isnifti $mask && isnifti $out; then
    echo "Assuming label number in the mask is 1, if not the result will be wrong!"
    fslmaths $img -mul $mask $out
else
    echo $img 
    echo $mask 
    echo $out 
    echo "must all be in same format, either nrrd/nhdr or nii/nii.gz"
    exit 1
fi
echo "Made $out"
