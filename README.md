Together with some prequisite software, these bash and python scripts implement
the [PNL](http://pnl.bwh.harvard.edu)'s diffusion and structural MRI processing
pipelines.  Given a DWI, T1w, and optionally a T2w image, the scripts generate
a motion corrected DWI, T1w mask, freesurfer segmentation and freesurfer stats
csv, freesurfer segmentation registered to DWI, whole brain tractography,
extracted fiber bundles, and extracted fiber bundle measures.  And because they
are modular, you can run them individually or as a complete pipeline.

# Table of Contents

1. [Install](#install)
1. [Quick Walkthrough](#quick-walkthrough)
2. [Pipeline Scripts Overview](#pipeline-scripts-overview)
3. [Redo Overview](#redo-overview)
4. [PNL Pipeline Implementation](#pnl-pipeline-implementation)
5. [Repo Organization](#repo-organization)
6. [Issues](#issues)

# Install

The pipeline requires that you have the following software packages pre-installed:

1. Freesurfer (https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall)
2. FSL (http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation)
3. Python with VTK and numpy (easily obtained via anaconda: https://www.continuum.io/downloads)

To install the rest of the dependencies, run the following.

```sh
git clone https://github.com/pnlbwh/pnlutil
cd pnlutil/install-software
./all.sh
source ./addpaths.sh
```

That will install each of the following under the subdirectory `install-software`:

1. BRAINSTools
2. redo
3. measureTracts
4. UKFTractography

# Quick Walkthrough

    
## Setup and run

    cd your/project/
    mkpipeline.sh .  # copies files in pipeline/ to your project folder
    # edit SetUpData_config.sh and make file called 'caselist.txt' with your case id's, one per line 
    redo  # begins pipeline by running the default do script 'all.do'

If you only want part of the pipeline:

    cd your/project/
    addukf.sh .  # or addfs.sh, addmabs.sh, addepi.sh, addfsindwi.sh, etc. (these scripts are at `pnlutil/add*.sh`)
    # edit SetUpData.sh to set your input variables for 'ukf'
    missing ukf | xargs redo -k

## Query progress

The query scripts in `scripts-query` query the file paths of the variables
defined in your data schema, `SetUpData.sh`.  At the PNL we use a set of standard
variable names and file paths for the pipeline's output, as defined in
`SetUpData_pipeline.sh`:

    t1mabs=$case/strct/$case.t1mabs.nrrd  # generated t1 MABS mask
    fs=$case/strct/$case.freesurfer # freesurfer subject directory
    dwied=$case/diff/$case.dwi-Ed.nrrd  # eddy current corrected DWI
    ukf=$case/diff/$case.ukf_2T.vtk.gz  # whole brain tractography
    fsindwi=$case/diff/$case.fsindwi.nrrd  # freesurfer segmentation registered to DWI space
    wmqltracts=$case/diff/$case.wmqltracts  # directory of fiber bundles extracted using tract_querier
    tractmeasures=$case/diff/$case.tractmeasures.csv  # fiber bundle measures
    tractvols=$case/diff/$case.tractvols.csv  # fiber bundle volumes

The data is queried thus:

    vars  # convenient way of listing variables in the data schema SetUpData.sh
    completed dwied # lists eddy current corrected DWI's generated so far
    missing t1mabs  # lists missing t1 masks
    all ukf # lists paths of all tractography files that are to be generated; this will be same size as your case list file
    casestatus 01009  # shows what files are and are not generated for case 01009
    logstatus  # shows progress of each variable in 'status_vars' (and saves the result to statuslog.csv)

`logstatus` is one you'll use frequently to track the pipeline's progress.


# Pipeline Scripts Overview

This table summarizes the scripts in `scripts-pipeline`.

|                    |                         |                                                                       |                                                 | 
|--------------------|-------------------------|-----------------------------------------------------------------------|-------------------------------------------------| 
| Category           |  Script                 |  Function                                                             |  Software Dependencies                          | 
| General            |  **axis_align_nrrd.py**     |   removes oblique coordinate tranform                                 |  teem                                           | 
| General            |  **center.py**              |   changes origin to be at the center of the volume                    |  teem                                           | 
| General            |  **mask**                   |  skullstrips by applying a labelmap mask                              |  teem ConvertBetweenFileFormats                 | 
| DWI                |  **dwiPipeline-nofilt.py**  |  eddy and motion correction via registration                          |  teem FSL  ConvertBetweenFileFormats numpy      | 
| DWI                |  **bse.sh**                 |  extracts a baseline b0 image                                         |  teem                                           | 
| DWI                |  **dwibetmask**             |  computes a `bet` mask                                                |  FSL ConvertBetweenFileFormats                  | 
| DWI                |  **maskbse**                |  extracts a baseline b0 image and masks it                            |  teem                                           | 
| DWI                |  **epi.sh**                 |  corrects EPI distortion via registration                             |   teem ANTs                                     | 
| Structural         |  **mabs.sh**                |  computes a brain mask from training data                             |  teem ANTs                                      | 
| Structural         |  **fs.sh**                  |  runs freesurfer but takes care of some common preprocessing steps    |  Freesurfer ConvertBetweenFileFormats teem      | 
| Structural         |  **fsstats.sh**             |  creates a csv file of select freesurfer measures                     |  -                                              | 
| Structural         |  **make_rigid_mask.sh**     |  rigidly transforms a labelmap to align with another structural image |  ANTs teem                                      | 
| Freesurfer to DWI  |  **fs2dwi.sh**              |  registers a freesurfer segmentation to a DWI                         |  Freesurfer ANTs ConvertBewteenFileFormats teem | 
| Freesurfer to DWI  |  **fs2dwi_T2.sh**           |  registers a freesurfer segmentation to a DWI using a T2 (better)     |  Freesurfer ANTs ConvertBewteenFileFormats teem | 
| Tractography       |  **wmql.sh**                |  simple wrapper for tract_querier                                     |  tract_querier gunzip ConvertBewteenFileFormats | 

# Redo Overview

Data pipelines are built by connecting components that read inputs and emit an
output.  The overall result is a workflow that reads a set of input data and
outputs a set of processed data.

This makes build systems a good candiate for implementing pipelines.  They
have the same requirements as a data pipeline: an output file depends on the
existence of other files, and if those files are missing then they must be
generated first.  So although they are typically used by programmers to compile code,
they are also used by researchers to process data.

There are many build systems to choose from, but typically all
come with their own "pipeline writing" language, and many also have
the limitation of only accepting static dependencies, meaning all the
dependencies have to be known up front (for example, they won't be able to find
non-deterministic dependencies like files with time stamps).  Fortunately,
[redo](http://github.com/mildred/redo) is a simple build system that
avoids these issues, and so we use it to implement the PNL pipeline.

Redo works by executing a script for each output file or directory. In other
words, the scripts are pipeline components that accept inputs and compute an
output.  These scripts are named in two specials ways.  First, they must end
with the extension '.do', so that redo can find them.  Second, their names
determine the name of their output.  For example, if you wanted to generate a
csv file called `data.csv`, you would name your csv making script `data.csv.do`

To call redo you run `redo <filename>`, which makes redo find and
execute the matching `.do` script, thus creating the output `<filename>`. 

Dependencies are declared inside each `.do` script.  If those dependencies are
found missing during execution, then redo will look for the matching `.do`
scripts and run them before continuing with the current script.  For example,
if your `data.csv.do` relies on a text file `data.txt` and it doesn't exist,
then redo will look for and execute `data.txt.do` before continuing with its
execution of `data.csv.do`.

`.do` files can also be named with a leading `default.` to match many files you
wish to build using the same script.  Using the previous example, instead of
having a `data.csv.do`, you could have a `default.csv.do` that takes the string
matched by 'default' and uses it to find its text file dependency. So `redo
data.csv` would invoke `default.csv.do` with 'data' as an argument and thus it
knows to use `data.txt` as its input for building `data.csv`.


# PNL Pipeline Implementation

Each `.do` script in the `pipeline/` is a bash script that generates either an
image, directory, or csv file.  The scripts interpret the 'default' part of
their names as case id's, which they use to find their inputs.  For example,
`redo 0001.dwi-Ed.nrrd.do` invokes `default.dwi-Ed.nrrd.do` which uses the case
id 0001 to find its input DWI.  This requires that it be able to generate the
file path from a case id, but since projects have different file paths, we need
a way to specify them without hardcoding them in the scripts.

This is accomplished by writing a bash config file called `SetUpData.sh`.
Whenever a `.do` script is called, it sources this file and uses the file paths
of specifically named variables as its input (if these variables don't exist it
will complain and exit).  For example, `default.dwi-Ed.nrrd.do` expects the
path of its input to be in a variable called `dwied_dwi`, so in `SetUpData.sh`
you would have a line such as `dwied_dwi=path/to/${case}-dwi.nrrd`.  Running
`redo 0001.dwi-Ed.nrrd` would invoke `default.dwi-Ed.nrrd.do` with '0001' as an
argument, which sets the variable `case` to be '0001' and sources
`SetUpData.sh`, and thus the variable `dwied_dwi` resolves to
`path/to/0001-dwi.nrrd` which is used as the input DWI.

Because the output of one `.do` script will be the input of another, `SetUpData.sh`
can define a pipeline.  Here's a two step example:

    ## Source data ##################################
    dwiraw=$case/$case-dwi.nrrd

    ## Derived data #################################
    # Eddy current correction
    # Input
    dwied_dwi=$dwiraw
    # Output
    dwied=$case/$case.dwi-Ed.nrrd  # filename must match 'default.dwi-Ed.nrrd.do'

    # BET mask
    # Input
    dwibetmask_dwi=$dwied
    # Output
    dwibetmask=$case/$case.dwibetmask.nrrd  # filename must match 'default.dwibetmask.nrrd.do'

Running `redo 0001/0001.dwibetmask.nrrd` would first generate the eddy current
corrected dwi `0001/0001.dwi-Ed.nrrd` followed by the bet mask
`00001/00001.dwibetmask.nrrd`.

The extra output variables `dwied` and `dwibetmask` aren't strictly necessary
but they make the config file clearer and querying your data easier (see
below).

The full PNL pipeline is defined in `pipeline/SetUpData_pipeline.sh`.  There
you can see how each of the components are connected together.  Since the
pipeline is already specified all that it needs to be run is your input data: a
DWI file path, a T1 file path, and a list of your case id's in a file
`caselist`. 

# Repo Organization

The main scripts are organized into directories as follows.

1. `scripts-pipeline`

The pipeline is built from these scripts.  The are the pipeline's 'functions',
and they can be run independently.

2. `scripts-query`

These scripts query your project's data schema and print lists of files that
match certain conditions. For example, you can list all the freesurfer's that
have yet to be generated, or all the T1w masks that have already been generated.

3. `scripts-qc`

Contains scripts to help with quality control.  The main one is `qc`, and like
the query scripts relies on you having defined a data schema for your project.
You can then use it to loop through your case list and load Slicer for some
subset of a subject's data, saving a csv file with your notes and whether or
not they passed QC.

4. `pipeline`

This folder contains the scripts that are plugged together to build pipelines,
and depend on and use the scripts in `scripts-pipeline`.  These scripts are
never called directly -- they are used by the build system that implements
the pipeline.  Instead, you are only required to define the location of
your data in your data schema, and the scripts will read that information
and execute the pipeline.  

5. `scripts-all`

Contains symlinks to all other scripts so that you can access them by simply
referencing this folder (for example by putting it on your PATH).

# Issues

## Running `redo` hangs
This will happen when a redo process is interrupted unexpectedly and leaves behind
a lock file.  To fix this, first make sure no-one else is running redo in your project,
then run

    find . -name "*.lock" -exec rm {} \;
    
or

    cleanlocks.sh

This will clean up the stale lock files which lets redo know it can safely build
their associated outputs.
