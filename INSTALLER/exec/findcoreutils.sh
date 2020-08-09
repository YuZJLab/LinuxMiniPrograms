#!/usr/bin/env bash
# FINDCOREUTILS.sh V2
if ! "${mygrep}" ^"${PROGNAME}"= "${path_sh}";then
    GNU_found=false
    for dir in "${eachpath[@]}"; do
        ${GNU_found} && break || true
        tmpf=$(mktemp -t configpath.XXXXXX)
        "${myls}" -F -1 "${dir}" | "${mygrep}" '.[*@]$' | "${mysed}" 's;[*@]$;;' | "${mygrep}" '^'"${PROGNAME}"'\(\.exe\)*$' | "${mysed}" "s;^;$(echo ${dir})/;" >"${tmpf}"
        while read line; do
            lntmp="${line}"
            PROG_ver=$("${line}" --version 2>&1||true)
            if [[ "${PROG_ver}" =~ .*"GNU".* ]]; then
                GNU_found=true
                [[ "${PROG_ver}" =~ .*"Cygwin".* ]] && type="GNU version in Cygwin systems" || type="GNU version in GNU/Linux systems"
            else
                type="BSD version"
            fi
            echo "${PROGNAME} found in ${line}, ${type}"
            if ${GNU_found}; then
                echo "my${PROGNAME}=\"${line}\" #${type}" >>"${path_sh}"
                break
            fi
        done <"${tmpf}"
        "${myrm}" "${tmpf}"
        unset tmpf dir
    done
    if "${mygrep}" ^"${PROGNAME}"= "${path_sh}";then
        if [ -z "${lntmp:-}" ]; then
            echo "my${PROGNAME}=\"ylukh\" #UNKNOWN" >>"${path_sh}"
            echo -e "\033[31mERROR: ${PROGNAME} still not found. Please configure it manually in LMP_ROOT/etc/"${path_sh}".\033[0m"
        else
            echo -e "\033[31mWARNING: Will use BSD ${PROGNAME}.\033[0m"
            echo "my${PROGNAME}=\"${lntmp}\" #${type}" >>"${path_sh}"
        fi
    fi
    unset PROG_ver line
else
    echo -e "\033[033m${PROGNAME} configured\033[0m"
fi
