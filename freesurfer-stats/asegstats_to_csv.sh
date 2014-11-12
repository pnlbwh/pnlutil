#!/bin/bash

cat -n $1 | \
    sed 's/^[ ]*//' | \
    egrep "^17|^18|^20|^21|^34" | \
    cut  -d, -f 4 | sed 's/[ ]*//'
