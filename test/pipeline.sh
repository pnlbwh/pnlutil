#!/bin/bash -eu

pipedir=$1

#[ ! -d "$pipedir" ] || { echo "'$pipedir' exists, delete it first."; exit 1; }
../mkpipeline.sh "$pipedir"
cp pipelineconfig/SetUpData_config.sh "$pipedir"
cp pipelineconfig/caselist "$pipedir"
cd "$pipedir" && redo
