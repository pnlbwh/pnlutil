#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

SetUpData_vars="\
# --------------------------------------------------------------------------
# EPI
# Input
dwiepi_dwi=\$dwied
dwiepi_dwimask=\$dwimask
dwiepi_t2=\$t2raw
dwiepi_t2mask=\$t2rawmask
# Output
dwiepi=\$case/diff/\$case.dwi-epi.nrrd
# ---------------------------------------------------------------------------"
dofile="default.dwi-epi.nrrd.do"
scripts="epi.sh warp.sh antsApplyTransformsDWI.sh util.sh"

usage() {
    echo -e "\
Adds 'default.dwi-epi.nrrd.do' to your project directory, and adds its input variables 
$SetUpData_vars
to your project directory's data schema, 'SetUpData.sh'.

Usage:

    ${0##*/} <project_dir>

After running this script, edit '<project_dir>/SetUpData.sh', then run the
following to generate the epi corrected DWI's 

    missing dwiepi | xargs redo  # or, equivalently
    redo \`missing dwiepi\`
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
$1/default.dwi-epi.nrrd.do 
$1/SetUpData.sh  # added dwiepi_dwi, dwiepi_dwimask, and dwiepi_t2
$made_scripts

Now set the variables dwiepi_dwi, dwiepi_dwimask, and dwiepi_t2 in 
SetUpData.sh and run

    redo \`missing dwiepi\`  # or, missing dwiepi | xargs redo

(Don't forget to define your caselist in SetUpData.sh as
'cases="001 002 ..."',  or 'caselist=mycaselist.txt', for
query script 'missing' to work)\
"
