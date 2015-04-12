source ../util.sh

export FREESURFER_HOME=/projects/schiz/ra/eli/freesurfer5.3
export ANTSPATH=/projects/schiz/software/ANTS-git-build2/bin/
export ANTSSRC=/projects/schiz/software/ANTS-git/

case=01010 && source $threet/SetUpData.sh
output=output && mkdir -p $output
