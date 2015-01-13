#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

HELP="
Usage: 

   ${0##*/} <freesurfer_mri_folder> <dwi> <dwi_mask> <T2> <T2_mask> <T1> <T1_mask> <output_dir>

where <dwi> and <dwi_mask> are nrrd/nhdr files
"

[ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && usage 0
[ $# -ne 8 ] && usage 1

log=$(mktemp -d)/log && start_logging "$log"

check_vars FREESURFER_HOME ANTSPATH ANTSSRC
export SUBJECTS_DIR=

input_args="mri dwi dwi_mask t2 t2_mask t1 t1_mask output_dir"
read -r $input_args <<<"$@"
input_vars=${input_args% *}  # remove output_dir
get_if_remote $input_vars

log "Make and change to output directory"
run "mkdir $output_dir" || { log_error "$output_dir already exists, delete it or choose another output folder name"; exit 1; }
run pushd $output_dir

log "Make brain.nii.gz and wmparc.nii.gz from their mgz versions"
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/wmparc.mgz $mri/wmparc.nii.gz
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/brain.mgz $mri/brain.nii.gz
run $FREESURFER_HOME/bin/mri_vol2vol --mov $mri/brain.mgz --targ $mri/brain.mgz --regheader --o brain.nii.gz
run $FREESURFER_HOME/bin//mri_label2vol --seg $mri/wmparc.mgz --temp $mri/brain.mgz --o wmparc.nii.gz --regheader $mri/wmparc.mgz
log_success "Made 'brain.nii.gz' and 'wmparc.nii.gz'"

log "Make masked T2"
mask "$t2" "$t2_mask" maskedt2
log_success "Made masked T2: '$maskedt2'"

log "Make masked T1"
mask "$t1" "$t1_mask" maskedt1
log_success "Made masked T1: '$maskedt1'"

log "Make masked baseline"
bse=$(basename "$dwi")
bse="${bse%%.*}-bse.nrrd"
maskedbse=$(basename ${bse%%.*}-masked.nrrd)
run "unu slice -a 3 -p 0 -i $dwi | unu 3op ifelse $dwi_mask - 0 -o $maskedbse"
$SCRIPTDIR/center.py -i "$maskedbse" -o "$maskedbse"
log_success "Made masked baseline: '$maskedbse'"

log "Compute rigid transformation from brain.nii.gz to T1"
rigid brain.nii.gz $maskedt1 "fs-to-t1-"

log "Compute rigid transformation from masked T1 to masked T2"
rigid $maskedt1 $maskedt2 "t1-to-t2-"

log "Compute warp from T2 to DWI baseline"
warp $maskedt2 $maskedbse "t2-to-bse-"
run mv t2-to-bse-deformed.nii.gz t2-in-bse.nii.gz 

log "Apply transformations to wmparc.nii.gz to create wmparc-in-bse.nii.gz"
run $ANTSPATH/antsApplyTransforms -d 3 -i wmparc.nii.gz -o wmparc-in-bse.nrrd -r "$maskedbse" -n NearestNeighbor -t t2-to-bse-Warp.nii.gz t2-to-bse-Affine.txt t1-to-t2-Affine.txt fs-to-t1-Affine.txt
ConvertBetweenFileFormats wmparc-in-bse.nrrd wmparc-in-bse.nrrd short
log_success "Made 'wmparc-in-bse.nii.gz'"

popd
rm_remotes $input_vars
log_success "Made '$(readlink -f "$output_dir"/wmparc-in-bse.nrrd)'"
mv "$log" "$output_dir/log"
