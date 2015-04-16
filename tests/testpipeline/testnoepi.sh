#!/bin/bash -eu

dir=noepi
[ $# -eq 0 ]  || dir=$1
../../mkpipeline.sh $dir
cp SetUpData_config.sh $dir/SetUpData_config.sh
cp training*.txt $dir
cd $dir && redo 01010.all
