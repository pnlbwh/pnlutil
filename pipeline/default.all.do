#!/bin/bash -eu
source scripts-pipeline/util.sh
case=${2##*/}
setupvars tractvols tractmeasures
redo $tractvols $tractmeasures
