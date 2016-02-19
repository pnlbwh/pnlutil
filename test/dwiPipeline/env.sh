case=01010 
source $threet/SetUpData.sh
if uname -a | grep -q "bwh.harvard.edu"; then
    export ANTSPATH=/projects/schiz/software/ANTS-git-build/bin/
    export ANTSSRC=/projects/schiz/software/ANTS-git/
    export FREESURFER_HOME=/projects/schiz/ra/eli/freesurfer5.3
else
    export ANTSPATH=/data/pnl/soft/ANTs-build/bin/
    export ANTSSRC=/data/pnl/soft/ANTs/
    export FREESURFER_HOME=/data/pnl/soft/freesurfer5.3
fi
