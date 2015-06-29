#!/usr/bin/env python

"""
Eddy correction, Motion correction via registration, NO NOISE FILTERING
of each gradient direction volume to the first (should be baseline)

Dependencies:
    - unu
    - fsl
    - ConvertBetweenFileFormats
    - numpy
"""
import sys
import os
import glob
import shutil
import numpy as np
import tempfile

rootdir = os.getcwd()
args = sys.argv;
if '-h' in args or '--help' in args or len(args) == 1:
    print 'dwiPipeline.py input output'
    print 'by convention, PNL calls the output CASE-dwi-Ed.nhdr'
    sys.exit(1)
input = args[1]
output = args[2]

wdir = tempfile.mkdtemp()

#Save the file as gzip in temp directory
os.system('unu save -f nrrd -e gzip -i '+input+' -o '+wdir+'/dwijoined.nhdr')

os.chdir(wdir)

# this is where the noise filtering goes in the script which does it as well

sys.stderr.write('Dice the volume\n')
os.system('unu convert -t int16 -i dwijoined.nhdr | unu dice -a 3 -o Diffusion-G')

sys.stderr.write('Convert to Nifty\n')
files = glob.glob('Diffusion-G*.nrrd')
files.sort()
ref = files[0].replace('.nrrd','')
for fnrrd in files:
    fnii = fnrrd.replace('nrrd','nii.gz')
    sys.stderr.write('Convert to Nifti\n')
    #os.system('/projects/schiz/software/bin_linux64/magicScalarFileConvert --outputtype short '+
              #fnrrd+' '+fnii)
    #os.system('magicScalarFileConvert --outputtype short ' + fnrrd + ' ' + fnii)
    os.system('ConvertBetweenFileFormats ' + fnrrd + ' ' + fnii + ' short')
    f = fnii.replace('.nii.gz','')
    sys.stderr.write('Run FSL flirt affine registration\n')
    os.system('flirt -interp sinc -sincwidth 7 -sincwindow blackman -in '+
              f+' -ref '+ref+' -nosearch -o '+f+' -omat '+f+'.txt -paddingsize 1')
os.system('fslmerge -t EddyCorrect-DWI Diffusion-G*.nii.gz')

#Get the resulting Transforms
Transforms = glob.glob('Diffusion-G*.txt')
Transforms.sort()

sys.stderr.write('Extract the rotations and realign the gradients\n')
fd = open('dwijoined.nhdr')
gDir = []
header=''
gNum = []
gframe = []
for line in fd:
    if line.find('DWMRI_gradient_')!=-1:
        gNum.append(line[15:19])
        gDir.append( map(float,line[21:-1].split()) )
    elif line.find('data file:')!=-1:
        header = header+'data file: EddyCorrect-DWI.nii.gz\n'
    elif line.find('encoding:')!=-1:
        header = header+line+'byteskip: -1\n'
    elif line.find('measurement frame:')!=-1:
        header = header+line
        mf =  np.matrix([map(float,line.split()[2][1:-1].split(',')),map(float,line.split()[3][1:-1].split(',')),map(float,line.split()[4][1:-1].split(','))])
    elif line.find('space:')!=-1:
        header = header+line
        # Here I assume either lps or ras so only need to check the first letter
        space = line.split()[1][0]
        if (space=='l')|(space=='L'):
            spctoras = np.matrix([[-1, 0, 0], [0,-1,0], [0,0,1]])
        else:
            spctoras = np.matrix([[1, 0, 0], [0,1,0], [0,0,1]])
    else:
        header = header+line
fd.close()

fd = open('EddyCorrect-DWI.nhdr','w')
fd.write(header)
i=0
# Transforms are in RAS so need to do inv(MF)*inv(SPC2RAS)*ROTATION*SPC2RAS*MF*GRADIENT
mfras = mf.I*spctoras.I
rasmf = spctoras*mf
for t in Transforms:
    tra = np.loadtxt(t)
    #removes the translation
    aff = np.matrix(tra[0:3,0:3])
    # computes the finite strain of aff to get the rotation
    rot = aff*aff.T
    # Computer the square root of rot
    [el, ev] = np.linalg.eig(rot)
    eL = np.identity(3)*np.sqrt(el)
    sq = ev*eL*ev.I
    # finally the rotation is defined as
    rot = sq.I*aff
    newdir = np.dot(mfras*rot*rasmf,gDir[i])
    fd.write('DWMRI_gradient_'+gNum[i]+':= '+str(newdir[0,0])+' '+str(newdir[0,1])+' '+str(newdir[0,2])+'\n')
    i = i+1
fd.close()

os.chdir(rootdir)
os.system('unu save -f nrrd -e gzip -i '+wdir+'/EddyCorrect-DWI.nhdr -o '+output)

sys.stderr.write('Clean up\n')
#shutil.rmtree(wdir)

