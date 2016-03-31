tmp=$(mktemp)
csvcat `completed tractmeasures` > $tmp
head -n 1 $tmp > $3
grep -E "_cc\.|_af|_slf|_uf|_ioff|_ilf|_cb" $tmp | sed 's|,.*/|,|' | sed 's|.vtk||' >> $3
