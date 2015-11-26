#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

SetUpData_vars="\
# -----------------------------------------------------------------
## Freesurfer
# Input
fsindwi_dwi=\$dwied
fsindwi_dwimask=\$dwimask
fsindwi_fssubjectdir=\$fs
fsindwi_t1=\$t1
fsindwi_t1mask=\$t1mabs
fsindwi_t2=\$t2
# Output
fsindwi=\$case/diff/\$case.fsindwi.nrrd
# -----------------------------------------------------------------"
dofile="default.fsindwi.nrrd.do"
scripts="bse.sh \
center.py \
fs2dwi_T2.sh \
make_rigid_mask.sh \
mask \
rigidtransform \
util.sh \
warp.sh"

usage() {
    echo -e "\
Adds 'default.fsindwi.nrrd.do' to your project directory, and adds its input variables 
$SetUpData_vars
to your project directory's data schema, 'SetUpData.sh'.

Usage:

    ${0##*/} <project_dir>

After running this script, edit '<project_dir>/SetUpData.sh', then run the
following to generate the freesurfer subject directories.

    missing fsindwi | xargs redo  # or, equivalently
    redo \`missing fsindwi\`
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
$1/SetUpData.sh 
$made_scripts

Now set the the fsindwi_* variables in 'SetUpData.sh' and run

    redo \`missing fsindwi\`  # or 'missing fsindwi | xargs redo'

(Don't forget to define your caselist in 'SetUpData.sh' as
'cases="001 002 ..."',  or 'caselist=mycaselist.txt', for
query script 'missing' to work)\
"
