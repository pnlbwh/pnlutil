#!/bin/bash -eu

repo=https://github.com/demianw/tract_querier
dirSrc=tract_querier

if [ ! -d "$dirSrc" ]; then 
    git clone "$repo" "$dirSrc"
else
    pushd "$dirSrc" &>/dev/null
    git pull origin
    popd &>/dev/null
fi

cd $dirSrc && python setup.py install
