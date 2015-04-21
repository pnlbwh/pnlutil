#!/bin/bash -eu

dir=noepi
[ $# -eq 0 ]  || dir=$1
[ ! -d "$dir" ] || { echo "'$dir' exists, delete it first."; exit 1; }
../mkpipeline.sh $dir
cp SetUpData_config.sh $dir
cp caselist $dir
cd $dir && redo
