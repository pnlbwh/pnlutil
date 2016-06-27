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

export PATH=$redo:$brainstools:$ants:$antssrc:$pnlutil:$ukf:$measuretracts:$PATH
export ANTSPATH=$brainstools
export ANTSSRC=$antssrc
