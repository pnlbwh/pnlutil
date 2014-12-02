#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}
source $SCRIPTDIR/../util.sh

HELP="
Outputs a column of freesurfer stats to stdout

Usage: 
    ${SCRIPT##*/} </path/to/freesurfer/subjects/case/stats> <caseid>
EOF
"

[ $# -ne 2 ] || [[ $1 == "-h" || $1 == "--help" ]]  && usage 1

stats_dir=$1
case_id=$2
get_remotes stats_dir

aseg=$stats_dir/aseg.stats
wmparc=$stats_dir/wmparc.stats
lh_aparc=$stats_dir/lh.aparc.stats
rh_aparc=$stats_dir/rh.aparc.stats

cat <(echo $case_id) \
    <($SCRIPTDIR/header_stat.sh $aseg 17) \
    <($SCRIPTDIR/header_stat.sh $aseg 18) \
    <($SCRIPTDIR/header_stat.sh $aseg 20) \
    <($SCRIPTDIR/header_stat.sh $aseg 21) \
    <($SCRIPTDIR/header_stat.sh $aseg 34) \
    <($SCRIPTDIR/statsfile_to_csv.sh $aseg | cut -d, -f4) \
    <($SCRIPTDIR/statsfile_to_csv.sh $wmparc | cut -d, -f4) \
    <($SCRIPTDIR/statsfile_to_csv.sh $lh_aparc | cut -d, -f4) \
    <($SCRIPTDIR/statsfile_to_csv.sh $rh_aparc | cut -d, -f4) \
    <(echo "") \
    <($SCRIPTDIR/header_stat.sh $lh_aparc 21) \
    <($SCRIPTDIR/statsfile_to_csv.sh $lh_aparc | cut -d, -f5) \
    <($SCRIPTDIR/header_stat.sh $rh_aparc 21) \
    <($SCRIPTDIR/statsfile_to_csv.sh $rh_aparc | cut -d, -f5) | \
    paste -d "," $SCRIPTDIR/firstcol.csv -
