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

def run(cmd):
    sys.stdout.write(cmd+'\n')
    os.system(cmd)

def log(s):
    sys.stderr.write(s + '\n')

def registerDirs(nrrd, dirOut):
    cwd = os.getcwd()
    os.chdir(dirOut)
    log('Dice the volume')
    run('unu convert -t int16 -i %s | unu dice -a 3 -o Diffusion-G' % nrrd)

    files = glob.glob('Diffusion-G*.nrrd')
    files.sort()
    #ref = files[0].replace('.nrrd','')
    ref = files[0]
    for nrrd in files:
        #fnii = fnrrd.replace('nrrd','nii.gz')
        #sys.stderr.write('Convert to Nifti\n')
        #os.system('/projects/schiz/software/bin_linux64/magicScalarFileConvert --outputtype short '+
                  #fnrrd+' '+fnii)
        #os.system('magicScalarFileConvert --outputtype short ' + fnrrd + ' ' + fnii)
        #os.system('ConvertBetweenFileFormats ' + fnrrd + ' ' + fnii + ' short')
        #f = fnii.replace('.nii.gz','')
        #sys.stderr.write('Run FSL flirt affine registration\n')
        #os.system('flirt -interp sinc -sincwidth 7 -sincwindow blackman -in '+
                  #f+' -ref '+ref+' -nosearch -o '+f+' -omat '+f+'.txt -paddingsize 1')
        pre = nrrd.replace('.nrrd','')
        warpednii = pre + "Warped.nii.gz"
        warped = pre + "Warped.nrrd"
        run("$ANTSSRC/Scripts/antsRegistrationSyN.sh -d 3 -f %s -m %s -t r -o %s" %
                (ref, nrrd, pre))
        run("ConvertBetweenFileFormats %s %s short" % (warpednii, warped))
    warpednrrds = glob.glob("*Warped.nrrd")
    warpednrrds.sort()
    for nrrd in warpednrrds:
        run("unu save -e gzip -f nrrd -i %s -o %s" % (nrrd, nrrd))
    run("unu join -a 3 -i " + ' '.join(warpednrrds) + " | unu save -e gzip -f nrrd -o EddyCorrect-DWI.nhdr")
    #os.system('fslmerge -t EddyCorrect-DWI Diffusion-G*.nii.gz')
    os.chdir(cwd)
    transforms = glob.glob(dirOut+'/*.mat')
    transforms.sort()
    return transforms

if __name__ == '__main__':
    rootdir = os.getcwd()
    args = sys.argv;
    if '-h' in args or '--help' in args or len(args) != 3:
        print 'dwiPipeline.py dwiIn dwiOut'
        print 'by convention, PNL calls the output CASE-dwi-Ed.nhdr'
        sys.exit(1)
    dwiIn = args[1]
    dwiOut = args[2]

    dirOutput = os.path.splitext(dwiOut)[0] + '-xfms'

    #dirTmp = tempfile.mkdtemp()
    #dirTmp="/tmp/629159.tmpdir/tmpNILbWW"
    dirTmp='tmpdir'
    if not os.path.exists(dirTmp):
        os.makedirs(dirTmp)
    #registerDirs(dwiIn, dirTmp)
    transforms = glob.glob(dirTmp+'/*.mat')
    transforms.sort()
    run('unu save -f nrrd -e gzip -i '+dwiIn+' -o '+dirTmp+'/dwiInput.nhdr')

    log('Extract the rotations and realign the gradients')
    gDir = []
    header=''
    gNum = []
    gframe = []
    with open(dirTmp+'/dwiInput.nhdr') as fd:
        for line in fd:
            if 'DWMRI_gradient_' in line:
                gNum.append(line[15:19])
                gDir.append( map(float,line[21:-1].split()) )
            elif 'data file:' in line:
                header += 'data file: EddyCorrect-DWI.raw.gz\n'
            elif 'encoding' in line:
                header += line+'byteskip: -1\n'
            elif 'measurement frame:' in line:
                header += line
                mf =  np.matrix([map(float,line.split()[2][1:-1].split(',')),map(float,line.split()[3][1:-1].split(',')),map(float,line.split()[4][1:-1].split(','))])
            elif 'space:' in line:
                header += line
                # Here I assume either lps or ras so only need to check the first letter
                space = line.split()[1][0]
                #if (space=='l')|(space=='L'):
                    #spctoras = np.matrix([[-1, 0, 0], [0,-1,0], [0,0,1]])
                #else:
                    #spctoras = np.matrix([[1, 0, 0], [0,1,0], [0,0,1]])
            else:
                header += line

    with open(dirTmp+'/EddyCorrect-DWI.nhdr','w') as fd:
        fd.write(header)
        i=0
        # Transforms are in RAS so need to do inv(MF)*inv(SPC2RAS)*ROTATION*SPC2RAS*MF*GRADIENT
        #mfras = mf.I*spctoras.I
        #rasmf = spctoras*mf
        for matTransform in transforms:
            txtTransform = matTransform.replace(".mat", ".txt")
            run("$ANTSPATH/ConvertTransformFile 3 %s %s --hm" % (matTransform, txtTransform))
            tra = np.loadtxt(txtTransform)
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
            #newdir = np.dot(mfras*rot*rasmf,gDir[i])
            newdir = np.dot(rot,gDir[i])
            fd.write('DWMRI_gradient_'+gNum[i]+':= '+str(newdir[0,0])+' '+str(newdir[0,1])+' '+str(newdir[0,2])+'\n')
            i = i+1

    #os.chdir(rootdir)
    os.system('unu save -f nrrd -e gzip -i '+dirTmp+'/EddyCorrect-DWI.nhdr -o '+dwiOut)
    if not os.path.exists(dirOutput):
        os.mkdir(dirOutput)
    os.system('cp '+dirTmp+'/*.txt '+dirOutput)

    #sys.stderr.write('Clean up\n')
    #shutil.rmtree(dirTmp)
