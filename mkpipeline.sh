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

[ $# -gt 0 ] || { usage; exit 1; }
[ $1 = "-h" ] && { usage; exit 0; }
dir=$(readlink -f $1)

tmpdir=$(mktemp -d)
pipelinedir="$SCRIPTDIR/pipeline"
datadir="$pipelinedir/trainingdata/"
ls -1 $datadir/*edited.nrrd | sed "s|.*\/|$datadir|" > $tmpdir/trainingmasks.txt
ls -1 $datadir/*realign.nrrd | sed "s|.*\/|$datadir|" > $tmpdir/trainingt1s.txt
pushd $pipelinedir
cp -LR $(ls . | grep -v trainingdata) $tmpdir
sed -i "s,SCRIPTDIR,$(readlink -m "$1")\/scripts-pipeline," $tmpdir/SetUpData.sh
popd

[ -d "$dir" ] || mkdir "$dir"

echo "Diff between staging temporary staging directory '$tmpdir' and target directory '$dir':"
echo "------------------------------------------------------------------------------------------------------"
diff=$(diff -rqu "$tmpdir" "$dir" | grep "$tmpdir" | grep -v '.redo' | grep -v 'trainingdata' || true)
if [ -n "$diff" ]; then
    echo  "$diff" 
    echo "------------------------------------------------------------------------------------------------------"
else
    echo "No difference, nothing to do"
    echo "------------------------------------------------------------------------------------------------------"
    exit 0
fi

goodbyeMsg() {
    echo "Now make 'SetUpData_config.sh' and 'caselist' in '$dir' and run 'redo'"
}

echo "Copy files to '$dir'?"
select yn in "Yes" "Cancel"; do
    case $yn in
        Yes ) cp -r $tmpdir/* "$dir"; rm -r "$tmpdir"; goodbyeMsg; exit;;
        Cancel ) break;;
    esac
done

echo "Delete temporary staging directory '$tmpdir'?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) rm -r $tmpdir; break;;
        No ) break;;
    esac
done
