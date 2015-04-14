#!/bin/bash -eu
source util.sh
case=${2##*/}
setupvars tractvols tractmeasures
redo $tractvols $tractmeasures
