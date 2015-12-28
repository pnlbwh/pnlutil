#!/usr/bin/env python

import vtk
import sys
infile=sys.argv[1]
outfile=sys.argv[2]

# Read vtk
pdr = vtk.vtkPolyDataReader()
pdr.SetFileName(infile)
pdr.Update()
out = pdr.GetOutput()
pd = out.GetPointData()

# Write vtk
pdw = vtk.vtkXMLPolyDataWriter()
#pdw.SetFileTypeToASCII()
#pdw.SetFileTypeToBinary()
pdw.SetDataModeToAscii()
pdw.SetFileName(outfile)
pdw.SetInput(out)
#pdw.SetInputData(out)
pdw.Write()
pdw.Update()
