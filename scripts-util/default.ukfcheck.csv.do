#!/bin/bash -u

source scripts-pipeline/util.sh
case=${2##*/} && source SetUpData.sh
if [[ ! -f $ukf ]]; then
    echo "Skipping $ukf"
    exit 1
fi

inputvars="dwied dwimask ukf"
setupdo $@

run bse.sh $dwied /tmp/bse.nrrd 
vtk=/tmp/ukf.vtk
run "gunzip -c $ukf > $vtk"
scripts-pipeline/checkvtk.j -t $vtk -m $dwimask -r /tmp/bse.nrrd &> $3
tmp=$(mktemp)
paste -d, <(echo -e "case\n$case") $3 > $tmp 
mv $tmp $3
rm $vtk /tmp/bse.nrrd
