#!/bin/bash -eu

dirScripts="scripts-pipeline/fsstats"
$dirScripts/csvcat `completed fsstats` > $3
echo "Made '$1'"
