# Sourced by origin, spacedir

source $SCRIPTDIR/util.sh

HELP="\
Prints $descrip for SetUpData.sh variables.
Usage:
    ${0##*/} [-d delimiter] [-c \"case1 case2 ..\"] [-f mycaselist.txt] <var1> <var2> ... <varN>
E.g.
    ${0##*/} dwied fsindwi
    ${0##*/} -d\" \" -c case001 dwied dwimask fsindwi
"
usage() { echo -e "$HELP"; exit 1; }

setcases() {
    if [ -n "${argcases-}" ]; then 
        cases=$argcases
    elif [ -n "${argcaselist-}" ] && [ -f "$argcaselist" ]; then 
        cases=$(cat "$argcaselist" | awk '{print $1}')
    else
        case=000 && source SetUpData.sh
        if [ ! -n "${caselist-}" ]; then
            echo -e "Set variable 'caselist' (a text file) or 'cases' (a string of case ids) in 'SetUpData.sh', \nor pass them as arguments on the commandline."
            usage; exit 1;
        fi
        cases=$(cat "$caselist" | awk '{print $1}')
    fi
}

nrrdInfo() {
    nrrd=$1
    if [ ! -f "$nrrd" ]; then
        printf "nonexistant"
        return
    elif [[ "${nrrd##*.}" != "nrrd" && "${nrrd##*.}" != "nhdr" ]]; then
        printf "notnrrd"
        return
    fi
    header=$(unu head $nrrd 2>/dev/null)
    if test -z "$header"; then
        printf "badnrrd"
    else
        #printf "$header" | grep "origin" | sed 's/space origin: //'
        filtfunc "$header"
    fi
}

join() { 
    local IFS="$1"; shift; echo "$*"; 
    #delim=$1; shift;
    #printf "%s%s\n" "$delim" "$*"
}

delim=","
# Parse args
while getopts "hd:c:f:" flag; do
case "$flag" in
    h) usage;;
    d) delim=$OPTARG;; 
    c) argcases=$OPTARG;;
    f) argcaselist=$OPTARG;;
esac
done
shift $((OPTIND-1))

# Get positional arguments (vars) and make sure they are set in SetUpData.sh
vars=$@
case=000 && source SetUpData.sh
for var in $vars; do
    [ -n "${!var-}" ] || { usage; exit 1; }
done

# Get the cases to get results for
setcases

for case in $cases; do
    source SetUpData.sh
    info=()
    for var in $vars; do
        info+=("$(nrrdInfo "${!var}")")
    done
    join "$delim" "${info[@]}"
done
