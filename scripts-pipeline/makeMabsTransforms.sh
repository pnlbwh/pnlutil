#!/bin/bash -eu

SCRIPT=$(readlink -m "$(type -p $0)")
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

usage() {
echo -e "\
Usage:
    ${0##*/} -t <trainingImages.txt> -i <target> -o <outdir>"
}

mi() {
    $ANTSPATH/MeasureImageSimilarity 3 2 $1 $2 | head -n 1 | cut -d' ' -f6 || true
}

[ -z "${DEBUG-}" ] || set -x

## Parse args
while getopts "ht:i:o:" OPTION; do
    case $OPTION in
        h) usage; exit 0;;
        t) txtTrainingImages=$OPTARG;;
        i) imgTarget=$OPTARG;;
        o) outdir=$OPTARG;;
    esac
done

for arg in txtTrainingImages imgTarget outdir; do
    [ -n "${!arg-}" ] || { usage; exit 1; }
done
for arg in txtTrainingImages imgTarget; do
    [ -e "${!arg-}" ] || { echo "'${!arg}' doesn't exist"; usage; exit 1; }
done

## Check ANTSPATH is set
[ -n "${ANTSPATH-}" ] || { echo "Set ANTSPATH environment variable first (the directory that has the ANTS binaries)"; exit 1; }
[ -n "${ANTSSRC-}" ] || { echo "Set ANTSSRC environment variable first (the ANTS folder that has subdirectory 'Scripts/')"; exit 1; }

startlogging

## Print input
echo "Target:"
echo "* $imgTarget"
echo "Training data:"
cat $txtTrainingImages | xargs ls -1
echo "Output directory:"
echo "* $outdir/transforms.csv"
echo "* $outdir/?_to_targetTransform.nii.gz"
echo "* $outdir/?_to_targetWarped.nii.gz"

log "Make output directory and copy labelmap making scripts"
run mkdir -p "$outdir" || true
run cp -r "$SCRIPTDIR/mabsTransforms-template/*" "$outdir"

log "Compute transforms for each training image"
csvTransforms="$outdir/transforms.csv" && rm -f $csvTransforms >/dev/null
iTraining="1"
header="imgTraining,imgTarget,xfm,imgTrainingWarped,MI"
echo $header > $csvTransforms
while read imgTraining; do
    sPre=$outdir/${iTraining}_to_target
    xfmRigid=${sPre}0GenericAffine.mat
    xfmWarp=${sPre}1Warp.nii.gz
    xfm=${sPre}Transform.nii.gz
    imgTrainingWarped=${sPre}Warped.nii.gz

    log "Compute warp from training image $iTraining to target image '$imgTarget'" 
    #run $ANTSPATH/antsRegistrationSyNQuick.sh -d 3 -f $imgTarget -m $imgTraining -o $sPre -n 8  # '-n 8' => 8 cores
    run $ANTSSRC/Scripts/antsRegistrationSyN.sh -d 3 -f $imgTarget -m $imgTraining -o $sPre -n 8  # '-n 8' => 8 cores
    run "$ANTSPATH/ComposeMultiTransform 3 "$xfm" -R "$imgTarget" "$xfmWarp" "$xfmRigid" || true"  

    log "Compute mutual information between warped training image and target image"
    MI=$(mi "$imgTarget" "$imgTrainingWarped")

    log "Save the input and output paths to '$csvTransforms'"
    echo $header
    printf "$imgTraining,$imgTarget,$xfm,$imgTrainingWarped,$MI\n" | tee -a $csvTransforms

    (( iTraining++ ))
done < $txtTrainingImages
log_success "Computed registrations"

stoplogging "$outdir/log"

log_success "Made '$outdir'"
