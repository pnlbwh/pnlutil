#!/bin/bash -eu


transpose() {
awk '
BEGIN { FS=OFS=" " }
{
    for (rowNr=1;rowNr<=NF;rowNr++) {
        cell[rowNr,NR] = $rowNr
    }
    maxRows = (NF > maxRows ? NF : maxRows)
    maxCols = NR
}
END {
    for (rowNr=1;rowNr<=maxRows;rowNr++) {
        for (colNr=1;colNr<=maxCols;colNr++) {
            printf "%s%s", cell[rowNr,colNr], (colNr < maxCols ? OFS : ORS)
        }
    }
}' $1
}

needs_transpose() {
    input=$1
    numcols=$(awk '{ print NF; exit }' $input)
    if [ "$numcols" -eq 3 ]; then
        return 0; # true
    elif [ "$numcols" -eq 1 ]; then
        return 0; # true
    else
        return 1; # false
    fi
}

for input in $@; do
    if needs_transpose $input; then
        echo "'$input' needs to be tranposed"
        tmp=$(mktemp)
        transpose $input > $tmp
        mv $input /tmp
        mv $tmp $input
        echo "'$input' is transposed"
    else
        echo "'$input' is fine."
    fi
done
