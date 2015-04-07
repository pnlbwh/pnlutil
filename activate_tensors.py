#!/usr/bin/env python

import vtk
import sys

pdr = vtk.vtkPolyDataReader()
pdr.SetFileName(sys.argv[1])
pdr.Update()

out = pdr.GetOutput()
pd = out.GetPointData()

if pd is not None and pd.GetArray('tensor1') is not None:
	pd.SetTensors(pd.GetArray('tensor1'))


pdw = vtk.vtkPolyDataWriter()
#pdw.SetFileTypeToASCII()
pdw.SetFileTypeToBinary()
pdw.SetFileName(sys.argv[2])
pdw.SetInput(out)
#pdw.SetInputData(out)
pdw.Write()
pdw.Update()
