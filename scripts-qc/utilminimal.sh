#####
# Query script functions/helpers

queryscript_parseargs() {
    selectcases=false
    while getopts "hcf:" flag; do
        case "$flag" in
            h) usage 1;;
            c) selectcases=true;;
            f) argcaselist=$OPTARG;;
        esac
    done
    shift $((OPTIND-1))

    # get positional arguments
    IFS=" " read var argcases <<<"$@"
    [ -n "${var-}" ] || { echo -e "Specify variable <var>."; usage 1; }

    # check input is ok
    case=000 && setupvars $var
    [ ! -n "${argcaselist-}" ] || caselist=$argcaselist
    [ ! -n "${argcases-}" ] || cases=$argcases
    setupcases
}

queryscript_helpmsg="\
Run in directory with 'SetUpData.sh' that has '<var>=/path/to/\$case-file'
defined in it.  The set of cases must either be defined in SetUpData.sh (e.g.
as caselist=mycaselist.txt or cases=\"case1 case2.. caseN\"), or on the
commandline (see below).

${0##*/} [-c] [-f <caselist>] <var>  [case1 case2 .. caseN]

-c                      Prints case id's, not file paths
-f <caselist>           Uses case id's from <caselist> (one per line, but can include comments)
[case1 case2 ..caseN]   Use these case id's instead of a caselist file

Examples:
    missing -c t1
    all -f caselist_qc.txt dwi
    completed ukf 01009 01010 01012 01243
"
