#!/usr/bin/env bash
set -eu
DN="$(readlink -f "$(dirname "${0}")")"
# shellcheck disable=SC2034
PROGNAME=git-mirror
. "${DN}"/00_libtest.sh
which git &>>/dev/null || exit 0
git-mirror lscmd 2>/dev/null | while read line; do
    __DO git-mirror --home:"${TDN}/tmp" "${line}" -h
    __DO git-mirror --home:"${TDN}/tmp" "${line}" -v
done
for act in lscmd "-h" "-v"; do
    __DO git-mirror --home:"${TDN}/tmp" "${act}"
done
__DO git-mirror --home:"${TDN}/tmp" add https://gitee.com/YuZJLab/SoftInstall https://gitee.com/YuZJLab/R_CheatSheet
for act in sync ls lsbranch gc; do
    __DO git-mirror --home:"${TDN}/tmp" "${act}"
done
__DO git-mirror --home:"${TDN}/tmp" rmrepo -f https://gitee.com/YuZJLab/SoftInstall https://gitee.com/YuZJLab/R_CheatSheet
__DO git-mirror --home:"${TDN}/tmp" log
rm -rf "${TDN}"
