#!/usr/bin/env bash

set -eu
SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

HELP="
Usage: 

   $(basename $0) <freesurfer_mri_folder> <dwi> <dwi_mask> <T2> <T2_mask> <T1> <T1_mask> <output_folder>

where <dwi> and <dwi_mask> are nrrd/nhdr files
"

[ -n "${1-}" ] && [[ $1 == "-h" || $1 == "--help" ]] && usage 0
[ $# -lt 8 ] && usage 1

input_vars="mri dwi dwi_mask t2 t2_mask t1 t1_mask output_folder"
read -r $input_vars <<<"$@"
get_remotes ${input_vars% *}

set_freesurfer_home

log "Make an output directory for intermediate files"
run "mkdir $output_folder" || { log_error "$output_folder already exists, delete it or choose another output folder name"; exit 1; }
run pushd $output_folder

log "Create brain.nii.gz and wmparc.nii.gz from their mgz versions"
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/wmparc.mgz $mri/wmparc.nii.gz
#$fsbin/mri_convert -rt nearest --in_type mgz --out_type nii --out_orientation LPI $mri/brain.mgz $mri/brain.nii.gz
run $FREESURFER_HOME/bin/mri_vol2vol --mov $mri/brain.mgz --targ $mri/brain.mgz --regheader --o brain.nii.gz
run $FREESURFER_HOME/bin//mri_label2vol --seg $mri/wmparc.mgz --temp $mri/brain.mgz --o wmparc.nii.gz --regheader $mri/wmparc.mgz

log "Create masked T2"
mask "$t2" "$t2_mask" maskedt2
log_success "Created masked T2: '$maskedt2'"

log "Create masked T1"
mask "$t1" "$t1_mask" maskedt1
log_success "Created masked T1: '$maskedt1'"

log "Create masked baseline"
bse=$(basename ${dwi%%.*}-bse.nrrd)
maskedbse=$(basename ${bse%%.*}-masked.nrrd)
run "unu slice -a 3 -p 0 -i $dwi | unu 3op ifelse $dwi_mask - 0 -o $maskedbse"
$SCRIPTDIR/../util/center.py -i "$maskedbse" -o "$maskedbse"

log "Compute rigid transformation from brain.nii.gz to T1"
prefix1="fs-to-t1_"
#moving=brain.nii.gz
#fixed=$t1
#run $ANTS_BIN/ANTS 3 -m MI[$fixed,$moving,1,32] -i 0 -o $prefix1 --do-rigid
rigid brain.nii.gz $maskedt1 $prefix1
log_success "Created brain.nii.gz to masked t1 rigid transform: '${prefix1}Affine.txt'"

log "Compute rigid transformation from masked T1 to masked T2"
prefix2="t1-to-t2_"
#moving=$t1
#fixed=$t2
#run $ANTS_BIN/ANTS 3 -m MI[$fixed,$moving,1,32] -i 0 -o $prefix2 --do-rigid
rigid $maskedt1 $maskedt2 $prefix2

log "Compute warp from T2 to DWI baseline"
prefix3="t2-in-bse_"
#run $ANTS_SRC/Scripts/antsIntroduction.sh -d 3 -i "$t2" -r "$maskedbse" -o ${prefix3} -s MI 
warp $maskedt2 $maskedbse $prefix3
run mv ${prefix3}deformed.nii.gz t2-in-bse.nii.gz 
log_success "Created warp from masked T2 to masked DWI: '${prefix3}Affine.txt', '${prefix3}Warp.nii.gz'"

log "Apply transformations to wmparc.nii.gz to create wmparc-in-bse.nii.gz"
#run $ANTSPATH/WarpImageMultiTransform 3 wmparc.nii.gz wmparc-in-bse.nii.gz -R $maskedbse --use-NN ${prefix1}Affine.txt ${prefix2}Warp.nii.gz ${prefix2}Affine.txt
#run $ANTSPATH/WarpImageMultiTransform 3 wmparc.nii.gz wmparc-in-bse.nii.gz -R $maskedbse --use-NN ${prefix1}Affine.txt ${prefix2}Affine.txt ${prefix2}Warp.nii.gz
run $ANTSPATH/antsApplyTransforms -d 3 -i wmparc.nii.gz -o wmparc-in-bse.nrrd -r "$maskedbse" -n NearestNeighbor -t ${prefix3}Warp.nii.gz ${prefix3}Affine.txt ${prefix2}Affine.txt ${prefix1}Affine.txt

popd
log_success "Made '$(readlink -f "$output_folder"/wmparc-in-bse.nrrd)'"
