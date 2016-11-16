#!/usr/bin/env python

import numpy as np
import nibabel as nib
from dipy.segment.mask import median_otsu
import sys

finput = sys.argv[1]
foutput = sys.argv[2]
print "Input: " + finput
print "Output: " + foutput

img = nib.load(finput)
data = np.squeeze(img.get_data())
b0_mask, mask = median_otsu(data, 2, 1)

mask_img = nib.Nifti1Image(mask.astype(np.float32), img.get_affine())
#b0_img = nib.Nifti1Image(b0_mask.astype(np.float32), img.get_affine())

nib.save(mask_img, foutput)
#nib.save(b0_img, fname + '_mask.nii.gz')
