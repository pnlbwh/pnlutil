#!/bin/bash -eu

SCRIPT=$(readlink -m "$(type -p $0)")
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

usage() {
echo -e "\
Usage
    ${0##*/} -t <trainingData.csv> -i <target> -o <outMask> "
}

## Parse args
while getopts "ht:i:o:" OPTION; do
    case $OPTION in
        h) usage; exit 0;;
        t) csvTrainingData=$OPTARG;;
        i) imgTarget=$OPTARG;;
        o) maskOut=$OPTARG;;
    esac
done

for arg in csvTrainingData imgTarget maskOut; do
    [ -n "${!arg-}" ] || { usage; exit 1; }
done
for arg in csvTrainingData imgTarget; do
    [ -e "${!arg}" ] || { echo "'${!arg}' doesn't exist"; usage; exit 1; }
done
[ ! -f "$maskOut" ]  || { echo "'$maskOut' exists, delete it first"; exit 1; }

## Check ANTSPATH is set
[ -n "${ANTSPATH-}" ] || { echo "Set ANTSPATH environment variable first"; exit 1; }

## Print input
echo "Output:"
echo "* $maskOut"
echo "Training data:"
cat $csvTrainingData | cut -d, -f1 | xargs ls -1
cat $csvTrainingData | cut -d, -f2 | xargs ls -1

## Make temporary text files
txtTrainingImages=$(mktemp)
txtTrainingMasks=$(mktemp)
cat $csvTrainingData | cut -d, -f1 > $txtTrainingImages
cat $csvTrainingData | cut -d, -f2 > $txtTrainingMasks

## Register training images to target image
dirTmp=$(mktemp -d)
$SCRIPTDIR/mabsReg.sh -t $txtTrainingImages -i $imgTarget -o "$dirTmp"

## Apply registrations to training masks
$SCRIPTDIR/mabsApply.sh -t $txtTrainingMasks -i "$dirTmp" -o "$maskOut"

## Clean up
rm -rf "$dirTmp"
rm $txtTrainingImages
rm $txtTrainingMasks

log_success "Made '$maskOut'"
