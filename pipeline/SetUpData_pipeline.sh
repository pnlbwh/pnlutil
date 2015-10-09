diff=$base/$case/diff
strct=$base/$case/strct
status_vars_extra=""
status_vars_epi=""

# ==========================================================
# Axis align and center DWI
dwixc_dwi=$dwiraw
dwixc=$diff/$case.dwixc.nrrd
# ==========================================================


# ==========================================================
# Axis align and center T1
t1xc_t1=$t1align
t1xc=$strct/$case.t1xc.nrrd
# ==========================================================


# ==========================================================
# MABS mask
# Inputs
t1mabs_trainingcsv=${base}/trainingDataT1.csv
t1mabs_target=$t1xc
# Output
t1mabs=$strct/$case.t1mabs.nrrd
if [ -n "${MABS_EDIT:-}" ]; then 
    t1mabs=$strct/$case.t1mabs.edited.nrrd
    t1mabs_unedited=$strct/$case.t1mabs.nrrd
    status_vars_extra="t1mabs_unedited"
fi
# ==========================================================


# ==========================================================
# Freesurfer
# Inputs
fs_mask=$t1mabs
fs_t1=$t1xc
# Output
fs=$strct/$case.freesurfer
# ==========================================================


# ==========================================================
# DWI eddy current correction
# Inputs:
dwied_dwi=$dwixc
# Output
dwied=$diff/$case.dwi-Ed.nrrd  
# ==========================================================


# ==========================================================
# DWI mask
# Inputs:
dwibetmask_dwi=$dwied
# Output
dwibetmask=$diff/$case.dwibetmask.nrrd  
if [ -n "${DWIMASK_EDIT:-}" ]; then
    dwibetmask=$diff/$case.dwibetmask.edited.nrrd  
    dwibetmask_unedited=$diff/$case.dwibetmask.nrrd  
    status_vars_extra="$status_vars_extra dwibetmask_unedited"
fi
# ==========================================================


#if [ -n "${DWIMASK_EDIT:-}" ]; then
    #dwibetmask_edit=$diff/$case.dwibetmask.edited.nrrd  
    #dwiepi_dwimask=$dwibetmask_edit
    #ukf_dwimask=$dwibetmask_edit

    #status_vars_extra="$status_vars_extra dwibetmask_edit"
#else
    #dwiepi_dwimask=$dwibetmask
    #ukf_dwimask=$dwibetmask
#fi

if $EPICORRECTION; then
    status_vars_epi="t2 dwiepi dwiepimask"
    # ==========================================================
    # DWI epi correction
    # Inputs
    dwiepi_dwi=$dwied
    dwiepi_dwimask=$dwibetmask 
    dwiepi_t2=$t2
    # Output
    dwiepi=$diff/$case.dwi-epi.nrrd
    # ==========================================================

    # ==========================================================
    # DWI epi mask (for ukftractography seed map)
    # Input
    dwiepimask_dwi=$dwiepi
    # Output
    dwiepimask=$diff/$case.dwi-epi-mask.nrrd
    # ==========================================================

    # ==========================================================
    # UKF
    # Inputs
    ukf_dwi=$dwiepi
    ukf_dwimask=$dwiepimask 
    # Output
    ukf=$diff/$case.ukf_2T.vtk.gz
    # ==========================================================

    # ==========================================================
    # Freesurfer to DWI registration
    # Inputs
    fsindwi_dwi=$dwiepi
    fsindwi_dwimask=$dwiepimask
    # ==========================================================
else
    # ==========================================================
    # UKF
    # Inputs
    ukf_dwi=$dwied
    ukf_dwimask=$dwibetmask 
    # Output
    ukf=$diff/$case.ukf_2T.vtk.gz
    # ==========================================================

    # ==========================================================
    # Freesurfer to DWI registration
    # Inputs
    fsindwi_dwi=$dwied
    fsindwi_dwimask=$dwibetmask
    # ==========================================================
fi


# ==========================================================
# Freesurfer to DWI registration
# Inputs
fsindwi_fssubjectdir=$fs
# Output
fsindwi=$diff/$case.fsindwi.nrrd
# ==========================================================


# ==========================================================
# WMQL
# Inputs
wmqltracts_tractography=$ukf
wmqltracts_wmparc=$fsindwi
wmqltracts_query=wmql_query.txt
# Output
wmqltracts=$diff/$case.wmqltracts
# ==========================================================

# ==========================================================
# WMQL tract measures
# Inputs
tractmeasures_tracts=$wmqltracts
# Output
tractmeasures=$diff/$case.tractmeasures.csv
# ==========================================================


# ==========================================================
# WMQL tract volumes
# Inputs
tractvols_tracts=$wmqltracts
# Output
tractvols=$diff/$case.tractvols.csv
# ==========================================================


# used by script 'logstatus', which writes 'statuslog.csv'
status_vars="\
    t1align \
    t1xc \
    dwiraw \
    dwixc \
    t1mabs \
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
