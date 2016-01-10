cocurrent 'vtk'

splitat=: taketo ; takeafter

getHdr=: (LF&taketo)@:dropto 

getPointsBinary=: 3 : 0
  Hdr=. 'POINT' getHdr 400 {. y NB. assume in first 200 bytes
  'Field NumTuples Type'=. ;: Hdr
  BinIdx=. (>:#Hdr) + # 'POINT' taketo y
  NumTuples=. do NumTuples
  select. Type 
  case. 'double' do. 
    Sz=.8
    byte2j=. _2&fc
  case. 'float' do. 
    Sz=.4
    byte2j=. _1&fc
  end.
  BinData=. BinIdx }. (BinIdx+Sz*NumTuples*3) {. y
  _3 ]\ byte2j&.|. BinData
)

splittract=:(({. {. }.);({. }. }.))
splitlast=:(}: , splittract@>@:{:)

getLinesBinary=: 3 : 0
  NB. 'Line Data'=:LF splitat 'LINES' takeafter y
  Hdr=. 'LINE' getHdr y
  BinIdx=. (>:#Hdr) + # 'LINE' taketo y
  'NumLines NumItems'=: {. do every }. ;:Hdr
  SzInt=.4
  BinData=. BinIdx }. (BinIdx+SzInt*NumItems) {. y
  Data=:_2&ic&.|. BinData
  FretIdx=:}: (+ >:@:({&Data))^:((#Data) > ])^:a: ] 0
  <;._1 (_ FretIdx} Data)
)

getTractsBinary=: 3 : 0
    pts=.getPointsBinary y
    ({&pts)each getLinesBinary y
)

vtkReadPoly=: getTractsBinary@:fread

NB. === export functions
vtkReadPoly_z_=: vtkReadPoly_vtk_
getPointsBinary_z_=: getPointsBinary_vtk_
getTractsBinary_z_=: getTractsBinary_vtk_
