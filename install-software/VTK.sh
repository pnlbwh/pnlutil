#!/bin/bash -eu

repo=https://github.com/Kitware/VTK.git
dirSrc=VTK
dirBld="$dirSrc"-build
#git config --global core.autocrlf false

if [ ! -d "$dirSrc" ]; then 
    git clone $repo $dirSrc
else
    pushd "$dirSrc" 
    git pull origin
    popd
fi

[ -d "$dirBld" ] || mkdir "$dirBld"

cd "$dirBld" && cmake "../$dirSrc" -DVTK_WRAP_PYTHON=ON && make
