#!/bin/bash -eu

# For this script, You will need a mean_FA.nii.gz file.
# Moreover, You may need to adjust this script with the name of Your statistics file. 

usage() {
    echo -e "\
This script helps visualize the results of TBSS.  Run it in the directory
with TBSS statistic files and the mean_FA.nii.gz.

Usage:
    ${0##*/} 
"
}

[ $# -eq 0 ] || { usage; exit 0; }

for i in tbss*tfce*; do
	ID=$(basename $i '.nii.gz')
	echo "filling $i"
	tbss_fill $i 0.95 mean_FA zzfilled-$i
	echo "overlaying $i"
	overlay 0 0 mean_FA.nii.gz -a zzfilled-$i 0.1 1 zzoverlaid$i
	echo "slicing $i"
	/projects/schiz/software/fsl-5.0.4-64bit/bin/slicer zzoverlaid$i.nii.gz -S 5 1000 visualized-$ID.png
	#rm *zzoverlaid* *zzfilled*
done
