#!/bin/bash -eu

dirSrc=measuretracts
git config --global core.autocrlf false

if [ ! -d "$dirSrc" ]; then 
    git clone https://github.com/pnlbwh/measuretracts
else
    pushd "$dirSrc" 
    git pull origin
    popd
fi


