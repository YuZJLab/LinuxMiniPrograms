#!/usr/bin/env bash
# GZIP.sh V1
if [ -z "${mypython:-}" ]; then
    python_ver=3
    for dir in "${eachpath[@]}"; do
        tmpf=$(mktemp -t configpath.XXXXXX)
        ${myls} -F -1 "${dir}" | ${mygrep} '.\*$' | ${mysed} "s;\*\$;;" | ${mygrep} -E '^(python(3|)(\.[[:digit:]]+)*(d|m|u|)(.exe|)$)' | ${mysed} "s;^;$(echo ${dir})/;" >"${tmpf}"
        while read line; do
            echo "Python found in ${line}"
            curr_version=$("${line}" --version 2>&1 | cut -f 2 -d " ")
            if [[ "${curr_version}" == 3* ]] && [ $(expr "${curr_version}" \>= "${python_ver}") -eq 1 ]; then
                Out_C="${line}"
                python_ver="${curr_version}"
            fi
            unset curr_version line
        done <"${tmpf}"
        rm "${tmpf}"
        unset tmpf dir
    done
    if [ -n "${Out_C:-}" ]; then
        echo "mypython=\"${Out_C}\" #version ${python_ver}" >>"${path_sh}"
        echo "Python found in ${Out_C}, version ${python_ver}"
        unset Out_C
    else
        echo "mypython=\"python\" #UNKNOWN" >>"${path_sh}"
        echo -e "\e[30mERROR: Python still not found. Please configure it manually in LMP_ROOT/etc/"${path_sh}".\e[0m"
    fi
    unset python_ver
    . "${path_sh}"
else
     echo -e "\e[033mpython configured\e[0m"
fi
