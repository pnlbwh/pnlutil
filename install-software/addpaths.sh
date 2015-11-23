#!/bin/bash
# Source this file 

basedir=$(readlink -m ${BASH_SOURCE[0]}) && basedir=${basedir%/*}
redo=$basedir/redo
ants=$basedir/ANTs-build/bin
antssrc=$basedir/ANTS/Scripts
measuretracts=$basedir/measuretracts
pnlutil=$basedir/../scripts-all
#tract_querier # installed to your python installation, make sure bin folder is on path
ukf=UKFTractography-build/UKFTractography-build/ukf/bin/
unu=UKFTractography-build/bin/

export PATH=$redo:$ants:$antssrc:$measuretracts:$pnlutil:$ukf:$unu:$PATH
export PYTHONPATH=$PYTHONPATH:$basedir/VTK-6.1.0-build/lib:$basedir/VTK-6.1.0-build/Wrapping/Python/
