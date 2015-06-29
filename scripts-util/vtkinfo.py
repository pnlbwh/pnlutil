#!/usr/bin/env python

import vtk
import sys

# Read vtk
pdr = vtk.vtkPolyDataReader()
pdr.SetFileName(sys.argv[1])
pdr.Update()
polydata = pdr.GetOutput()
pointdata = polydata.GetPointData()

# print array info
numArrays = pointdata.GetNumberOfArrays()
print "Number of PointData arrays: %i " % numArrays
for i in range(numArrays):
    print "Array index: %i| name: %s | type: %s" % (i, pointdata.GetArrayName(i), pointdata.GetArray(i).GetDataType())

# print tensor info
print "Tensor name: %s" % pdr.GetTensorsNameInFile(0)
