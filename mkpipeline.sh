#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=${SCRIPT%/*}      
source $SCRIPTDIR/util.sh

usage() {
    echo -e "Installs intrust pipeline.  Copies pipeline files
from '$SCRIPTDIR'.

Usage:
    ${0##*/} <dir>
"
}

installpipeline() {
    cp -L "$pipelinedir"/* $1
    sed -i "s,SCRIPTDIR,$SCRIPTDIR," $dir/SetUpData.sh
    datadir="$SCRIPTDIR"/pipeline-trainingdata/
    ls -1 $datadir/*edited.nrrd | sed "s|.*\/|$datadir|" | head -n 5 > $dir/trainingmasks.txt
    ls -1 $datadir/*realign.nrrd | sed "s|.*\/|$datadir|" | head -n 5 > $dir/trainingt1s.txt
    echo "Installed to '$dir':"
    for f in $files; do echo $f; done
    echo "Now make 'SetUpData_config.sh' and 'caselist' in '$dir'"
}

[ $# -gt 0 ] || { usage; exit 1; }
[ $1 = "-h" ] && { usage; exit 0; }
dir=$(readlink -f $1)

pipelinedir="$SCRIPTDIR/pipeline"
files=$(ls -1 "$pipelinedir")
files="$files trainingmasks.txt trainingt1s.txt"

existingfiles=""
for f in $files; do
    [ ! -f "$dir/$f" ] || existingfiles="$existingfiles\n$dir/$f"
done

[ -d "$dir" ] || mkdir "$dir"

echo "Copy pipeline files from '$pipelinedir' to '$dir'?"
if [ -n "$existingfiles" ]; then
    echo  "The following files would be overwritten:"
    echo -e "$existingfiles"
    echo
fi
select yn in "Yes" "Cancel"; do
    case $yn in
        Yes ) installpipeline "$dir"; break;;
        Cancel ) exit;;
    esac
done
