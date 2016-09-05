diff=$base/$case/diff
strct=$base/$case/strct
status_vars_extra=""
status_vars_epi=""
t2xc=""
t2mask=""

# ----------------------------------------------------------
# Axis align and center DWI
dwixc_dwi=$dwiraw
dwixc=$diff/$case.dwixc.nrrd
# ----------------------------------------------------------

# ----------------------------------------------------------
# Axis align and center T1
t1xc_t1=$t1
t1xc=$strct/$case.t1xc.nrrd
# ----------------------------------------------------------

if [ -n "${t2-}" ]; then
    # ----------------------------------------------------------
    # Axis align and center T2
    t2xc_t2=$t2
    t2xc=$strct/$case.t2xc.nrrd
    # ----------------------------------------------------------
    status_vars_extra="$status_vars_extra t2xc"
fi

if [ -n "${T2MABS-}" ] && $T2MABS; then
    # ----------------------------------------------------------
    # T2 MABS mask
    # Inputs
    t2mabs_trainingcsv=${base}/trainingDataT2Masks.csv
    t2mabs_target="${t2xc-}"
    # Output
    t2mabs=$strct/$case.t2mabs.nrrd
    t2mask=$t2mabs
    status_vars_extra="$status_vars_extra t2mabs"
    if [ -n "${MABS_EDIT:-}" ] && $MABS_EDIT; then 
        t2mabs_edited=$strct/$case.t2mabs.edited.nrrd
        status_vars_extra="$status_vars_extra t2mabs_edited"
        t2mask=$t2mabs_edited
    fi
    # ----------------------------------------------------------

    # -----------------------------------------------------------------
    ## T1 mask registration
    # Input
    t1rigidmask_t2mask=$t2mabs
    t1rigidmask_t2="${t2xc-}"
    t1rigidmask_t1=$t1xc
    # Output
    t1rigidmask=$strct/$case.t1rigidmask.nrrd
    # -----------------------------------------------------------------
    t1mask=$t1rigidmask
    status_vars_extra="$status_vars_extra t1rigidmask"

else # T1MABS
    # ----------------------------------------------------------
    # T1 MABS mask
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
    t1mask=$t1mabs
    # ----------------------------------------------------------

    if [ -n "${t2-}" ]; then
    # -----------------------------------------------------------------
    ## T2 mask registration
    # Input
    t2rigidmask_t1mask=$t1mabs
    t2rigidmask_t1=$t1xc
    t2rigidmask_t2=$t2xc
    # Output
    t2rigidmask=$strct/$case.t2rigidmask.nrrd
    # -----------------------------------------------------------------
    t2mask=$t2rigidmask
    status_vars_extra="$status_vars_extra t2rigidmask"
    fi
fi

# ----------------------------------------------------------
# Freesurfer
# Inputs
fs_mask=$t1mask
fs_t1=$t1xc
# Output
fs=$strct/$case.freesurfer
# ----------------------------------------------------------

# ----------------------------------------------------------
# DWI eddy current correction
# Inputs:
dwied_dwi=$dwixc
# Output
dwied=$diff/$case.dwi-Ed.nrrd  
# ----------------------------------------------------------
dwiProcessed=$dwied

# ----------------------------------------------------------
# DWI mask
# Inputs:
dwibetmask_dwi=$dwied
# Output
dwibetmask=$diff/$case.dwibetmask.nrrd  
dwiedmask=$dwibetmask
dwiProcessedMask=$dwibetmask
if [ -n "${DWIMASK_EDIT:-}" ] && $DWIMASK_EDIT; then
    dwibetmask_edited=$diff/$case.dwibetmask.edited.nrrd  
    status_vars_extra="$status_vars_extra dwibetmask_edited"
    dwiedmask=$dwibetmask_edited
    dwiProcessedMask=$dwibetmask_edited
fi
# ----------------------------------------------------------

if [ -n "${EPICORRECTION-}" ] && $EPICORRECTION; then
    status_vars_epi="dwiepi dwiepimask"
    # ----------------------------------------------------------
    # DWI epi correction
    # Inputs
    dwiepi_dwi=$dwied
    dwiepi_dwimask=$dwiedmask 
    dwiepi_t2="$t2xc"
    dwiepi_t2mask=$t2mask
    # Output
    dwiepi=$diff/$case.dwi-epi.nrrd
    # ----------------------------------------------------------
    dwiProcessed=$dwiepi

    # ----------------------------------------------------------
    # DWI epi mask (for ukftractography seed map)
    # Input
    dwiepimask_dwi=$dwiepi
    # Output
    dwiepimask=$diff/$case.dwi-epi-mask.nrrd
    # ----------------------------------------------------------
    dwiProcessedMask=$dwiepimask
fi

# ----------------------------------------------------------
# UKF
# Inputs
ukf_dwi=$dwiProcessed
ukf_dwimask=$dwiProcessedMask 
# Output
ukf=$diff/$case.ukf_2T.vtk.gz
# ----------------------------------------------------------

# ----------------------------------------------------------
# Freesurfer to DWI registration
# Inputs
fsindwi_dwi=$dwiProcessed
fsindwi_dwimask=$dwiProcessedMask
fsindwi_fssubjectdir=$fs
if [ -n "${t2-}" ]; then
    fsindwi_t1=$t1xc
    fsindwi_t1mask=$t1mask
    fsindwi_t2=$t2xc  # fs2dwi.sh will generate a t2 mask
fi
# Output
fsindwi=$diff/$case.fsindwi.nrrd
# ----------------------------------------------------------

# ----------------------------------------------------------
# WMQL
# Inputs
wmqltracts_tractography=$ukf
wmqltracts_wmparc=$fsindwi
wmqltracts_query=wmql-2.0.txt
# Output
wmqltracts=$diff/$case.wmqltracts
# ----------------------------------------------------------

# ----------------------------------------------------------
# WMQL tract measures
# Inputs
tractmeasures_tracts=$wmqltracts
# Output
tractmeasures=$diff/$case.tractmeasures.csv
# ----------------------------------------------------------

# ----------------------------------------------------------
# WMQL tract volumes
# Inputs
tractvols_tracts=$wmqltracts
# Output
tractvols=$diff/$case.tractvols.csv
# ----------------------------------------------------------


# used by script 'logstatus', which writes 'statuslog.csv'
status_vars="\
    t1 \
    t1xc \
    dwiraw \
    dwixc \
    t1mask \
    fs \
    $status_vars_extra \
    dwied \
    dwiedmask \
    $status_vars_epi \
    ukf \
    fsindwi \
    wmqltracts \
    tractmeasures \
    tractvols \
    "
