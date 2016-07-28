#!/bin/bash -eux

dwi=../pipelineTestData/023_NAA_006-dwi-Ed.nhdr

../../scripts-util/PNLTBSSprep --DWI $dwi --folder _out
