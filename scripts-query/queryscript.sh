#####
# Query script functions/helpers
# Sourced by query scripts

join() { 
    local IFS="$1"; shift; echo "$*"; 
    #delim=$1; shift;
    #printf "%s%s\n" "$delim" "$*"
}

setcases() {
    if [ -n "${argcases-}" ]; then 
        cases=$argcases
    elif [ -n "${argcaselist-}" ]; then 
        [ -f "$argcaselist" ] || { echo "'$argcaselist' doesn't exist."; exit 1; }
        cases=$(cat "$argcaselist" | awk '{print $1}')
    else
        case=000 && source SetUpData.sh
        if [ ! -n "${caselist-}" ] && [ ! -n "${cases-}" ]; then 
            echo -e "Set variable 'caselist' (a text file) or 'cases' (a string of case ids) in 'SetUpData.sh', \nor pass them as arguments on the commandline."
            exit 1
        fi
        if [ -n "${caselist-}" ] && [ -n "${cases-}" ]; then 
            echo "You have set both 'caselist' and 'cases' in your SetUpData.sh, just set just one."
            exit 1
        fi
        if [ -n "${caselist-}" ]; then
            [ -f "$caselist" ] || { echo "Your caselist '$caselist' isn't an existing file."; exit 1; }
            cases=$(cat "$caselist" | awk '{print $1}')
        fi
    fi
}

delim=","
printcaseids=false
# Parse args
while getopts "hd:cl:f:" flag; do
case "$flag" in
    h) usage; exit;;
    d) delim=$OPTARG;; 
    l) argcases=$OPTARG;;
    c) printcaseids=true;;
    f) argcaselist=$OPTARG;;
esac
done
shift $((OPTIND-1))

[ $# -gt 0 ] || { usage; }
# Get positional arguments (vars) and make sure they are set in SetUpData.sh
vars=$@
[ -f SetUpData.sh ] || { echo "Run in directory with SetUpData.sh."; usage; exit 1; }
case=000 && source SetUpData.sh
for var in $vars; do
    [ -n "${!var-}" ] || { echo "Set '$var' in SetUpData.sh first."; usage; exit 1; }
done


# Get the cases to get results for
setcases
