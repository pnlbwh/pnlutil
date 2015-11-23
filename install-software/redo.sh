#!/bin/bash -eu

repo=https://github.com/mildred/redo
dirSrc=redo

if [ ! -d "$dirSrc" ]; then 
    git clone "$repo" "$dirSrc"
else
    pushd "$dirSrc" &>/dev/null
    git pull origin
    popd &>/dev/null
fi
