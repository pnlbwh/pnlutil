#!/bin/bash -eu

source util.sh
inputvars="\
    lblrigid_lbl \
    lblrigid_mov \
    lblrigid_fix \
    " 
setupdo $@
run "make_rigid_mask.sh $(varvalues $inputvars) $3"
log_success "Made '$1'"
