#!/bin/env python
#
# Dependencies:
#  ConvertBetweenFileformats
#  tract_querier, numpy, nibabel

import optparse
from optparse import OptionParser

def run(cmd):
    print cmd
    os.system(cmd)

example="""Example use:
case=006_ACT_002 && source SetUpData.sh
bse $dwied /tmp/bse.nrrd
checkvtk.py -m $dwimask -t $ukf -r $dwied
"""

if __name__ == "__main__":
    print example
    parser = OptionParser(
            description='''\
Checks the overlap between a vtk and a mask (or labelmap), by printing the \
number of vtk points that pass through each label, usually 0 and 1.''',
        usage=" %prog -m mask -t vtk")

    parser.add_option("-t", dest="vtk", help="whole brain tractography vtk")
    parser.add_option("-m", dest="mask", help="mask (nrrd or nifti)")
    parser.add_option("-r", dest="ref", help="image from which to get affine (nrrd or nifti)")
    (options, args) = parser.parse_args()

    if not options.vtk or not options.mask:
        parser.error("missing vtk or mask")

    # Convert to nifti if inputs are nrrds
    if options.mask.endswith('.nrrd') or options.mask.endswith('.nhdr'):
        import tempfile
        import os
        cleanup = True
        dirTmp=tempfile.mkdtemp()
        maskNii = dirTmp + "/mask.nii.gz"
        run("ConvertBetweenFileFormats %s %s >/dev/null" % (options.mask, maskNii))
        if options.ref and options.ref.endswith('.nrrd') or options.ref.endswith('.nhdr'):
            cleanup = True
            refNii = dirTmp + "/ref.nii.gz"
            run("ConvertBetweenFileFormats %s %s >/dev/null" % (options.ref, refNii))
        else:
            refNii = options.ref
    else:
        maskNii = options.mask

    import tract_querier as tq
    import nibabel as nb
    import numpy as np
    import sys

    # Load images and get affine
    mask=nb.load(maskNii)
    mask_data=mask.get_data()
    if options.ref:
        ref=nb.load(refNii)
        aff=ref.get_affine()
        print "Getting affine from " + refNii
    else:
        print "Getting affine from " + maskNii
        aff=mask.get_affine()
    print "Will use the inverse of this affine to put vtk points in ijk space:"
    print aff

    # Get vtk points in ijk space
    tr = tq.tractography.tractography_from_file(options.vtk)
    points=np.vstack(tr.tracts())
    w2i=np.linalg.inv(aff)
    pointsijk=np.round((np.dot(w2i[:-1, :-1], points.T).T + w2i[:-1, -1])).astype(int)

    # Check that vtk points are inside volume
    if ( any(((pointsijk[:, i] >= mask_data.shape[i]).any() for i in xrange(3))) or
     (pointsijk < 0).any()):
        print "FAIL: Tract points fall outside the image"
        sys.exit(1)

    # Check that
    labels = mask_data[tuple(pointsijk.T)]
    unique, counts = np.unique(labels, return_counts=True)
    print
    print "Bin count of labelmap values that all tracts pass through:"
    print np.asarray((unique, counts)).T

    # Clean up
    if cleanup:
        import shutil
        shutil.rmtree(dirTmp)

