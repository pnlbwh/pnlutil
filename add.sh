# to be sourced

SCRIPT=$(readlink -m $(type -p "$0"))
SCRIPTDIR=$(dirname $SCRIPT)
source "$SCRIPTDIR/util.sh"

usage() {
    echo -e "\

Adds '$SCRIPTDIR/pipeline/$doscript'  and
its pipeline scripts directory '$SCRIPTDIR/pipeline/scripts-pipeline/$var/' to your project directory, and
adds its input variables
$SetUpData_vars
to your project directory's data schema, 'SetUpData.sh'.

Usage:

    ${0##*/} <project_dir>

After running this script, edit '<project_dir>/SetUpData.sh', then run the
following to generate your output

    missing $var | xargs redo -k 
"
}

[ $# -eq 1 ] && [[ ! $1 == "-h" ]] || { usage; exit 1; }
[ -d $1 ] || { echo "Make directory '$1' first."; exit 1; }
dirProj=$1

# Install .do script
cp $SCRIPTDIR/pipeline/$doscript $1/$doscript

# Add vars to SetUpData.sh
echo >> $dirProj/SetUpData.sh
echo "$SetUpData_vars" >> $dirProj/SetUpData.sh 

# Copy pipeline scripts 
mkdir -p "$dirProj/scripts-pipeline/$var"
cp -LR "$SCRIPTDIR/pipeline/scripts-pipeline/$var" "$dirProj/scripts-pipeline"

echo -e "Made
$dirProj/$doscript
$dirProj/SetUpData.sh  # added $var's input variables
$dirProj/scripts-pipeline/$var

Now set the ${var}_* variables in SetUpData.sh and run

     missing $var | xargs redo -k

(Don't forget to define your caselist in SetUpData.sh as
'cases="001 002 ..."',  or 'caselist=mycaselist.txt', for
query script 'missing' to work)\
"
