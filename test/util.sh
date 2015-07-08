#!/bin/bash -eu

function verify() {
    if md5sum $1 | cut -d' ' -f1 | diff - <(echo $2); then
        log_success "$1 PASS"
    else
        log_error "$1 FAIL"
        return 1
    fi
}
