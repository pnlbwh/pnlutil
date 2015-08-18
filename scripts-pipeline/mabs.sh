#!/bin/bash -eu

SCRIPT=$(readlink -m "$(type -p $0)")
SCRIPTDIR=$(dirname "$SCRIPT")
source "$SCRIPTDIR/util.sh"

usage() {
    echo -e "\
    Usage
        ${0##*/} -t <trainingdata.csv> -i <target> -o <outmask>
    "
}

mi() {
    $ANTSPATH/MeasureImageSimilarity 3 2 $1 $2 | head -n 1 | cut -d' ' -f6 || true
}

while getopts "ht:i:o:" OPTION; do
    case $OPTION in
        h) usage; exit 0;;
        t) trainingfile=$OPTARG;;
        i) target=$OPTARG;;
        o) outmask=$OPTARG;;
    esac
done

for arg in trainingfile target outmask; do
    [ -n "${!arg-}" ] || { echo "Set '$arg'"; usage; exit 1; }
done
for arg in trainingfile target; do
    [ -e "${!arg-}" ] || { echo "'${!arg}' doesn't exist"; usage; exit 1; }
done
[ ! -f "$outmask" ]  || { echo "'$outmask' exists, delete it first"; exit 1; }

echo "Training data:"
cat $trainingfile | cut -d, -f1 | xargs ls -l
cat $trainingfile | cut -d, -f2 | xargs ls -l

tmp=$(mktemp -d)
echo "Saving registrations to '$tmp'"
fixed=$target
mi_csv=${outmask%.*}.csv && rm -f $mi_csv >/dev/null
#echo "target,trainingcase,trainingmaskwarped,MI" > $mi_csv
trainingid=1
while IFS=, read trainingimg trainingmask; do
    moving=$trainingimg
    pre=$tmp/${trainingid}_to_target
    rigid=${pre}0GenericAffine.mat
    warp=${pre}1Warp.nii.gz
    trainingwarped=${pre}Warped.nii.gz
    trainingmaskwarped=$tmp/${trainingid}-mask-warped.nii.gz
    run $ANTSPATH/antsRegistrationSyNQuick.sh -d 3 -f $fixed -m $moving -o $pre -n 8
    run $ANTSPATH/antsApplyTransforms -d 3 -i "$trainingmask" -o "$trainingmaskwarped" -r "$target" -t "$warp $rigid"
    MI=$(mi $target $trainingwarped)
    printf "$target,$trainingid,$trainingwarped,$trainingmaskwarped,$MI\n" | tee -a $mi_csv
    (( trainingid++ ))
done < $trainingfile

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
tmpfile=$(mktemp)
normalize $(cat $mi_csv | cut -d, -f5) | paste -d, $mi_csv - > $tmpfile
mv $tmpfile $mi_csv

i="1"
while IFS=, read target trainingid trainingwarped trainingmaskwarped MI MInormalized; do
    echo "iteration $i: Weight and add mask '$trainingmaskwarped'"
    masknrrd=$(mktemp).nrrd
    ConvertBetweenFileFormats $trainingmaskwarped $masknrrd >/dev/null
    if [[ $i -eq 1 ]]; then
        run unu 2op x $masknrrd $MInormalized | unu save -f nrrd -e gzip -o $outmask
        weightedmask="$(mktemp).nrrd"
        (( i++ ))
        continue
    fi
    run unu 2op x $masknrrd $MInormalized | unu 2op + - $outmask | unu save -f nrrd -e gzip -o $outmask
    (( i++ ))
done < $mi_csv

cp $outmask $tmp
run unu 2op gt $outmask 0.5 | unu save -e gzip -f nrrd -o $outmask
log_success "Made '$outmask'"
