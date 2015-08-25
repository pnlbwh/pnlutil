#!/bin/bash -eu

SCRIPT=$(readlink -m "$(type -p $0)")
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

usage() {
echo -e "\
Usage
    ${0##*/} -t <traininglabels.txt> -i <mabsDir> -o <outlabel> "
}

[ -z "${DEBUG-}" ] || set -x

## Parse Args
while getopts "ht:i:o:" OPTION; do
    case $OPTION in
        h) usage; exit 0;;
        t) txtTrainingLabels=$OPTARG;;
        i) dirMabs=$OPTARG;;
        o) lblOut=$OPTARG;;
    esac
done

for arg in txtTrainingLabels dirMabs lblOut; do
    [ -n "${!arg-}" ] || { usage; exit 1; }
done
for arg in txtTrainingLabels dirMabs; do
    [ -e "${!arg-}" ] || { echo "'${!arg}' doesn't exist"; usage; exit 1; }
done
[ ! -f "$lblOut" ]  || { echo "'$lblOut' exists, delete it first"; exit 1; }

## Check ANTSPATH is set
[ -n "${ANTSPATH-}" ] || { echo "Set ANTSPATH environment variable first"; exit 1; }

## Print input
echo "Training data:"
cat $txtTrainingLabels | xargs ls -1

## Input csv
csvTransforms="$dirMabs/transforms.csv"

## Make new csv by adding a training labels column
csvTmp=$(mktemp)
paste -d, $csvTransforms $txtTrainingLabels > $csvTmp

## Warp and weight the labelmaps and add them together
dirTmp=$(mktemp -d)
echo "Saving temporary files to '$dirTmp'"
iTraining=1
while IFS=, read imgTraining imgTarget xfm fMI fMInormalized lblTraining; do
    # apply warp
    lblTrainingWarped=$dirTmp/$iTraining-lblTraining-warped.nrrd
    run $ANTSPATH/antsApplyTransforms -d 3 -i "$lblTraining" -o "$lblTrainingWarped" -r "$imgTarget" -t "$xfm"

    # weight
    if [[ $iTraining -eq 1 ]]; then
        run unu 2op x $lblTrainingWarped $fMInormalized | unu save -f nrrd -e gzip -o $lblOut
        (( iTraining++ ))
        continue
    fi

    # weight and add
    run unu 2op x $lblTrainingWarped $fMInormalized | unu 2op + - $lblOut | unu save -f nrrd -e gzip -o $lblOut

    (( iTraining++ ))
done < $csvTmp

## Threshold
run unu 2op gt $lblOut 0.5 | unu save -e gzip -f nrrd -o $lblOut

## Clean up
rm -rf $dirTmp $csvTmp

log_success "Made '$lblOut'"
