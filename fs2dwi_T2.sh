#!/usr/bin/env bash

set -eux
SCRIPT=$(readlink -m $(type -p $0))
SCRIPT_DIR=$(dirname ${SCRIPT})
source "$SCRIPT_DIR/../util/util.sh"

HELP_TEXT="
Usage: 

   $(basename $0) <freesurfer_mri_folder> <dwi> <dwi_mask> <T2> <T2_mask> <T1> <T1_mask> <output_folder>

where <dwi> and <dwi_mask> are nrrd/nhdr files
"

[ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && usage 0
[ $# -lt 6 ] && usage 1

mri=$(readlink -f $1)
dwi=$(readlink -f $2)
dwi_mask=$(readlink -f $3)
t2=$(readlink -f $4)
t2_mask=$(readlink -f $5)
t1=$(readlink -f $6)
t1_mask=$(readlink -f $7)
output_folder=$8

export SUBJECTS_DIR=
configdir="$SCRIPT_DIR/../config"
readconfig ANTS_SRC "$configdir/ANTS_SRC"
readconfig ANTS_BIN "$configdir/ANTS_BIN"
readconfig FREESURFER_HOME "$configdir/FREESURFER_HOME"
fsbin=$FREESURFER_HOME/bin
export ANTSPATH=$ANTS_BIN/  # needed by antsIntroduction.sh

log "Make an output directory for intermediate files"
run "mkdir $output_folder" || { log_error "$output_folder already exists, delete it or choose another output folder name"; exit 1; }
run pushd $output_folder

log "Create brain.nii.gz and wmparc.nii.gz from their mgz versions"
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/wmparc.mgz $mri/wmparc.nii.gz
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/brain.mgz $mri/brain.nii.gz
run $fsbin/mri_vol2vol --mov $mri/brain.mgz --targ $mri/brain.mgz --regheader --o brain.nii.gz
run $fsbin/mri_label2vol --seg $mri/wmparc.mgz --temp $mri/brain.mgz --o wmparc.nii.gz --regheader $mri/wmparc.mgz

log "Create masked T2"
tmpt2=$(basename $t2)
tmpt2="${tmpt2%.*}-masked.nrrd"
run ConvertBetweenFileFormats $t2 $tmpt2 >/dev/null
run "unu 3op ifelse $t2_mask $tmpt2 0 -w 1 | unu save -e gzip -f nrrd -o "$tmpt2""
$SCRIPT_DIR/../util/center.py -i "$tmpt2" -o "$tmpt2"
t2=$tmpt2

log "Create masked T1"
tmpt1=$(basename $t1)
tmpt1="${tmpt1%.*}-masked.nrrd"
run ConvertBetweenFileFormats $t1 $tmpt1 >/dev/null
run "unu 3op ifelse $t1_mask $tmpt1 0 -w 1 | unu save -e gzip -f nrrd -o "$tmpt1""
$SCRIPT_DIR/../util/center.py -i "$tmpt1" -o "$tmpt1"
t1=$tmpt1

log "Create masked baseline"
bse=$(basename ${dwi%%.*}-bse.nrrd)
bse_masked=$(basename ${bse%%.*}-masked.nrrd)
run "unu slice -a 3 -p 0 -i $dwi | unu 3op ifelse $dwi_mask - 0 -o $bse_masked"
$SCRIPT_DIR/../util/center.py -i "$bse_masked" -o "$bse_masked"

log "Compute rigid transformation from brain.nii.gz to T1"
prefix1="fs-to-t1_"
moving=brain.nii.gz
fixed=$t1
run $ANTS_BIN/ANTS 3 -m MI[$fixed,$moving,1,32] -i 0 -o $prefix1 --do-rigid

log "Compute rigid transformation from masked T1 to masked T2"
prefix2="t1-to-t2_"
moving=$t1
fixed=$t2
run $ANTS_BIN/ANTS 3 -m MI[$fixed,$moving,1,32] -i 0 -o $prefix2 --do-rigid

log "Compute warp from T2 to DWI baseline"
prefix3="t2-in-bse_"
export ANTSPATH=$ANTS_BIN/  # needed by antsIntroduction.sh
run $ANTS_SRC/Scripts/antsIntroduction.sh -d 3 -i "$t2" -r "$bse_masked" -o ${prefix3} -s MI 
run mv ${prefix3}deformed.nii.gz t2-in-bse.nii.gz 

log "Apply transformations to wmparc.nii.gz to create wmparc-in-bse.nii.gz"
#run $ANTS_BIN/WarpImageMultiTransform 3 wmparc.nii.gz wmparc-in-bse.nii.gz -R $bse_masked --use-NN ${prefix1}Affine.txt ${prefix2}Warp.nii.gz ${prefix2}Affine.txt
#run $ANTS_BIN/WarpImageMultiTransform 3 wmparc.nii.gz wmparc-in-bse.nii.gz -R $bse_masked --use-NN ${prefix1}Affine.txt ${prefix2}Affine.txt ${prefix2}Warp.nii.gz
run $ANTS_BIN/antsApplyTransforms -d 3 -i wmparc.nii.gz -o wmparc-in-bse.nii.gz -r "$bse_masked" -n NearestNeighbor -t ${prefix3}Warp.nii.gz ${prefix3}Affine.txt ${prefix2}Affine.txt ${prefix1}Affine.txt

ConvertBetweenFileFormats wmparc-in-bse.nii.gz wmparc-in-bse.nrrd >/dev/null
out=$(readlink -f wmparc-in-bse.nrrd) && log_success "Made '$out'"

popd
