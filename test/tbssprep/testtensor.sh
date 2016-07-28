#!/bin/bash -eux

tensor=01251_FW_TensorNoNeg.nrrd

../../scripts-util/PNLTBSSprep --tensor $tensor --folder _out_tensoronly
