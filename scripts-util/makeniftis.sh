#!/bin/bash -eu

nrrds=$(ls -1 *.nrrd || true)
nhdrs=$(ls -1 *.nhdr || true)

if [ -n "$nrrds" ]; then
    for i in $nrrds; do ConvertBetweenFileFormats $i ${i/nrrd/nii.gz}; done
fi

if [ -n "$nhdrs" ]; then
    for i in $nhdrs; do ConvertBetweenFileFormats $i ${i/nhdr/nii.gz}; done
fi
