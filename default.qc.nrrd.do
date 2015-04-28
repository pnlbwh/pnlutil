#!/bin/bash -eu

dependency=$2.nrrd

if [ -f $2.qcfail.nrrd ]; then
    echo "'$dependency already QC'ed and rejected (i.e. '$2.qcfail.nrrd' exists), skipping this case"
else # $dependency.qc.nrrd doesn't exist
    redo-ifchange $dependency
    echo -e "'$dependency' is now ready to be QC'ed, check it and when done run 
    
    qcaccept $dependency  # makes '$2.qc.nrrd' and stamps its header, pipeline will continue for this case

or

    qcreject $dependency # makes '$2.qcfail.nrrd' and stamps its header, pipeline will not continue for this case

and then restart the pipeline."
fi

exit 1
