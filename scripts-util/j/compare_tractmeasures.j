#!/usr/bin/env jc

loc=. 3 : '> (4!:4 <''y'') { 4!:3 $0'
SCRIPTDIR=. getpath_j_ jpath loc''

load SCRIPTDIR,'vtk.ijs'
load'regex csv'

mean=:+/ % #
getcol=:}.@:([ {"1~ (i.~ {.)~)
tonum=. ".every
removeid=: ('^[[:digit:]]{3}_[[:digit:][:alpha:]]{3}_[[:digit:][:alpha:]]{3}(-time.)?_';'')&rxrplc
tractcol=. (removeid each)@:(getcol&(<'tract'))
addcol=: (<@[ ,.~ ])each
has=: +./@:rxE
exitWhen=: 2 : 0
if. y do.
    echo x
    exit''
end.
)

fcsvs=. 2 }. ARGV
echo 'Input csvs: ', ' ' joinstring fcsvs
'At least one csv is needed' exitWhen (0 = #fcsvs)
'One or all of the csvs don''t exist' exitWhen (-.@*.@fexist every fcsvs)

echo 'Read csvs'
csvs=. readcsv each fcsvs
echo 'Dimensions: ', ": $ each csvs

echo 'Get stats'
Stats=:/:~@:(~.@:tractcol ,. tractcol <"0@(#,mean)/. tonum@:getcol&('num_fibers-num_fibers';'FA-mean';'FA-stDev')) each csvs

GroupedStats=./:~ ({."1 </. ]) ; fcsvs addcol Stats
Header=: ;: 'Bundle numCases numTractsAvg meanFaAvg stDevFAAvg InputCsv'
Result=. Header , }. ; a:&,each  (#~ 'cb|uf|af|slf|ilf|ioff'&has@:,@:(":@>)@>) GroupedStats
'wmql_comparison.csv' writecsv~ Result

exit''
