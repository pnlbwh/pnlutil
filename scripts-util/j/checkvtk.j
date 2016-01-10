#!/usr/bin/env jc

loc=. 3 : '> (4!:4 <''y'') { 4!:3 $0'
SCRIPTDIR=. getpath_j_ jpath loc''
load SCRIPTDIR,'nrrd.ijs'
load SCRIPTDIR,'vtk.ijs'
require 'jmf'

USAGE=: 0 : 0
    checkvtk.j -t vtk -m mask -r ref
)
LPS2RAS=: 4 4 $ _1 0 0 0  0 _1 0 0  0 0 1 0  0 0 0 1
exitmsg=: (exit bind 1)@:echo
readpoints=: 3 : 0
    JCHAR map_jmf_ 'VTK';y
    pts=.getPointsBinary_vtk_ VTK
    unmap_jmf_'VTK'
    pts
)
dot=: +/ .*

Args=.{:"1 /:~ _2 ]\ 2 }. ARGV
(exitmsg bind USAGE)^:(3 ~: #) Args
([: exitmsg 'These arguments don''t exist:',":)^:(0 < #) (#~ -.@fexist) Args
'MASKFILE REFFILE VTKFILE'=. Args

Pointsijk=: |: <. 0.5 + (}: %. LPS2RAS dot getaffine_nrrd_ REFFILE) dot 1,~|:readpoints VTKFILE
Mask=: readnrrd MASKFILE
Sz=: $ Mask

Bincount=. {: |: /:~ (~. ,. #/.~) Mask {~ <@(0&>.)@((Sz-1)&<.)@|."1 Pointsijk
Pctzero=:100* ({. Bincount) % (# Pointsijk)

Hdr=:'NumPoints PointsTooSmall PointsTooBig NumZero NumMask PctZero'
Stats=: (Bincount , Pctzero) ,~ (# , (0 +/@:> ,) , ((|.Sz) +/@:,@:<: |:) ) Pointsijk

echo ','joinstring ;: Hdr
echo ' ,' rplc~ ": Stats

exit''
