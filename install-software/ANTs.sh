#!/bin/bash -eu

repo=https://github.com/stnava/ANTs.git
dirSrc=ANTs
dirBld=ANTs-build
git config --global core.autocrlf false

if [ ! -d "$dirSrc" ]; then 
    git clone $repo $dirSrc
else
    pushd "$dirSrc" 
    git pull origin
    popd
fi

[ -d "$dirBld" ] || mkdir "$dirBld"

cd "$dirBld" && cmake "../$dirSrc" && make
