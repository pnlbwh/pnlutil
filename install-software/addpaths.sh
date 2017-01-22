#!/bin/bash
# Source this file 

base=$(readlink -m ${BASH_SOURCE[0]}) && base=${base%/*}

redo=$base/redo
brainstools=$base/BRAINSTools-build/bin
#ants=$base/BRAINSTools-build/bin
antssrc=$base/BRAINSTools-build/ANTs
pnlutil=$base/../scripts-all
ukf=$base/UKFTractography-build/UKFTractography-build/ukf/bin/
measuretracts=$base/measuretracts

tractquerier=$base/../scripts-pipeline/wmql/tract_querier/scripts-2.7
export PYTHONPATH=$base/../scripts-pipeline/wmql/tract_querier/lib
export PATH=$redo:$brainstools:$antssrc:$pnlutil:$ukf:$measuretracts:$tractquerier:$PATH
export ANTSPATH=$brainstools
export ANTSSRC=$antssrc
