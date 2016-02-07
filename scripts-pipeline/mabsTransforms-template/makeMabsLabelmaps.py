#!/usr/bin/env python

import os
from math import exp
import csv
import subprocess
import argparse
from argparse import RawTextHelpFormatter
import sys
import shutil

SCRIPTDIR = os.path.dirname(os.path.realpath(__file__))
CSV = SCRIPTDIR + '/transforms.csv'
OBJ = SCRIPTDIR + '/mabsLabelmaps-template/'
MI = SCRIPTDIR + '/MI.txt'


description="""
"""

def parseArgs():
    argparser = argparse.ArgumentParser(description=description,
        formatter_class=RawTextHelpFormatter)
    argparser.add_argument('-o', '--out', dest='dirOut', help="", required=True)
    argparser.add_argument('-t', '--training', dest='txtTrainingLabelmaps', help="", required=True)
    return argparser.parse_args()


def checkEnv():
    exit = False
    if not os.environ.get('ANTSPATH', None):
        print "Set ANTSPATH environment variable first (the directory that has the ANTS binaries)"
        exit = True
    if not os.environ.get('ANTSSRC', None):
        print "Set ANTSSRC environment variable first (the ANTS folder that has subdirectory 'Scripts/')"
        exit = True
    if exit:
        sys.exit(1)


def linecount(filepath):
    with open(filepath) as f:
        return sum(1 for line in f)

def warp(moving, xfm, fixed, out):
    run("$ANTSPATH/antsApplyTransforms -d 3 -i %s -o %s -r %s -t %s" % (moving, out, fixed, xfm))
    run("unu save -e gzip -f nrrd -i %s -o %s" % (out, out))

def warpLabelmaps(txt, dirOut):
    with open(CSV) as f:
        rows = [row for row in csv.DictReader(f)]
    with open(txt) as f:
        labelmaps = [line.strip() for line in f]
    for (lbl, row, i) in zip(labelmaps, rows, range(len(rows))):
       warp(lbl, row['xfm'], row['imgTarget'], dirOut + "/%02d-lblTrainingWarped.nrrd"%i)


def run(cmd):
    print cmd
    os.system(cmd)


def checkArgs(args):
    if linecount(CSV) != 1+linecount(args.txtTrainingLabelmaps):
       print "input text file must have the same number of labelmaps as training images used"
       sys.exit(1)
    if os.path.exists(args.dirOut):
        print "Out dir already exists"
        sys.exit(1)

def getMIs():
    with open(CSV) as f:
        return [row['MI'] for row in csv.DictReader(f)]

if __name__ == '__main__':
    args = parseArgs()
    checkEnv()
    checkArgs(args)
    shutil.copytree(OBJ, args.dirOut)
    shutil.copy(args.txtTrainingLabelmaps, args.dirOut)
    with open(args.dirOut+'/MI.txt', 'w') as f:
        for mi in getMIs():
            f.write('%s\n'% str(mi))
    warpLabelmaps(args.txtTrainingLabelmaps, args.dirOut)
    with open(args.dirOut+'/log', 'w') as f:
        f.write('Created from ' + SCRIPTDIR + '\n')
