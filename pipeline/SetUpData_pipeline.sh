diff=$base/$case/diff
strct=$base/$case/strct

# Atlas mask
# Inputs
atlas_target=$t1align
atlas_trainingstructs=${base}/trainingt1s.txt
atlas_traininglabels=${base}/trainingmasks.txt
# Output
t1atlasmask=$strct/$case.t1atlasmask.nrrd

status_vars_extra=""
if [ -n "${ATLASMASK_EDIT:-}" ]; then
    t1atlasmask_edit=$strct/$case.t1atlasmask.edited.nrrd
    fs_mask=$t1atlasmask_edit
    status_vars_extra="t1atlasmask_edit"
else
    fs_mask=$t1atlasmask
fi

# Freesurfer
# Inputs
fs_t1=$t1align
#fs_mask=$t1atlasmask  # set above
# Output
fs=$strct/$case.freesurfer

# DWI preprocessing
# Inputs:
dwied_dwi=$dwiraw
# Output
dwied=$diff/$case.dwi-Ed.nrrd  

# DWI mask
# Inputs:
dwibetmask_dwi=$dwied
# Output
dwibetmask=$diff/$case.dwibetmask.nrrd  

if [ -n "${DWIMASK_EDIT:-}" ]; then
    dwibetmask_edit=$diff/$case.dwibetmask.edited.nrrd  
    dwiepi_dwimask=$dwibetmask_edit
    ukf_dwimask=$dwibetmask_edit

    status_vars_extra="$status_vars_extra dwibetmask_edit"
else
    dwiepi_dwimask=$dwibetmask
    ukf_dwimask=$dwibetmask
fi

status_vars_epi=""
if $EPICORRECTION; then
    status_vars_epi="t2 dwiepi dwiepimask"
    # DWI epi correction
    # Inputs
    dwiepi_dwi=$dwied
    #dwiepi_dwimask=$dwibetmask # set above
    dwiepi_t2=$t2
    # Output
    dwiepi=$diff/$case.dwi-epi.nrrd

    # DWI epi mask (for ukftractography seed map)
    # Input
    dwiepimask_dwi=$dwiepi
    # Output
    dwiepimask=$diff/$case.dwi-epi-mask.nrrd

    # UKF
    # Inputs
    ukf_dwi=$dwiepi
    #ukf_dwimask=$dwiepimask # set above
    # Output
    ukf=$diff/$case.ukf_2T.vtk.gz

    # Freesurfer to DWI registration
    # Inputs
    fsindwi_dwi=$dwiepi
    fsindwi_dwimask=$dwiepimask
else
    # UKF
    # Inputs
    ukf_dwi=$dwied
    #ukf_dwimask=$dwibetmask # set above
    # Output
    ukf=$diff/$case.ukf_2T.vtk.gz

    # Freesurfer to DWI registration
    # Inputs
    fsindwi_dwi=$dwied
    fsindwi_dwimask=$dwibetmask
fi

# Freesurfer to DWI registration
# Inputs
fsindwi_fssubjectdir=$fs
# Output
fsindwi=$diff/$case.fsindwi.nrrd

# WMQL
# Inputs
wmqltracts_tractography=$ukf
wmqltracts_wmparc=$fsindwi
wmqltracts_query=wmql_query.txt
# Output
wmqltracts=$diff/$case.wmqltracts

# WMQL tract measures
# Inputs
tractmeasures_tracts=$wmqltracts
# Output
tractmeasures=$diff/$case.tractmeasures.csv

# WMQL tract volumes
# Inputs
tractvols_tracts=$wmqltracts
# Output
tractvols=$diff/$case.tractvols.csv

status_vars="\
    t1align \
    dwiraw \
    t1atlasmask \
    fs \
    $status_vars_extra \
    dwibetmask \
    dwied \
    $status_vars_epi \
    ukf \
    fsindwi \
    wmqltracts \
    tractmeasures \
    tractvols \
    "
