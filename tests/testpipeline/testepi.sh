#!/bin/bash -eu

dir=epi
../../mkpipeline.sh $dir
cp SetUpData_config_epi.sh $dir/SetUpData_config.sh
cp training*.txt $dir
cd $dir && redo 01010.all
