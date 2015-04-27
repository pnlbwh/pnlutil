#!/bin/bash -e
#
# Runs freesurfer to make '$case.freesurfer/'.
#
# Requires these filepaths be defined in 'SetUpData.sh':
#   fs_t1
#   fs_mask (optional) - if defined will use it to mask '$fs_t1' before running freesurfer

source util.sh
inputvars="fs_t1 fs_mask"
setupdo $@

if [ -n "${fs_mask-}" ]; then
    redo-ifchange $fs_mask
    run fs.sh -f -i "$fs_t1" -m "$fs_mask" -o $3 
else
    skullstripflag=""
    if [[ -n "${fs_skullstrip-}" && "$fs_skullstrip" ]]; then
        skullstripflag="-s"
    fi
    run fs.sh -f $skullstripflag -i "$fs_t1" -o $3
fi
log_success "Made '$1'"
