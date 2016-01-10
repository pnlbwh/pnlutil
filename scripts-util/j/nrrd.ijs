require 'dll'

coclass 'nrrd'

libteem=. IFUNIX{::'libteem.dll';('Darwin'-:UNAME){::'libteem.so';'libteem.dylib'
SZI=: IF64{4 8

NB. adverb to make a verb that throws error 11 (nonce) with error message
notImp=: 1 : '(13!:8)@:(11"_)@:smoutput@:(m"_)'

NB. Binary to J conversion verbs 
unknown=. 'Nrrd type is unkown' notImp
int1=: 'Signed 1 byte integer not implemented yet' notImp
uint1=: 'Unsigned 1 byte integer not implemented yet' notImp
int2=: _1 & ic  
uint2=: 0 & ic  
int4=: _2 & ic  
uint4=: 'Unsigned 4 byte integer not implemented yet' notImp
int8=: _3 & ic  
uint8=: 'Unsigned 8 byte integer not implemented yet' notImp
float4=: _1 & fc 
float8=: _2 & fc

int2j=: (-2+IF64) & ic   NB. 4 or 8 byte binary integer to J

NB. nrrdEnums.h: precision types 
NB.  nrrdTypeUnknown=0,     /*  0: signifies "type is unset/unknown" */
NB.  nrrdTypeDefault=0,     /*  0: signifies "determine output type for me" */
NB.  nrrdTypeChar,          /*  1:   signed 1-byte integer */
NB.  nrrdTypeUChar,         /*  2: unsigned 1-byte integer */
NB.  nrrdTypeShort,         /*  3:   signed 2-byte integer */
NB.  nrrdTypeUShort,        /*  4: unsigned 2-byte integer */
NB.  nrrdTypeInt,           /*  5:   signed 4-byte integer */
NB.  nrrdTypeUInt,          /*  6: unsigned 4-byte integer */
NB.  nrrdTypeLLong,         /*  7:   signed 8-byte integer */
NB.  nrrdTypeULLong,        /*  8: unsigned 8-byte integer */
NB.  nrrdTypeFloat,         /*  9:          4-byte floating point */
NB.  nrrdTypeDouble,        /* 10:          8-byte floating point */
NB.  nrrdTypeBlock,         /* 11: size user defined at run time; MUST BE LAST */
type2bytes=:0 1 1 2 2 4 4 8 8 4 8
binary_converters=: unknown`int1`uint1`int2`uint2`int4`uint4`int8`uint8`float4`float8 

nrrdNew=:libteem, ' nrrdNew > x'
nrrdLoad=:libteem, ' nrrdLoad i  x *c x'
NB. nrrdAxisInfoGet_nva(Nrrd *nrrd, int nrrdAxisInfoSize, size_t[] size);
nrrdAxisInfoGet_nva=:libteem, ' nrrdAxisInfoGet_nva n x i x '

NB. typedef struct { 
NB.     void *data; 
NB.     int type; 
NB.     unsigned int dim; 
NB.     ... 
NB. } Nrrd;
readnrrd=: 3 : 0
    filename=.y
    (filename, ' does not exist.') assert fexist filename
    nrrd_ptr=. nrrdNew cd ''
    nrrdLoad cd nrrd_ptr;filename;0
    data_ptr=. int2j memr nrrd_ptr,0,SZI

    NB. Skeptical that this will work on 32 bit machine 
    'type dimension'=. _2 ic memr nrrd_ptr,SZI,SZI 
    num_bytes=. type { type2bytes

    size_ptr=. mema SZI*16 NB. nrrd can have 16 dimensions
    nrrdAxisInfoGet_nva cd nrrd_ptr; 1; size_ptr
    size=. |. int2j memr size_ptr, 0, dimension*SZI

    data=. memr data_ptr, 0, num_bytes * (*/ size)
    size $ (binary_converters @. type) data
)
spacedir=: 3 : 0
    dirRaw=. > (#~ +./@('space direction'&E.)@>) 'b' fread y;0 900
    |: 3 3 $ do every 3 5 7 10 12 14  17 19 21 { ;: '-_' rplc~ dirRaw
)

origin=: 3 : 0
    originRaw=. > (#~ +./@('origin'&E.)@>) 'b' fread y;0 900
    do@> 3 5 7 { ;: '-_' rplc~ originRaw
)

getaffine=: 1 (<3;3)} (0,~spacedir,.origin)

readnrrd_z_=: readnrrd_nrrd_
origin_z_=: origin_nrrd_
spacedir_z_=: spacedir_nrrd_
getaffine_z_=: getaffine_nrrd_
