#!/bin/bash -eu

dir=epi
../mkpipeline.sh $dir
cp SetUpData_config_epi.sh $dir/SetUpData_config.sh
cp caselist $dir
cd $dir && redo 
