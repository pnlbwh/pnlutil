#!/usr/bin/env python

import argparse
import sys
from os.path import basename, splitext, abspath, exists
from subprocess import Popen, PIPE, check_call
import re
import fileinput

def t(cmd):
    if isinstance(cmd, list):
        cmd = ' '.join(cmd)
    print "* " + cmd
    check_call(cmd, shell=True)

def nrrd_is_valid(nrrd):
    stdout, stderr = Popen('unu minmax %s' % nrrd, shell=True, stdout=PIPE,
                           stderr=PIPE).communicate()
    if 'trouble' in stdout:
        return False
    if 'trouble' in stderr:
        return False
    return True

def get_spc_dirs(s):
    match = re.search(
  'space directions: \((?P<xvec>(.*))\) \((?P<yvec>(.*))\) \((?P<zvec>(.*))\)',
        s)
    xvec = [float(x) for x in match.group('xvec').split(',')]
    yvec = [float(x) for x in match.group('yvec').split(',')]
    zvec = [float(x) for x in match.group('zvec').split(',')]
    # take transpose
    col1=[xvec[0],yvec[0],zvec[0]]
    col2=[xvec[1],yvec[1],zvec[1]]
    col3=[xvec[2],yvec[2],zvec[2]]
    return (col1, col2, col3)

def get_sizes(s):
    for line in s.splitlines():
        if "sizes:" in line:
            words = line.split()
            size_x, size_y, size_z = map(float, (words[1], words[2], words[3]))
            return (size_x, size_y, size_z)
    return (None, None, None)

def get_origin(s):
    for line in s.splitlines():
        if "space origin:" in line:
            return line
    return None


def get_hdr(nrrd):
    hdr, stderr = Popen(['unu', 'head', nrrd], stdout=PIPE,
                           stderr=PIPE).communicate()
    return hdr

def dot_product(v1, v2):
    return [a*b for (a,b) in zip(v1, v2)]

def centered_origin(hdr):
    spc_dirs = get_spc_dirs(hdr)
    sizes = get_sizes(hdr)
    print "space directions: " + str(spc_dirs)
    print "sizes: " + str(sizes)
    print get_origin(hdr)
    new_origin = []
    for dir in spc_dirs:
        dp = dot_product(sizes, dir)
        dp_abs = [abs(x) for x in dp]
        maxmin_elem = dp_abs.index(max(dp_abs))
        new_origin.append(-dp[maxmin_elem]/2 + (dp[maxmin_elem]/abs(dp[maxmin_elem]))*0.5)
    print "new origin: " + str(new_origin)
    return new_origin

def replace_line_in_file(afile, match_string, replace_with):
    for line in fileinput.FileInput(afile, inplace=1):
        if match_string in line:
            line = replace_with
        print line,

def main():
    argparser = argparse.ArgumentParser(description="Centers a nrrd.")
    argparser.add_argument('-i', '--infile', help='a 3d or 4d nrrd image', required=True)
    argparser.add_argument('-o', '--outfile', help='a 3d or 4d nrrd image', required=True)
    args = argparser.parse_args()

    image_in = abspath(args.infile)
    image_out = abspath(args.outfile)

    if not exists(image_in):
        print image_in + ' doesn\'t exist'
        sys.exit(1)
    if not nrrd_is_valid(image_in):
        print image_in + ' is not a valid nrrd'
        sys.exit(1)
    #if exists(args.outfile):
        #print args.outfile + ' already exists.'
        #print 'Delete it first.'
        #sys.exit(1)

    new_origin = centered_origin(get_hdr(image_in))
    t('unu save -e gzip -f nrrd -i %s -o %s' % (image_in, image_out))
    replace_line_in_file(image_out, "space origin: ", "space origin: (%s, %s, %s)\n" % tuple(new_origin))

if __name__ == '__main__':
    main()
