#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

SetUpData_vars="\
# -----------------------------------------------------------------
## T1 mask generation
# Input
t1mabs_target=\$t1  # make sure you define t1 above
# Output
t1mabs=\$case/strct/\$case.t1mabs.nrrd
# -----------------------------------------------------------------
"
dofile="default.t1mabs.nrrd.do"
scripts="mabs.sh util.sh"

usage() {
    echo -e "\
Adds 'default.t1mabs.nrrd.do' and 't1mabs_trainingdata.csv'
to your project directory, and adds its input variables 
$SetUpData_vars
to your project directory's data schema, 'SetUpData.sh'.

Usage:

    ${0##*/} <project_dir>

Then edit 't1mabs_target' in 'SetUpData.sh' to point to your T1's and
run 

    missing t1mabs | xargs redo -k  # or, equivalently
    redo -k \`missing t1atlasmask\`
"
}

[ $# -eq 1 ] && [[ ! $1 == "-h" ]] || { usage; exit 1; }
[ -d $1 ] || { echo "Make directory '$1' first."; exit 1; }

cp $SCRIPTDIR/pipeline/$dofile $1/$dofile
echo >> $1/SetUpData.sh
echo "$SetUpData_vars" >> $1/SetUpData.sh 
mkdir -p $1/scripts-pipeline && for i in $scripts; do cp $SCRIPTDIR/scripts-pipeline/$i $1/scripts-pipeline; done

tmpdir=$(mktemp -d)
datadir="$SCRIPTDIR"/pipeline/trainingdata/
ls -1 $datadir/*realign.nrrd | sed "s|.*\/|$datadir|" > "$tmpdir/t1s"
ls -1 $datadir/*edited.nrrd | sed "s|.*\/|$datadir|" > "$tmpdir/masks"
paste -d"," "$tmpdir/t1s" "$tmpdir/masks" > "$1/t1mabs_trainingdata.csv"

made_scripts=$(for i in $scripts; do echo "$1/scripts-pipeline/$i"; done)
echo -e "Made
$1/$dofile
$1/SetUpData.sh
$made_scripts
$1/t1mabs_trainingdata.csv

Now set 't1mabs_target' in 'SetUpData.sh' and run 

    redo \`missing t1mabs\`  # or 'missing t1mabs | xargs redo'

(Don't forget to define your case list in 'SetUpData.sh' as
'cases="001 002 ..."'  or 'caselist=mycaselist.txt' for
query script 'missing' to work)\
"

