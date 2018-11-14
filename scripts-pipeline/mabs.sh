#!/bin/bash -eu
SCRIPT=$(readlink -m "$(type -p $0)")
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

DEBUG=false
ALPHA=0.0
MERGE=true
TMPDIR=/tmp/mabsrun.$$

usage() {
echo -e "\
Multi-atlas brain segmentation.  Given a set of training images and labelmaps, computes
a new labelmap for a target image.

Usage:
    ${0##*/} [-d] [-a alpha] [-s] -t <trainingData.csv> -i <target> -o <outMask>

Options:
    -d             Debug, do not remove temporary directories.
    -a <alpha>     Set the alpha parameter used in weighting the training labelmaps.
    -s             Separate labelmap predictions, otherwise the predicted labelmaps from each column in trainingData.csv are merged.
    -t <train.csv> A csv whose first column is a set of training images, and subsequent columns are corresponding training labelmaps.
    -i <target>    The target image for the predicted labelmap(s).
    -o <out>       The prefix for the output labelmaps.
"
}

cleanup() {
    echo "here"
    echo $DEBUG
    echo $TMPDIR
    if [ "$DEBUG" = false ]; then
        echo "Clean up, remove '$TMPDIR'"
        [ -d "$TMPDIR" ] && rm -r "$TMPDIR"
        echo "Done"
    fi
    exit 1
}
trap cleanup SIGHUP SIGINT SIGTERM

## Parse args
while getopts "hdsa:t:i:o:f:" OPTION; do
    case $OPTION in
        d) DEBUG=true;;
        s) MERGE=false;; # separate predicted labelmaps, don't merge them
        h) usage; exit 0;;
        t) csvTrainingData=$OPTARG;;
        i) imgTarget=$OPTARG;;
        a) ALPHA=$OPTARG;;
        o) maskOut=$OPTARG;;
        f) TMPDIR=$OPTARG;;
    esac
done

if [ -n "${maskOut%.*}" ]; then
    maskOutPre=${maskOut%.*}
else
    maskOutPre=$maskOut
fi
maskOut=$maskOutPre.nrrd

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
colcount=$(awk -F, '{print NF}' $csvTrainingData | tail -n 1)
for i in $(seq $colcount); do
    run "cut -d, -f $i $csvTrainingData | xargs ls -1"
done

log "Compute training transforms"
dirReg=$TMPDIR/mabsTransforms
mkdir -p $dirReg
txtTrainingImages=$TMPDIR/trainingImages.txt
run "cat $csvTrainingData | cut -d, -f1 > $txtTrainingImages"
run $SCRIPTDIR/makeMabsTransforms.sh -t $txtTrainingImages -i $imgTarget -o $dirReg

log "Apply training transforms to training labelmap(s) and compute predicted labelmap"
dirLbl=$TMPDIR/mabsWarpedLabelmaps
for i in $(seq 2 $colcount); do
    txtTrainingLabelmaps=$TMPDIR/trainingLabelmaps.txt
    run cut -d, -f $i $csvTrainingData > $txtTrainingLabelmaps
    run $dirReg/makeMabsLabelmaps.py -t $txtTrainingLabelmaps  -o $dirLbl-$i
    run $dirLbl-$i/makeLabelmap.py --alpha $ALPHA -o $dirLbl-$i/labelmap.nrrd
    run rm $txtTrainingLabelmaps
done

if $MERGE; then
    log "Merging option is on: if there is more than one predicted labelmap, merge them"
    run cp $dirLbl-2/labelmap.nrrd $TMPDIR/labelmap.nrrd  # index of labelmaps starts at 2
    for i in $(seq 3 $colcount); do
        log "Merge labelmap $i"
        label=$(( i-- ))
        run "unu 3op ifelse "$dirLbl-$i/labelmap.nrrd" $label 0 | unu 2op + - "$TMPDIR/labelmap.nrrd" | unu save -e gzip -f nrrd -o $TMPDIR/labelmap.nrrd"
    done
    run mv $TMPDIR/labelmap.nrrd "${maskOut%.*}.nrrd"
    log_success "Made '$maskOut'"
else
   log "Merging option is off: "
   for i in $(seq 2 $colcount); do
        labelOut=${maskOut%.*}-col$i.nrrd
        run "cp "$dirLbl-$i/labelmap.nrrd" $labelOut"
   done
    log_success "Made '${maskOut%.*}-col?.nrrd'"
fi
