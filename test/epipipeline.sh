#!/bin/bash -eu

newdir=epi

[ ! -d "$1/$newdir" ] || { echo "'$1/$newdir' exists, delete it first."; exit 1; }
mkdir "$1/$newdir" && ../mkpipeline.sh "$1/$newdir"
cp pipelineconfig/SetUpData_config_epi.sh "$1/$newdir"
cp pipelineconfig/caselist "$1/$newdir"
cd "$1/$newdir" && redo
