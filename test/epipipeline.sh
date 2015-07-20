#!/bin/bash -eu

pipedir=$1

#[ ! -d "$1/$newdir" ] || { echo "'$1/$newdir' exists, delete it first."; exit 1; }
../mkpipeline.sh "$pipedir"
cp pipelineconfig/SetUpData_config_epi.sh "$pipedir/SetUpData_config.sh"
cp pipelineconfig/caselist "$pipedir"
cd "$pipedir" && redo
