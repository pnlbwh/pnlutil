#!/bin/bash -eu

setupvars() {
    [ ! -f SetUpData.sh ] && { echo "Run in directory with 'SetUpData.sh'"; usage; exit 1; } 
    [ -n "${case:-}" ] || { log_error "Set 'case' variable first before calling this function (util.sh:setupvars)"; exit 1; }
    source SetUpData.sh
    for var in $@; do
        if [ ! -n "${!var-}" ]; then
            echo "Set $var in 'SetUpData.sh' first."
            exit 1
        fi
    done
}

case=${2##*/}
setupvars tractvols tractmeasures
redo $tractvols $tractmeasures
