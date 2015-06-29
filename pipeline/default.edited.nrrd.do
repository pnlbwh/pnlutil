#!/bin/bash -eu

dependency=$2.nrrd
redo-ifchange $dependency
echo -e "
'$dependency' is now ready to be manually edited.  Once you're done editing, save it as
'$2.edited.nrrd', and re-run the pipeline.
"
exit 1
