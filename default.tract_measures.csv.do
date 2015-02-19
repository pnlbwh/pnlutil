#!/bin/bash -eu

readlink -m $0
source util.sh

# check to see if we should prevent a recompute
if [[ -e $1 && -f config/NOUPDATE ]]; then
    cat <<EOF 
"$1" and "config/NOUPDATE" exists, so even though it's out of 
date we're not going to recompute it.  Delete it or "config/NOUPDATE" to force 
an update
EOF
    mv $1 $3
    exit 0
fi

case=${2##*/}
redo-ifchange $case.tracts

echo "Making '$1'"
cmd="measureTracts.py -i $case.tracts/*.vtk -o $3" 
run $cmd || log_error "measureTracts.py failed: $cmd"

# prepend caseid column
tmp=$(mktemp) && cp $3 $tmp
cat $tmp | awk -v case=$case -F"," 'BEGIN { OFS="," } NR==1 {$1="case" FS $1; print} NR>1 {$1=case FS $1; print}' > $3 
echo "Made '$1'"
