#!/bin/bash -eu

getOrigin() {
    if [ -z "$1" ]; then
        echo "bad nrrd"
    else
        echo "$1" | grep "origin" | sed 's/space origin: //'
    fi
}

getSpacedir() {
    if [ -z "$1" ]; then
        echo "bad nrrd"
    else
        echo "$1" | grep "space directions" | sed 's/space directions: //'
    fi
}

getEncoding() {
    if [ -z "$1" ]; then
        echo "bad nrrd"
    else
        echo "$1" | grep "encoding" | sed 's/encoding: //'
    fi
}

getSpace() {
    if [ -z "$1" ]; then
        echo "bad nrrd"
    else
        echo "$1" | grep "space:" | sed 's/space: //'
    fi
}

shopt -s extglob

SCRIPT=$(readlink -m $(type -p $0))
SCRIPTDIR=${SCRIPT%/*}      
source $SCRIPTDIR/util.sh

# Input
test -f SetUpData.sh || { echo "Run in directory with 'SetUpData.sh'"; exit 1; }
vars=$@

# Output
mkdir -p .tables &>/dev/null || true

# Control
#REAL_TAB=$(echo -e "\t")
#delim="$REAL_TAB"
delim="\t"

#status_vars=${status_vars% *}
#header="caseid,${vars//+( )/,}"
#header="caseid"
#for var in $status_vars; do
    #header="$header${delim}$var${delim}"
#done
#echo "$header" > "$result"

#row="'$(date +"%Y-%m-%d %H:%M")'"

for var in $vars; do 
    case=000 && source SetUpData.sh
    if [ -z "${var-}" ]; then 
        echo "'$var' not in SetUpData.sh, skipping"
        continue
    fi
    tsvResult=".tables/$var.tsv"
    header=caseid${delim}path${delim}origin${delim}spacedir${delim}space${delim}encoding
    echo -e $header > $tsvResult

    for case in $($SCRIPTDIR/cases); do
        source SetUpData.sh
        path="${!var}"

        if [ ! -f "$path" ]; then
            origin="missing nrrd"
            spacedir="missing nrrd"
            space="missing nrrd"
            encoding="missing nrrd"
        else
            nhdr=$(unu head $path)
            origin=$(getOrigin "$nhdr")
            spacedir=$(getSpacedir "$nhdr")
            space=$(getSpace "$nhdr")
            encoding=$(getEncoding "$nhdr")
        fi

        row=$case${delim}$path${delim}$origin${delim}$space${delim}$spacedir${delim}$encoding
        echo -e "$row" >> "$tsvResult"
    done
    echo "Made '$tsvResult'" >&2
done
