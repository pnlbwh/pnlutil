#!/bin/bash -eu

usage() {
    echo -e "\
Usage: 
    ${0##*/} <dirDicoms> <dwiOut>
where <dwiOut> is a nifti DWI. "
}

[[ $# > 0 &&  $1 != "-h" ]] || { usage; exit 1; }
dirDicoms=$1
dwiOut=$2

[[ $dwiOut == *nii.gz ]] || { echo "Output needs to be nii.gz"; exit 1; }

echo "Make '$dwiOut' from '$dirDicoms'"
DWIConvert --conversionMode DicomToFSL -i $dirDicoms -o $dwiOut

echo "Made '$dwiOut' and its bvec and bval files"
