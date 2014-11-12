#!/bin/bash

lineno=
case $(basename $1) in
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
        echo "Usage: "
        echo "    $0 [aseg.stats | wmparc.stats | lh_aparc.stats | rh_aparc.stats]"
        exit 1
esac

# $'\t' is a bash portable version of the tab character
tail -n +$lineno $1 | \
    sed 's/^[ '$'\t''][ '$'\t'']*//' | \
    sed 's/[ '$'\t'']*$//' | \
    sed -e 's/[ '$'\t''][ '$'\t'']*/,/g'
