#!/bin/bash
# Source this file 

base=$(readlink -m ${BASH_SOURCE[0]}) && base=${base%/*}

redo=$base/redo

brainstools=$base/BRAINSTools-build/bin

#ants=$base/BRAINSTools-build/bin
antssrc=$base/BRAINSTools-build/ANTs

pnlutil=$base/../scripts-all

#tract_querier # installed to your python installation, make sure bin folder is on path

ukf=$base/UKFTractography-build/UKFTractography-build/ukf/bin/

export PATH=$redo:$brainstools:$ants:$antssrc:$pnlutil:$ukf:$PATH

export ANTSPATH=$brainstools
export ANTSSRC=$antssrc
