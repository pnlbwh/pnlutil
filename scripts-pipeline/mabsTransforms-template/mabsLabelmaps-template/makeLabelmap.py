#!/usr/bin/env python

import os
from math import exp
import glob
import subprocess
import argparse
from argparse import RawTextHelpFormatter

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
LABELMAP_GLOB = SCRIPTDIR+'/*-lblTrainingWarped.nrrd'

description="""
Computes the mutual information for each warped training image (read from %s/transforms.csv)
and applies a weighting function to the warped training labelmaps, adds them, and thresholds
at 50%.
"""
ALPHA_DEFAULT=0.45

def parseArgs():
    argparser = argparse.ArgumentParser(description=description,
        formatter_class=RawTextHelpFormatter)
    argparser.add_argument('-o', '--out', dest='lblOut', help="", required=True)
    argparser.add_argument('-a', '--alpha', dest='alpha', type=float, default=ALPHA_DEFAULT, help="", required=False)
    argparser.add_argument('-f', '--weightingFunc', dest='weightingFunc', help="", required=False)
    return argparser.parse_args()

def weightsFromMIExp(mis, alpha):
    factor = alpha/(max(mis) - min(mis))
    weights = [exp(factor*(min(mis) - mi)) for mi in mis]
    return [w/sum(weights) for w in weights]

def makeMask(lblOut, nrrds, weights):
    for (nrrd, w, i) in zip(nrrds, weights, range(len(nrrds))):
        if i == 0:
            run('unu 2op x %s %s | unu save -f nrrd -e gzip -o %s' % (nrrd,w,lblOut))
            continue
        run('unu 2op x %s %s | unu 2op + - %s | unu save -f nrrd -e gzip -o %s'%(nrrd,w,lblOut,lblOut))

def threshold(nrrd, t=0.5):
    run('unu 2op gt %s %f | unu save -e gzip -f nrrd -o %s' % (nrrd, t, nrrd))

def run(cmd):
    print cmd
    os.system(cmd)

if __name__ == '__main__':
   args = parseArgs()
   with open(SCRIPTDIR + '/MI.txt') as f:
       mis = [float(line.strip()) for line in f]
   lablemaps = glob.glob(LABELMAP_GLOB)
   weights = weightsFromMIExp(mis, args.alpha)
   print "Apply weights to warped training labelmaps and add to make mask"
   makeMask(args.lblOut, lablemaps, weights)
   threshold(args.lblOut)
   print "Made mask: " + args.lblOut
