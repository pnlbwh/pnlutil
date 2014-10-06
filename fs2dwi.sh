#!/bin/bash 

set -e
set -u
SCRIPT_DIR="$(cd "$( dirname "$0")" && pwd )" && source "$SCRIPT_DIR/../util/util.sh"

HELP_TEXT="
Usage: 

   fs2bse.sh <dwi> <dwi_mask> <freesurfer_mri_folder> <output_folder>

where <dwi> and <dwi_mask> are nrrd/nhdr files
"

[ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && usage 0
[ $# -lt 4 ] && usage 1

dwi=$(readlink -f $1)
dwi_mask=$(readlink -f $2)
mri=$(readlink -f $3)
output_folder=$4

export SUBJECTS_DIR=

configdir="$SCRIPT_DIR/../config"
#read ANTS_SRC < $(dirname $0)/../config/ANTS_SRC
#read ANTS_BIN < $(dirname $0)/../config/ANTS_BIN
#read FREESURFER_HOME < $(dirname $0)/../config/FREESURFER_HOME
readconfig ANTS_SRC "$configdir/ANTS_SRC"
readconfig ANTS_BIN "$configdir/ANTS_BIN"
readconfig FREESURFER_HOME "$configdir/FREESURFER_HOME"
fsbin=$FREESURFER_HOME/bin

mkdir $output_folder || { log_fail "$output_folder already exists, delete it or choose another output folder name"; exit 1; }
log "Changing directory to $output_folder"
pushd $output_folder

log "Create brain.nii.gz and wmparc.nii.gz from their mgz versions"
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/wmparc.mgz $mri/wmparc.nii.gz
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/brain.mgz $mri/brain.nii.gz
run $fsbin/mri_vol2vol --mov $mri/brain.mgz --targ $mri/brain.mgz --regheader --o brain.nii.gz
run $fsbin/mri_label2vol --seg $mri/wmparc.mgz --temp $mri/brain.mgz --o wmparc.nii.gz --regheader $mri/wmparc.mgz
#ConvertBetweenFileFormats $mri/brain.mgz brain.nii.gz
#ConvertBetweenFileFormats $mri/wmparc.mgz wmparc.nii.gz

bse=`basename ${dwi%%.*}-bse.nrrd`
bse_masked=`basename ${bse%%.*}-masked.nrrd`
bse_masked_1mm=`basename ${bse_masked%%.*}-1mm.nii.gz`

log "Creating masked baseline: $bse_masked"
unu slice -a 3 -p 0 -i $dwi | unu 3op ifelse $dwi_mask - 0 -o $bse_masked

log "Upsampling masked baseline to 1x1x1"
#run $ANTS_BIN/ResampleImage 3 $bse_masked $bse_masked_1mm 1x1x1
run $ANTS_BIN/ResampleImageBySpacing 3 $bse_masked $bse_masked_1mm 1 1 1 

log "Computing warp from brain.nii.gz to upsampled baseline"
prefix=fs2bse1mm_
export ANTSPATH=$ANTS_BIN/  # needed by antsIntroduction.sh
run $ANTS_SRC/Scripts/antsIntroduction.sh -d 3 -i brain.nii.gz -r $bse_masked_1mm -o ${prefix} -s MI 
run mv ${prefix}deformed.nii.gz brain-inbse1mm.nii.gz 

log "Appling warp to wmparc.nii.gz to create wmparc-inbse1mm.nii.gz"
run $ANTS_BIN/WarpImageMultiTransform 3 wmparc.nii.gz wmparc-inbse1mm.nii.gz -R $bse_masked_1mm --use-NN ${prefix}Warp.nii.gz ${prefix}Affine.txt

log "Downsample wmparc-inbse1mm.nii.gz to the DWI's resolution --> wmparc-inbse.nrrd"
ConvertBetweenFileFormats wmparc-inbse1mm.nii.gz wmparc-inbse1mm.nrrd
new_size=$(unu head $bse_masked | grep "sizes:" | sed 's/sizes:\s*//')
unu resample -k cheap -s $new_size -i wmparc-inbse1mm.nrrd | unu save -e gzip -f nrrd -o wmparc-inbse.nrrd

log_success "Made $(readlink -f wmparc-inbse.nrrd)"

popd
