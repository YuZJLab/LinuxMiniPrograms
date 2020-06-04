#!/usr/bin/env bash
#LIBDOMAN.sh V7
. "${DN}"/../lib/libisopt
more="${mymore}"
cmd=0
OPT=()
STDS=()
for opt in "${@}"; do
    if isopt "${opt}"; then
        case "${opt}" in
        "-h" | "--help")
            yldoc libdoman
            exit 0
            ;;
        "-v" | "--version")
            echo -e "\e[33mVersion 7 in Bash, compatiable with libdo Version 2.\e[0m"
            exit 0
            ;;
        -o\:*)
            cmd=${opt:3}
            ;;
        --output\:*)
            cmd=${opt:9}
            ;;
        --more\:*)
            more="${opt:7}"
            if $("${more}" --help &>/dev/null;echo ${?}) -eq 127; then
                echo -e "\e[31mERROR! Invalid More '${more}'! Will use original '${mymore}' instead.\e[0m"
                more="${mymore}"
            else
                echo -e "\e[33mWill use '${more}' as More.\e[0m"
            fi
            ;;
        *)
            echo -e "\e[31mERROR: Option '${opt}' invalid.\e[0m"
            exit 1
            ;;
        esac
        OPT=(${OPT[@]} "${opt}")
    else
        STDS=(${STDS[@]} "${opt}")
    fi
done

if [ ${#STDS[@]} -gt 1 ]; then
    echo -e "\e[33mMore than one filename was received. Will disable -o option.\e[0m"
    cmd=0
elif [ ${#STDS[@]} -lt 1 ]; then
    echo -e "\e[33mNo file.\e[0m"
    exit 1
fi
if [ ${cmd} -eq 0 ]; then
    more="${mycat}"
    echo -e "\e[33mWill use '${more}' as More.\e[0m"
    for fn in "${STDS[@]}"; do
        if ! [ -f "${fn}" ] || [ -z "${fn}" ]; then
            echo -e "\e[31mERROR: Filename '${fn}' invalid. Use libdoman -h for help.\e[0m"
            exit 1
        fi
        echo -e "\e[33mLoading ${fn}...0 item proceeded.\e[0m"
        ffn="$(mktemp -t libdo_man.XXXXXX)"
        "${mycat}" "${fn}" | "${mygrep}" LIBDO >"${ffn}"
        while read line; do
            all_lines=("${all_lines[@]}" "${line}")
        done <"${ffn}"
        i=0
        Proj=0
        while [ ${#all_lines[@]} -gt ${i} ]; do
            line="${all_lines[i]}"
            i=$((${i} + 1))
            if [[ "${line}" =~ "LIBDO IS GOING TO EXECUTE"* ]]; then
                Proj=$((${Proj} + 1))
                echo -e "\e[33mLoading ${fn}...${Proj} item proceeded.\e[0m"
                Proj_CMD[${Proj}]="${line:26}"
                line="${all_lines[i]}"
                if [[ "${line}" =~ "LIBDO STARTED AT"* ]]; then
                    Proj_Time_s[${Proj}]="${line:17}"
                    i=$((${i} + 2)) #Skip PID
                    line="${all_lines[i]}"
                fi
                if [ ${#all_lines[@]} -eq ${i} ]; then
                    Proj_Time_e[${Proj}]=0
                    Proj_Exit[${Proj}]="-1"
                    Proj_Time[${Proj}]="ERR"
                    continue
                fi
                if [[ "${line}" =~ "LIBDO STOPPED AT"* ]]; then
                    Proj_Time_e[${Proj}]="${line:17}"
                    Proj_Time[${Proj}]=$(bash "${DN}"/exec/datediff.sh "${Proj_Time_s[${Proj}]}" "${Proj_Time_e[${Proj}]}")
                    i=$((${i} + 1))
                    line="${all_lines[i]}"
                elif [[ "${line}" =~ "LIBDO IS GOING TO EXECUTE"* ]]; then
                    Proj_Time_e[${Proj}]=0
                    Proj_Exit[${Proj}]="-1"
                    Proj_Time[${Proj}]="ERR"
                    continue
                fi
                if [[ "${line}" == "LIBDO EXITED SUCCESSFULLY" ]]; then
                    i=$((${i} + 1))
                    Proj_Exit[${Proj}]="0"
                elif [[ "${line}" =~ "LIBDO FAILED, GOT"* ]]; then
                    i=$((${i} + 1))
                    Proj_Exit[${Proj}]="${line:21}"
                fi
            fi
        done
        echo -e "\e[33mFile ${fn} loaded. Making table...\e[0m"
        table=$(mktemp -t libdo_man.XXXXXX)
        echo -e "#1\n#S90\n#1\n#1" >"${table}"
        echo "NO.;COMMAND;EXIT;TIME" >>"${table}"
        for ((i = 1; i <= ${Proj}; i++)); do
            echo "${i};${Proj_CMD[${i}]};${Proj_Exit[${i}]};${Proj_Time[${i}]}" >>"${table}"
        done
        ylmktbl "${table}" | "${more}"
        "${myrm}" "${ffn}" "${table}"
        unset Proj Proj_CMD Proj_Exit Proj_Time_e Proj_Time_s table ffn all_lines
    done
else
    
    fn="${STDS[0]}"
    if ! [ -f "${fn}" ]; then
        echo -e "\e[31mERROR: Filename '${fn}' invalid. Use libdoman -h for help.\e[0m"
        exit 1
    fi
    ln_s=0
    ln_e=0
    tmps="$(mktemp -t libdo_man.XXXXXX)"
    "${mycat}" -n "${fn}" | "${mygrep}" "LIBDO IS GOING TO EXECUTE" >"${tmps}"
    ln=0
    while read line; do
        ln=$((${ln} + 1))
        if [ ${ln} -eq ${cmd} ]; then
            ln_s="$(echo ${line} | "${mycut}" -f 1 -d " ")"
        elif [ ${ln} -gt ${cmd} ]; then
            ln_e="$(($(echo ${line} | "${mycut}" -f 1 -d " ") - 1))"
            break
        fi
    done <"${tmps}"
    "${myrm}" "${tmps}"
    if [ ${ln_s} -eq 0 ]; then
        echo -e "\e[31mERROR: ${cmd} invalid.\e[0m" >&2
        exit 1
    fi
    if [ ${ln_e} -eq 0 ]; then ln_e=$(wc -l ${fn} | awk '{print $1}'); fi
    unset line
    tmpprj="$(mktemp -t libdo_man.XXXXXX)"
    "${myhead}" -n $((${ln_s} + 1)) "${fn}" | "${mytail}" -n 2 > "${tmpprj}"
    "${myhead}" -n ${ln_e} "${fn}" | "${mytail}" -n 2 >> "${tmpprj}"
    while read line; do
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
        if [[ "${line}" =~ "LIBDO STOPPED AT"* ]]; then
            Time_e="${line:17})"
            Time="$(bash "${DN}"/exec/datediff.sh "${Time_s}" "${Time_e}")"
            i=$((${i} + 1))
            line=${all_lines[i]}
        fi
        if [[ "${line}" == "LIBDO EXITED SUCCESSFULLY." ]]; then
            Exit="0"
        elif [[ "${line}" =~ "LIBDO FAILED, GOT"* ]]; then
            Exit="${line:21}"
        fi
    fi
    echo -e "\e[33mJOB_CMD      \e[36m: ${CMD}\e[0m" >&2
    echo -e "\e[33mELAPSED_TIME \e[36m: ${Time_s} to ${Time_e}, Total ${Time}\e[0m" >&2
    echo -e "\e[33mEXIT_STATUS  \e[36m: ${Exit}\e[0m" >&2
    echo -e "\e[33m________________JOB_________OUTPUT________________\e[0m" >&2
    tls=$((${ln_s} + 2))
    els=$((${ln_e} - 2))
    if [ ${ln_e} -le ${tls} ]; then
        echo -e "\e[33mNO_OUTPUT\e[0m"
    elif [ "${Exit}" = "-1" ]; then
        "${myhead}" -n ${ln_e} "${fn}" | "${mytail}" -n $((${tls} - ${ln_e})) | "${more}"
    else
        "${myhead}" -n ${els} "${fn}" | "${mytail}" -n $((${tls} - ${els})) | "${more}"
    fi
    echo -e "\e[33m________________OUTPUT____FINISHED________________\e[0m" >&2
    rm "${tmpprj}"
fi
echo -e "\e[33mFinished.\e[0m" >&2
exit 0
