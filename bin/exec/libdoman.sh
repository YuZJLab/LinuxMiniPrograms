#!/usr/bin/env bash
VERSION=7.6
. "${DN}"/../shlib/libinclude.sh
__include libisopt
__include libstr
warnh "This program is no longer monitored and updates may not be provided"
cmd=0
STDS=()
ISMACHINE=false
for opt in "${@}"; do
    if isopt "${opt}"; then
        case "${opt}" in
        "-h" | "--help")
            man libdoman
            builtin exit 0
            ;;
        "-v" | "--version")
            infoh "Version ${VERSION}, compatiable with libdo Version 2 & 3"
            builtin exit 0
            ;;
        "-m" | "--machine")
            cmd=0
            ISMACHINE=true
            ;;
        -o\:*)
            cmd=${opt:3}
            ;;
        --output\:*)
            cmd=${opt:9}
            ;;
        "-x")
            builtin set -x
            ;;
        *)
            warnh "Option '${opt}' invalid. Ignored"
            ;;
        esac
    else
        STDS=("${STDS[@]}" "${opt}")
    fi
done
if [ ${#STDS[@]} -gt 1 ]; then
    infoh "More than one filename was received. Will disable -o option"
    cmd=0
elif [ ${#STDS[@]} -lt 1 ]; then
    errh "No file"
fi
if [ ${cmd} -eq 0 ]; then
    for fn in "${STDS[@]}"; do
        [ -f "${fn}" ] || errh "Filename '${fn}' invalid"
        infoh "Loading ${fn}...0 item proceeded"
        while builtin read line; do
            all_lines=("${all_lines[@]}" "${line}")
        done < <(cat "${fn}" | grep LIBDO)
        i=0
        Proj=0
        while [ ${#all_lines[@]} -gt ${i} ]; do
            line="${all_lines[i]}"
            i=$((${i} + 1))
            if [[ "${line}" == "LIBDO IS GOING TO EXECUTE"* ]]; then
                Proj=$((${Proj} + 1))
                infoh "Loading ${fn}...${Proj} item proceeded"
                Proj_CMD[${Proj}]="${line:26}"
                line="${all_lines[i]}"
                if [[ "${line}" == "LIBDO STARTED AT"* ]]; then
                    Proj_Time_s[${Proj}]="${line:17}"
                    i=$((${i} + 2)) #Skip PID
                    line="${all_lines[i]}"
                fi
                if [ ${#all_lines[@]} -eq ${i} ]; then
                    Proj_Time_e[${Proj}]=0
                    Proj_Exit[${Proj}]="-1"
                    Proj_Time[${Proj}]="ERR"
                    builtin continue
                fi
                if [[ "${line}" == "LIBDO STOPPED AT"* ]]; then
                    Proj_Time_e[${Proj}]="${line:17}"
                    if ${ISMACHINE}; then
                        Proj_Time[${Proj}]=$(bash "${DN}"/exec/datediff.sh "${Proj_Time_s[${Proj}]}" "${Proj_Time_e[${Proj}]}" machine)
                    else
                        Proj_Time[${Proj}]=$(bash "${DN}"/exec/datediff.sh "${Proj_Time_s[${Proj}]}" "${Proj_Time_e[${Proj}]}")
                    fi
                    i=$((${i} + 1))
                    line="${all_lines[i]}"
                elif [[ "${line}" == "LIBDO IS GOING TO EXECUTE"* ]]; then
                    Proj_Time_e[${Proj}]=0
                    Proj_Exit[${Proj}]="-1"
                    Proj_Time[${Proj}]="ERR"
                    builtin continue
                fi
                if [[ "${line}" == "LIBDO EXITED SUCCESSFULLY" ]]; then
                    i=$((${i} + 1))
                    Proj_Exit[${Proj}]="0"
                elif [[ "${line}" == "LIBDO FAILED, GOT"* ]]; then
                    i=$((${i} + 1))
                    Proj_Exit[${Proj}]="${line:21}"
                fi
            fi
        done
        infoh "File ${fn} loaded. Making table..."
        if ${ISMACHINE}; then
            for ((i = 1; i <= ${Proj}; i++)); do
                builtin echo -e "${Proj_CMD[${i}]}\t${Proj_Exit[${i}]}\t${Proj_Time[${i}]}"
            done
        else
            table=$(mktemp -t libdo_man.XXXXXX)
            builtin echo -e "#1\n#S90\n#1\n#1" >"${table}"
            builtin echo "NO.;COMMAND;EXIT;TIME" >>"${table}"
            for ((i = 1; i <= ${Proj}; i++)); do
                builtin echo "${i};${Proj_CMD[${i}]};${Proj_Exit[${i}]};${Proj_Time[${i}]}" >>"${table}"
            done
            ylmktbl "${table}"
            rm "${table}"
        fi
        builtin unset Proj Proj_CMD Proj_Exit Proj_Time_e Proj_Time_s table all_lines
    done
else
    fn="${STDS[0]}"
    [ -f "${fn}" ] || errh "Filename '${fn}' invalid"
    ln_s=0
    ln_e=0
    ln=0
    while builtin read line; do
        ln=$((${ln} + 1))
        if [ ${ln} -eq ${cmd} ]; then
            ln_s="$(builtin echo ${line} | cut -f 1 -d " ")"
        elif [ ${ln} -gt ${cmd} ]; then
            ln_e="$(($(builtin echo ${line} | cut -f 1 -d " ") - 1))"
            break
        fi
    done < <(cat -n "${fn}" | grep "LIBDO IS GOING TO EXECUTE")
    [ ${ln_s} -ne 0 ] || builtin echo -e "${cmd} invalid"
    [ ${ln_e} -ne 0 ] || ln_e=$(wc -l ${fn} | awk '{print $1}')
    builtin unset line
    tmpprj="$(mktemp -t libdo_man.XXXXXX)"
    head -n $((${ln_s} + 1)) "${fn}" | tail -n 2 >"${tmpprj}"
    head -n ${ln_e} "${fn}" | tail -n 2 >>"${tmpprj}"
    while builtin read line; do
        all_lines=("${all_lines[@]}" "${line}")
    done <"${tmpprj}"
    CMD="${all_lines[0]:26}"
    Time_s="${all_lines[1]:17}"
    if [ ${#all_lines[@]} -lt 4 ]; then
        Time_e=0
        Exit="-1"
        Time="ERR"
    else
        i=2
        line="${all_lines[i]}"
        if [[ "${line}" == "LIBDO STOPPED AT"* ]]; then
            Time_e="${line:17}"
            Time="$(bash "${DN}"/exec/datediff.sh "${Time_s}" "${Time_e}")"
            i=$((${i} + 1))
            line=${all_lines[i]}
        fi
        if [[ "${line}" == "LIBDO EXITED SUCCESSFULLY" ]]; then
            Exit="0"
        elif [[ "${line}" == "LIBDO FAILED, GOT"* ]]; then
            Exit="${line:21}"
        fi
    fi
    infoh "JOB_CMD	  ${ANSI_CRAYON}: ${CMD}" >&2
    infoh "ELAPSED_TIME ${ANSI_CRAYON}: ${Time_s} to ${Time_e}, Total ${Time}" >&2
    infoh "EXIT_STATUS  ${ANSI_CRAYON}: ${Exit}" >&2
    infoh "________________JOB_________OUTPUT________________" >&2
    tls=$((${ln_s} + 2))
    els=$((${ln_e} - 2))
    if [ ${ln_e} -le ${tls} ]; then
        infoh "NO_OUTPUT"
    elif [ "${Exit}" = "-1" ]; then
        head -n ${ln_e} "${fn}" | tail -n $((${tls} - ${ln_e}))
    else
        head -n ${els} "${fn}" | tail -n $((${tls} - ${els}))
    fi
    infoh "________________OUTPUT____FINISHED________________" >&2
    rm "${tmpprj}"
fi
infoh "Finished"
builtin exit 0
