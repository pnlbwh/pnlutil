csvcat `completed tractvols` | sed 's|,.*/|,|' | sed 's|.vtk||' > $3
