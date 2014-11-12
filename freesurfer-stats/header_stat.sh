#!/bin/bash

statsfile=$1
lineno=$2

cat -n $statsfile | \
    sed 's/^[ ]*//' | \
    egrep "^$lineno" | \
    cut  -d, -f 4 | sed 's/[ ]*//'
