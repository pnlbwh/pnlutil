#!/usr/bin/env python

import argparse
from subprocess import Popen, PIPE, check_call
from os.path import basename, splitext, abspath, exists
import sys
import operator


def t(cmd):
    if isinstance(cmd, list):
        cmd = ' '.join(cmd)
    print "* " + cmd
    check_call(cmd, shell=True)


def nrrd_is_valid(nrrd):
    stdout, stderr = Popen('unu minmax "%s"' % nrrd, shell=True, stdout=PIPE,
                           stderr=PIPE).communicate()
    if 'trouble' in stdout or 'trouble' in stderr:
        return False
    return True

def read_hdr(nrrd):
    hdr, stderr = Popen(['unu', 'head', nrrd], stdout=PIPE,
                           stderr=PIPE).communicate()
    return hdr

def get_grad_dirs(hdr):
    return [map(float, line.split('=')[1].split())
            for line in hdr.splitlines()
            if 'DWMRI_gradient' in line]

def get_bval(hdr):
    for line in hdr.splitlines():
        if 'b-value' in line:
            return float(line.split('=')[1])

def get_b0_index(hdr):
    bval = get_bval(hdr)
    bvals = [norm(gdir)*bval for gdir in get_grad_dirs(hdr)]
    idx, min_bval  = min(enumerate(bvals), key=operator.itemgetter(1))
    print "Found B0 of " + str(min_bval) + " at index " + str(idx)
    return idx


def norm(vector):
    return sum([v**2 for v in vector])


def main():
    argparser = argparse.ArgumentParser(
        description="Extracts the baseline (b0) from a nrrd DWI.  Assumes \
        the diffusion volumes are indexed by the last axis.")

    argparser.add_argument('-m'
                           ,'--mask'
                           , help='DWI mask'
                           , required=False)

    argparser.add_argument('-i'
                           ,'--infile'
                           , help='DWI nrrd image'
                           , required=True)

    argparser.add_argument('-o'
                           ,'--outfile'
                           , help='B0 nrrd image'
                           , required=True)

    args = argparser.parse_args()
    dwi = abspath(args.infile)
    out = abspath(args.outfile)
    if not exists(dwi):
        print dwi + ' doesn\'t exist'
        sys.exit(1)


    if args.mask:
	dwimask = abspath(args.mask)
        if dwimask and not exists(dwimask):
            print dwimask + ' doesn\'t exist'
            sys.exit(1)

    hdr = read_hdr(dwi)
    idx = get_b0_index(hdr)
    if args.mask:
        t("unu slice -a 3 -p " + str(idx) +
              " -i " + dwi + " | unu 3op ifelse -w 1 " +
          dwimask + " - 0 | unu save -e gzip -f nrrd -o " + out)
    else:
        t("unu slice -a 3 -p " + str(idx) +
              " -i " + dwi + " | unu save -e gzip -f nrrd -o " + out)


if __name__ == '__main__':
    main()
