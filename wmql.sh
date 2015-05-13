#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

HELP="
A wrapper to 'tract_querier' that can operate on a nrrd lablemap
and a gzipped tractography file.

Usage:

    ${0##*/}  <tractography.vtk[.gz]> <wmparc.[nrrd,nii]> <queryfile> <outdir> <case>

Creates '<outdir>/<case>_*.vtk'
"

[ $# -ne 5 ] || [[  $1 == "-h" || $1 == "--help" ]] && usage 1

vtk=$1
wmparc=$2
query=$3
outdir=$4
case=$5

tmp=$(mktemp -d)
start_logging "$tmp/log"

if [[ $vtk =~ gz$ ]]; then
    tmpvtk=$tmp/$case.vtk
    log "The input tractography file is zipped, unzipping to temporary file: $vtk --> $tmpvtk"
    run "gunzip -c $vtk > $tmpvtk" && log_success "Unzipped tractography file to $tmpvtk"
    vtk=$tmpvtk
fi

log "Remove tracts with only one point"
tmpvtk_pruned=$tmp/$case-pruned.vtk
run tract_math $vtk  tract_remove_short_tracts 2 $tmpvtk_pruned
vtk=$tmpvtk_pruned

log "Make temporary nifti from $wmparc"
tmpnii="$tmp/${case}-wmparc.nii.gz"
run ConvertBetweenFileFormats "$wmparc" "$tmpnii" >/dev/null && log_success "Made wmparc nifti"

log "Run tract_querier"
run mkdir -p "$outdir"
cmd="tract_querier -t "$vtk" -a $tmpnii -q $query -o "$outdir/$case""
run "$cmd" || { log_error "tract_querier failed: $cmd"; rmdir "$outdir"; exit 1; }
log_success "Made '$outdir'"

log "Convert vtk field data to tensor data"
for vtk in "$outdir"/*vtk; do
    run "$SCRIPTDIR/activate_tensors.py" "$vtk" "$vtk"
done
log_success "Converted vtk field data to tensor data"

mv "$tmp/log" "$outdir"
rm -rf $tmp
