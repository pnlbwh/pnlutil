# Requires:
#   tract_math

case=${2##*/}
redo-ifchange $case.tracts

echo "Making '$1'"
header="case,tract,tract volume"
echo "$header" > $3
for tract in $case.tracts/*.vtk; do
    vol=$(tract_math $tract tract_volume 1 | sed -n 2p)
    echo "$case,$tract,$vol" >> $3
done
echo "Made '$1'"
