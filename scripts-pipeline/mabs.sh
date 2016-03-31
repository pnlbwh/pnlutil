#!/bin/bash -eu

SCRIPT=$(readlink -m "$(type -p $0)")
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

usage() {
echo -e "\
Usage
    ${0##*/} [-d] [-a alpha] -t <trainingData.csv> -i <target> -o <outMask> "
}

## Parse args
DEBUG=false
ALPHA=0.0
while getopts "hda:t:i:o:" OPTION; do
    case $OPTION in
        d) DEBUG=true;;
        h) usage; exit 0;;
        t) csvTrainingData=$OPTARG;;
        i) imgTarget=$OPTARG;;
        a) alpha=$OPTARG;;
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
colcount=$(awk -F, '{print NF}' $csvTrainingData | tail -n 1)
for i in $(seq $colcount); do
    run "cut -d, -f $i $csvTrainingData | xargs ls -1"
done

log "Compute training transforms"
dirReg=/tmp/mabsTransforms.$$
txtTrainingImages=/tmp/trainingImages-$$.txt
run "cat $csvTrainingData | cut -d, -f1 > $txtTrainingImages"
run $SCRIPTDIR/makeMabsTransforms.sh -t $txtTrainingImages -i $imgTarget -o $dirReg

log "Apply training transforms to training labelmap(s) and compute predicted labelmap"
dirLbl=/tmp/mabsWarpedLabelmaps.$$
for i in $(seq 2 $colcount); do
    txtTrainingLabelmaps=/tmp/trainingLabelmaps-$$.txt
    run cut -d, -f $i $csvTrainingData > $txtTrainingLabelmaps
    run $dirReg/makeMabsLabelmaps.py -t $txtTrainingLabelmaps  -o $dirLbl-$i
    run $dirLbl-$i/makeLabelmap.py --alpha $ALPHA -o $dirLbl-$i/labelmap.nrrd
    run rm $txtTrainingLabelmaps
done

# merge predicted labelmaps if more than one
log "If there is more than one predicted labelmap, merge them"
run cp $dirLbl-2/labelmap.nrrd /tmp/labelmap-$$.nrrd
for i in $(seq 3 $colcount); do
    label=$(( i-- ))
    run "unu 3op ifelse "$dirLbl-$i/labelmap.nrrd" $label 0 | unu 2op + - "/tmp/labelmap-$$.nrrd" | unu save -e gzip -f nrrd -o /tmp/labelmap-$$.nrrd"
done
run mv /tmp/labelmap-$$.nrrd "$maskOut"
log_success "Made '$maskOut'"

#cleanup
if [ ! $DEBUG ]; then
    rm -r "$dirReg" ${dirLbl}*
fi
