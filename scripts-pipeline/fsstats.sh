#!/bin/bash -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}
source $SCRIPTDIR/util.sh

headerstat() {
    local statsfile=$1
    local lineno=$2
    cat -n $statsfile | \
        sed 's/^[ ]*//' | \
        egrep "^$lineno" | \
        cut  -d, -f 4 | sed 's/[ ]*//'
}

stats2csv() {
    local lineno=
    case ${1##*/} in
        aseg.stats) 
            lineno=80
            ;;
        wmparc.stats)
            lineno=64
            ;;
        lh.aparc.stats)
            lineno=54
            ;;
        rh.aparc.stats)
            lineno=54
            ;;
        *)
            echo "Invalid stats file, expect"
            echo "aseg.stats | wmparc.stats | lh_aparc.stats | rh_aparc.stats"
            exit 1
    esac
    # $'\t' is a bash portable version of the tab character
    tail -n +$lineno $1 | \
        sed 's/^[ '$'\t''][ '$'\t'']*//' | \
        sed 's/[ '$'\t'']*$//' | \
        sed -e 's/[ '$'\t''][ '$'\t'']*/,/g'
}

HELP="
Outputs a csv of freesurfer stats to stdout

Usage: 
    ${SCRIPT##*/} <caseid> </path/to/freesurfer/subject-dir/>
"

[ $# -ne 2 ] || [[ $1 == "-h" || $1 == "--help" ]]  && usage 1

fsdir=$2
caseid=$1

aseg=$fsdir/stats/aseg.stats
wmparc=$fsdir/stats/wmparc.stats
lh_aparc=$fsdir/stats/lh.aparc.stats
rh_aparc=$fsdir/stats/rh.aparc.stats

for statsfile in aseg wmparc lh_aparc rh_aparc; do
    [ -f "${!statsfile}" ] || { log_error "'${!statsfile}' doesn't exist"; exit 1; }
done

cat $SCRIPTDIR/fsstats_header.csv
printf '%s,' $caseid
printf '%s,' $(headerstat $aseg 17)
printf '%s,' $(headerstat $aseg 18)
printf '%s,' $(headerstat $aseg 20)
printf '%s,' $(headerstat $aseg 21)
printf '%s,' $(headerstat $aseg 34)
printf '%s,' $(stats2csv $aseg | cut -d, -f4)
printf '%s,' $(stats2csv $wmparc | cut -d, -f4)
printf '%s,' $(stats2csv $lh_aparc | cut -d, -f4)
printf '%s,' $(stats2csv $rh_aparc | cut -d, -f4)
printf '%s,' $(headerstat $lh_aparc 21)
printf '%s,' $(stats2csv $lh_aparc | cut -d, -f5) 
printf '%s,' $(headerstat $rh_aparc 21)
printf '%s,' $(stats2csv $rh_aparc | cut -d, -f5)
printf '\n'
