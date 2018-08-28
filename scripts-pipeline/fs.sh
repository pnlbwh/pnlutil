#!/bin/bash -eu

SCRIPT=$(readlink -m "$(type -p $0)")
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

usage()
{
    cat << EOF
Usage:

    `basename $0` [-s] [-f] [-m <mask>] -i <t1> [-o <output_folder>]

Runs freesurfer on <t1>

Options:
-h                      help
-i  <t1>                t1 image in nifti or nrrd format (nrrd, nhdr, nii, nii.gz)
-s                      tells freesurfer to skull strip the t1
-m <mask>               use <mask> to mask the t1 before running freesurfer
-f                      force a re-run even if a subject folder already exists
-o  <output_folder>     (default: <t1>-freesurfer)
EOF
}

noskullstrip="-noskullstrip"
output_folder="."
force=false

while getopts "hm:i:sfo:" OPTION; do
    case $OPTION in
        h) usage; exit 1;;
        s) noskullstrip="" ;;
        f) force=true ;;
        m) mask=$OPTARG ;;
        i) t1=$OPTARG ;;
        o) output_folder=$OPTARG ;;
    esac
done

[ -n "${t1-}" ] || { usage; exit 1; }
[ -n "$FREESURFER_HOME" ] || { log_error "Set FREESURFER_HOME first."; exit 1; }
log "Found FREESURFER_HOME='$FREESURFER_HOME'"
set +eu # necessary because FreeSurferEnv causes error codes and has unbound variables
run source "$FREESURFER_HOME/FreeSurferEnv.sh" 
set -eu
[ -n "$SUBJECTS_DIR" ] || { log_error "'SUBJECTS_DIR' not set by '$FREESURFER_HOME/FreeSurferEnv.sh'!"; exit 1; }

get_if_remote t1

if [[ $t1 != *nii && $t1 != *nii.gz ]]; then
    tmpnii=/tmp/$(base "$t1").nii.gz
    log "t1 is nrrd, convert to nifti: '$tmpnii'"
    run ConvertBetweenFileFormats $t1 $tmpnii
    t1=$tmpnii
fi

case=$(base "$t1")
log "Set freesurfer 'case' to be name of input T1: '$case'"

if [ -d "$SUBJECTS_DIR/$case" ]; then
    if [ ! $force ]; then
        log_error "freesurfer needs to write to $FREESURFER_HOME/subjects/$case/ but
this directory already exists. Delete it first and re-run the script, or pass
'-f' option to force overwrite."
        exit 1
    else
        rm -rf "$SUBJECTS_DIR/$case"
    fi
fi

# If mask is given, then mask the img
if [ -f "${mask}" ]; then
    log "Mask t1"
    run $SCRIPTDIR/mask $t1 $mask /tmp/t1masked.nii.gz
    t1=/tmp/t1masked.nii.gz
    # If we are masking the img already, no need to skullstrip further
    noskullstrip='-noskullstrip'
    log_success "Made masked t1: '$t1'"
fi

log "Run freesurfer on '$t1'"
run "recon-all -s "$case" -i "$t1" -autorecon1 $noskullstrip && 
    cp $SUBJECTS_DIR/$case/mri/T1.mgz $SUBJECTS_DIR/$case/mri/brainmask.mgz && 
    recon-all -autorecon2 -subjid $case && 
    recon-all -autorecon3 -subjid $case  &&
    mv $SUBJECTS_DIR/$case $output_folder
    "
