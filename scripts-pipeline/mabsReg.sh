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

normalize() {
    mis=$@
    max=$(echo "$mis" | sort -nr | head -n1)
    min=$(echo "$mis" | sort -n | head -n1)
    range=$(echo "$max - $min" | bc)
    #factor=$(echo "-l(0.2)/$range" | bc -l)
    factor=$(echo "40/$range" | bc -l)

    weights=()
    for mi in $mis; do
        weights+=($(echo "e($factor*($min - $mi))" | bc -l))
    done
    # Compute normalize weights
    sum=0
    for weight in "${weights[@]}"; do
        sum=$(echo "$sum + $weight" | bc)
    done
    normalized_weights=()
    for weight in "${weights[@]}"; do
        normalized_weights+=($(echo "$weight/$sum" | bc -l))
    done

    echo "${normalized_weights[@]}" | sed 's/\./0./g' | tr ' ' '\n'
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
[ -n "${ANTSPATH-}" ] || { echo "Set ANTSPATH environment variable first"; exit 1; }

## Print input
echo "Target:"
echo "* $imgTarget"
echo "Training data:"
cat $txtTrainingImages | xargs ls -1
echo "Output directory:"
echo "* $outdir"

## Make output directory if it doesn't exist
mkdir -p "$outdir" || true
echo "Saving registrations to '$outdir'"

## Compute transforms and MI for each training image, and save filenames and MI to a csv file
csvTransforms="$outdir/transforms.csv" && rm -f $csvTransforms >/dev/null
iTraining="1"
while read imgTraining; do
    sPre=$outdir/${iTraining}_to_target
    xfmRigid=${sPre}0GenericAffine.mat
    xfmWarp=${sPre}1Warp.nii.gz
    xfm=${sPre}Transform.nii.gz
    imgTrainingWarped=${sPre}Warped.nii.gz
    #run $ANTSPATH/antsRegistrationSyNQuick.sh -d 3 -f $imgTarget -m $imgTraining -o $sPre -n 8  # '-n 8' => 8 cores
    run $ANTSPATH/antsRegistrationSyN.sh -d 3 -f $imgTarget -m $imgTraining -o $sPre -n 8  # '-n 8' => 8 cores
    run "$ANTSPATH/ComposeMultiTransform 3 "$xfm" -R "$imgTarget" "$xfmWarp" "$xfmRigid" || true"  
    fMI=$(mi $imgTarget $imgTrainingWarped)
    log "Result for '$imgTraining'"
    printf "imgTraining,imgTarget,xfm,fMI\n"
    printf "$imgTraining,$imgTarget,$xfm,$fMI\n" | tee -a $csvTransforms
    (( iTraining++ ))
done < $txtTrainingImages

# Normalize the MI and add it as a column to the csv
tmpfile=$(mktemp)
normalize $(cat $csvTransforms | cut -d, -f4) | paste -d, $csvTransforms - > $tmpfile
mv $tmpfile $csvTransforms

log_success "Made '$outdir'"
