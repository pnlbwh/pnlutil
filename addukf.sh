#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

SetUpData_vars="\
# --------------------------------------------------------------------------
## UKF
# Input
ukf_dwi=\$case/\$case-dwi.nrrd  # edit this, if you already defined dwi make it ukf_dwi=\$dwi
ukf_dwimask=\$case/\$case-dwimask.nrrd # edit this, if you already defined dwimask make it ukf_dwimask=\$dwimask
# Output
ukf=\$case/diff/\$case.ukf_2T.vtk.gz 
# ---------------------------------------------------------------------------"
dofile="default.ukf_2T.vtk.gz.do"
scripts="util.sh"

usage() {
    echo -e "\
Adds 'default.ukf_2T.vtk.gz.do' to your project directory, and adds its input variables 
$SetUpData_vars
to your project directory's data schema, 'SetUpData.sh'.

Usage:

    ${0##*/} <project_dir>

After running this script, edit '<project_dir>/SetUpData.sh', then run the
following to generate the epi corrected DWI's 

    missing ukf | xargs redo  # or, equivalently
    redo \`missing ukf\`
"
}


[ $# -eq 1 ] && [[ ! $1 == "-h" ]] || { usage; exit 1; }

[ -d $1 ] || { echo "Make directory '$1' first."; exit 1; }

cp $SCRIPTDIR/pipeline/$dofile $1/$dofile
echo >> $1/SetUpData.sh
echo "$SetUpData_vars" >> $1/SetUpData.sh 
mkdir -p $1/scripts-pipeline && for i in $scripts; do cp $SCRIPTDIR/scripts-pipeline/$i $1/scripts-pipeline; done

made_scripts=$(for i in $scripts; do echo "$1/scripts-pipeline/$i"; done)
echo -e "Made

$1/$dofile
$1/SetUpData.sh  # added ukf_dwi, ukf_dwimask, and ukf
$made_scripts

Now set the variables 'ukf_dwi' and 'ukf_dwimask' in 'SetUpData.sh' and run

    redo \`missing ukf\`  # or 'missing ukf | xargs redo'

(Don't forget to define your caselist in 'SetUpData.sh' as
'cases="001 002 ..."',  or 'caselist=mycaselist.txt', for
query script 'missing' to work)\
"
