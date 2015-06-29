#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

SetUpData_vars="\
atlas_target=\$case/\$case-t1  # if you have \$t1 already defined, make this line 'atlas_target=\$t1'
atlas_trainingstructs=trainingt1s.txt
atlas_traininglabels=trainingmasks.txt
t1atlasmask=\$case/strct/\$case.t1atlasmask.nrrd"

usage() {
    echo -e "\
Adds 'default.t1atlasmask.nrrd.do', 'trainingt1s.txt', 'trainingmasks.txt', 
to your project directory, and adds its input variables 
$SetUpData_vars
to your project directory's data schema, 'SetUpData.sh'.

Usage:

    ${0##*/} <project_dir>

Then edit 'atlas_target' in 'SetUpData.sh' to point to your T1's and
run 

    missing t1atlasmask | xargs redo  # or, equivalently
    redo \`missing t1atlasmask\`
"
}

[ $# -eq 1 ] && [[ ! $1 == "-h" ]] || { usage; exit 1; }

[ -d $1 ] || { echo "Make directory '$1' first."; exit 1; }
cp $SCRIPTDIR/pipeline/default.atlaslabelmap.nrrd.do $1/default.t1atlasmask.nrrd.do
datadir="$SCRIPTDIR"/pipeline/trainingdata/
ls -1 $datadir/*edited.nrrd | sed "s|.*\/|$datadir|" | head > $1/trainingmasks.txt
ls -1 $datadir/*realign.nrrd | sed "s|.*\/|$datadir|" | head > $1/trainingt1s.txt
echo >> $1/SetUpData.sh
echo "$SetUpData_vars" >> $1/SetUpData.sh 

echo -e "Made

    $1/trainingmasks.txt
    $1/trainingt1s.txt 
    $1/default.t1atlasmask.nrrd.do 
    $1/SetUpData.sh  # added default.t1atlasmask.nrrd.do's input variables here

Now edit 'atlas_target' in 'SetUpData.sh' and run 

    redo \`missing t1atlasmask\`  # or 'missing t1atlasmask | redo'

(Don't forget to define your caselist in 'SetUpData.sh' as
'cases="001 002 ..."',  or 'caselist=mycaselist.txt', for
query script 'missing' to work)\
"

