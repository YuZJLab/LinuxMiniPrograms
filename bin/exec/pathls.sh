#!/usr/bin/env bash
VERSION=3.10
_grep() {
    builtin local regstr
    regstr="${1}"
    builtin local tmpff
    tmpff=$(mktemp -t pls.XXXXXX)
    cat "${tmpf}" | grep -v "${regstr}" >"${tmpff}"
    mv "${tmpff}" "${tmpf}"
}
. "${DN}"/../shlib/libinclude.sh
__include libisopt
__include libstr
validate_path "${PATH}"
# shellcheck disable=SC2154
builtin mapfile -t eachpath < <(builtin echo ${valid_path} | tr ':' '\n')
builtin unset duplicated_path
allow_x=true
allow_d=false
allow_o=true
STDS=()
for opt in "${@}"; do
    if isopt "${opt}"; then
        case "${opt}" in
        "-h" | "--help")
            man pathls
            builtin exit 0
            ;;
        "-v" | "--version")
            builtin echo ${VERSION}
            builtin exit 0
            ;;
        "--no-x")
            allow_x=false
            ;;
        "--allow-d")
            allow_d=true
            ;;
        "--no-o")
            allow_o=false
            ;;
        "-l" | "--list")
            builtin echo ${valid_path} | tr ':' '\n'
            builtin unset valid_path
            builtin exit 0
            ;;
        "-i" | "--invalid")
            # shellcheck disable=SC2154
            builtin echo ${invalid_path} | tr ':' '\n'
            builtin unset invalid_set invalid_path valid_path
            builtin exit 0
            ;;
        "-x")
            builtin set -x
            ;;
        "-p" | "--parallel")
            # TODO: support parallel
            warnh "Currently not supported"
            ;;
        *)
            warnh "Option '${opt}' invalid. Ignored"
            ;;
        esac
    else
        STDS=("${STDS[@]}" "${opt}")
    fi
done
builtin unset invalid_path valid_path
tmpf="$(mktemp -t pls.XXXXXX)"
infoh "Reading database..."
for dir in "${eachpath[@]}"; do
    ls -1 -F "${dir}" 2>/dev/null | sed "s;^;$(builtin echo "${dir}")/;" >>"${tmpf}" || true
done
${allow_d} || _grep '/$'
${allow_x} || _grep '\*$'
${allow_o} || _grep '[^\*/]$'
if [ ${#STDS[@]} -eq 0 ]; then
    cat "${tmpf}"
else
    grepstr=''
    for fn in "${STDS[@]}"; do
        grepstr="${grepstr} -e ${fn}"
    done
    builtin eval cat \"${tmpf}\"\|grep "${grepstr}"
fi
rm "${tmpf}"
