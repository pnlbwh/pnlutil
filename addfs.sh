#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

SetUpData_vars="\
#FREESURFER_HOME=path/to/freesurfer 
fs_t1=\$case/\$case-t1.nrrd 
fs_mask=\$case/\$case-t1mask.nrrd
fs=\$case/strct/\$case.freesurfer"
dofile="default.freesurfer.do"
scripts="fs.sh util.sh"

usage() {
    echo -e "\
Adds 'default.freesurfer.nrrd.do' to your project directory, and adds its input variables 
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

$1/$dofile
$1/SetUpData.sh  # added FREESURFER_HOME, fs_t1, fs_mask, fs
$made_scripts

Now set the variables 'fs_t1' and 'fs_mask' in 'SetUpData.sh' and run

    redo \`missing fs\`  # or 'missing fs | redo'

(Don't forget to define your caselist in 'SetUpData.sh' as
'cases="001 002 ..."',  or 'caselist=mycaselist.txt', for
query script 'missing' to work)\
"
