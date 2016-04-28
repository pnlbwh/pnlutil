## Summary

This an implementation of the PNL's INTRuST pipeline using the lightweight
build system [`redo`](https://github.com/mildred/redo).  To run the pipeline,
you specify the file paths of your T1's and DWI's in a config file and then run
`redo`.  Currently, the following outputs are generated:

```
<case>/
   - diff/
      - <case>.dwi-Ed.nrrd
      - <case>.dwibetmask.nrrd
      - (<case>.dwi-epi.nrrd)     # if EPI correction turned on
      - (<case>.dwi-epi-mask.nrrd) # if EPI correction turned on
      - <case>.ukf_2T.vtk.gz
      - <case>.wmqltracts/
      - <case>.fsindwi.nrrd
      - <case>.tractmeasures.csv
      - <case>.tractvols.csv
   - strct/
      - <case>.t1mabs.nrrd
      - <case>.freesurfer/
```

## Software Requirements

The intrust pipeline requires the following software be installed on your on
your system.

### System Software 

These should already be installed on standard linux/mac distributions. 

* Bash
* Python 2.7 (you will need to install this if your system only comes with 2.6)

### Software Packages
* Freesurfer (http://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall)
* FSL bet (http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL)
* redo (https://github.com/mildred/redo)
* pnlutil (https://github.com/pnlbwh/pnlutil)
* tract-querier (https://github.com/demianw/tract_querier)
* measureTracts.py (https://github.com/pnlbwh/measuretracts)
* ConvertBetweenFileFormats (https://github.com/BRAINSia/BRAINSTools)
* TEEM unu (http://teem.sourceforge.net/unrrdu/)
* ukftractography (https://github.com/pnlbwh/ukftractography)
* ANTs (https://github.com/stnava/ANTs)


### Installation

To install FSL and Freesurfer, follow the instructions on their websites:

    http://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall
    http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FSL

For the rest of the software, automated installation scripts are provided 
by pnlutil.

    git clone https://github.com/pnlbwh/pnlutil
    cd install-software  # or wherever you want to install the software
    all.sh  # downloads and compiles software in the current directory
    source addpaths.sh  # adds the software's binaries and scripts to your PATH


## Setup

Once all the prerequiste software is installed you're ready to make an instance
of the pipeline for your project.  You do this by running `mkpipeline.sh`:

    mkpipeline.sh /path/to/my/project

This copies the files from `pipeline/` to your project folder.  Once this is
done you need to make two files, `SetUpData_config.sh`, which needs the file
paths to your T1's and DWI's, and `caselist.txt`, a text file with a list of
your case id's, one per line.  For the former, use
`SetUpData_config.sh.example` in your project folder as a template.

## Run

Now you are ready to execute the pipeline.  You are free to run the complete
pipeline or just parts of it on your whole caselist or subsets of your
caselist.  Note that the query scripts `missing`, `all`, and `completed`, the
status scripts `logstatus`, `showstatus` and `casestatus`, and the quality
control scripts `qclabels` and `qc`, are from the `pnlutil` repository. 

Examples:

    redo  # Run whole pipeline for all cases
    redo 001.all  # Run whole pipeline for case '001'
    casestatus 001 # Print what files are generated so far for case '001'
    missing t1mabs  # Print a list of the t1 masks not yet generated
    redo `missing t1mabs`  # Generate all the missing masks
    completed t1mabs  # Print a list of the completed t1 masks
    redo `missing fs | head -n 2`  # Run freesurfer for the first 2 cases not yet generated
    redo `missing dwied` # Generate eddy current corrected DWI's
    redo `missing dwibetmask`  # Generated DWI masks
    redo `missing ukf` # Generate whole brain tractography 
    redo `missing fsindwi`  # Generate freesurfer labelmap in DWI space
    redo `missing wmql` # Generate wmql tracts (uses the queries in wmql_query.txt)

You don't need to run these separately, any missing dependencies will be
generated automatically.  For example, running 

    redo -k `missing wmql` 

without any of the preceding commands will first generate `fsindwi` and `ukf`,
which in turn will first generate `dwied`, `dwibetmask`, and `fs`, which in
turn will first generate `t1mabs`.  So this runs the whole pipeline.  The
`-k` flag means keep going if a target fails to build.

More Examples:

    all -f caselist_qc_ukf.txt ukf  # Print a list of tractography files for cases in 'caselist_qc_ukf.txt'
    redo `all -f caselist_qc_ukf.txt ukf` # Generate tractography files for cases only in 'caselist_qc_ukf.txt'
    all dwied 001 002 003  # Print a list of DWI's for cases 001, 002, 003
    redo `all dwied 001 002 003`  # Generate DWI's for cases 001, 002, 003

To log the progress of the pipeline:

    logstatus  # saves status to 'statuslog.csv'

To show the last logged entry in `statuslog.csv`:

    showstatus

To show the status of a particular case:

    casestatus 001

To visually inspect and QC the results:

    qc -h  # show you the options
    qc -r dwied -q fsindwi  # Loads each case's DWI and freesurfer map into Slicer, one case at a time
    qc -l "001 002" -r t1align -q fs  # Load t1 as reference image and freesurfer segmentation as image to be QC'ed for cases 001 and 002
    qc -f caselist_notchecked_wmql -r dwied -q wmql  # Load DWI's and wmql tracts for cases in 'caselist_notchecked_wmql'

Finally, to generate a montage of image slices with a labelmap overlay:

    qclabels t1align t1mabs t1mabs.png
    qclabels dwied fsindwi fsindwi.png
    # see 'qclabels -h' on how to adjust the slice axis and dimension size
    # Note: doesn't work so well on DWI's right now
