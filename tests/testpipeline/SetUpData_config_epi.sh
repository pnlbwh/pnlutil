export FREESURFER_HOME=/projects/schiz/ra/eli/freesurfer5.3
export ANTSSRC=/projects/schiz/software/ANTS-git/
export ANTSPATH=/projects/schiz/software/ANTS-git-build2/bin/
export ANTSPATH_epi=/projects/schiz/software/deprecated/ANTs-1.9.y-Linux/bin/

EPICORRECTION=true
#EPICORRECTION=false

b=$base
source $threet/SetUpData.sh
t2=$t2masked 
base=$b
