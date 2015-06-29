#!/usr/bin/env bash 
set -eu

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=$(dirname $SCRIPT)
source $SCRIPTDIR/../util.sh

HELP="
Usage :

    $(basename $0) <out.csv> csvs
"

check_args 2 $@

tmpdir=$(mktemp -d)
tmpcsv=$tmpdir/tmp.cv

out=$1
shift
cat $1 | cut -d, -f1 > $tmpcsv

for csv in "$@"; do
    cat $csv | cut -d, -f2 | paste -d "," $tmpcsv - > $out
    cp $out $tmpcsv
done

rm -rf $tmpdir
log_success "Made '$out'"
