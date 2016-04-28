#!/bin/bash
# Source this file 

base=$(readlink -m ${BASH_SOURCE[0]}) && base=${base%/*}

redo=$base/redo

brainstools=$base/BRAINSTools-build/bin

ants=$base/BRAINSTools-build/ANTs-build/bin
antssrc=$base/BRAINSTools-build/ANTS

measuretracts=$base/measuretracts

pnlutil=$base/../scripts-all

#tract_querier # installed to your python installation, make sure bin folder is on path

ukf=UKFTractography-build/UKFTractography-build/ukf/bin/

unu=UKFTractography-build/bin/

export PATH=$redo:$brainstools:$ants:$antssrc:$measuretracts:$pnlutil:$ukf:$unu:$PATH

export PYTHONPATH=$PYTHONPATH:$base/VTK-6.1.0-build/lib:$base/VTK-6.1.0-build/Wrapping/Python/
