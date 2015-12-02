#!/bin/bash -eu

USAGE="Usage: $0 [intrust|3t] dir"

[ "$#" -gt "0" ] || { echo "$USAGE"; exit 1; }
config="pipelineconfig/SetUpData_config.sh"
if [ "$#" -gt 1 ]; then
    config="pipelineconfig/SetUpData_config_$1.sh"
    dir=$2
else
    dir=$1
fi

../mkpipeline.sh "$dir"
cp $config "$dir"/SetUpData_config.sh
cd "$dir" && redo
