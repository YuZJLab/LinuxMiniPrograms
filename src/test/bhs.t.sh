#!/usr/bin/env bash
builtin set -eu
DN="$(readlink -f "$(dirname "${0}")")"
# shellcheck disable=SC2034
PROGNAME=bhs
. "${DN}"/00_libtest.sh
__DO bhs
__DO bhs ls
__DO bhs "ls -l"
