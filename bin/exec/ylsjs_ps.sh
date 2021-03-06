#!/usr/bin/env bash
#YLSJS_PS v1
STDS=()
VERBOSE=false
TOP=false
PST=false
CAT=false
for opt in "${@}"; do
	if isopt "${opt}"; then
		case "${opt}" in
		"-V" | "--verbose")
			VERBOSE=true
			;;
		"-t" | "--top")
			TOP=true
			;;
		"-p" | "--pst")
			PST=true
			;;
		"-s" | "--show-sh")
			CAT=true
			;;
		esac
	else
		STDS=("${STDS[@]}" "${opt}")
	fi
done

unset STDS[0]

function __psv() {
	local PID
	echo "${@}" | tr ' ' '\n' | sort -n | while read ps_name;do
		if [ -f "${ps_name}.i" ]; then
			PID=$(cat "${ps_name}.i" | tail -n 1)
			echo -e "# ---------------No=${ps_name},\tNAME=$(cat ${ps_name}.i | head -n 1),\tPID=${PID},\tSTATUS=EXEC---------------"
			if ${CAT};then
				echo "    # ---------------Submitted ${ps_name}.sh---------------"
				cat -n ${ps_name}.sh
			fi
			#if ${PS};then
			#	echo "    # ---------------ps ${ps_name}---------------"
			#	ps -p ${PID} || true
			#fi
			if ${PST};then
				echo "    # ---------------pstree ${ps_name}---------------"
				${PST} && pstree -ap ${PID} || true
			fi
			if ${TOP};then
				echo "    # ---------------top ${ps_name}---------------"
				top -H -p ${PID} -bc -n1 || true
			fi
		elif [ -f "${ps_name}.f" ]; then
			PID=$(cat "${ps_name}.f" | tail -n 1)
			echo -e "# ---------------No=${ps_name},\tNAME=$(cat ${ps_name}.f | head -n 1),\tPID=${PID},\tSTATUS=DONE---------------"
			if ${CAT};then
				echo "    # ---------------Submitted ${ps_name}.sh---------------"
				cat -n ${ps_name}.sh
			fi
		elif [ -f "${ps_name}.q" ]; then
			PID=$(cat "${ps_name}.q" | tail -n 1)
			echo -e "# ---------------No=${ps_name},\tNAME=$(cat ${ps_name}.q | head -n 1),\tPID=UK,\tSTATUS=PEND---------------"
			if ${CAT};then
				echo "    # ---------------Submitted ${ps_name}.sh---------------"
				cat -n ${ps_name}.sh
			fi
		fi
	done
}

function __psc() {
	table=$(mktemp -t ylsjs_ps.XXXXXX)
	echo -e "#1\n#1\n#1\n#1\n#1" >"${table}"
	echo "NO.;NAME;PID;EXECTIME;STATUS" >>"${table}"
	echo "${@}" | tr ' ' '\n' | sort -n | while read ps_name;do
		[ -f "${ps_name}.i" ] && echo "${ps_name};$(cat ${ps_name}.i | head -n 1);$(cat ${ps_name}.i | tail -n 1);$(bash "${DN}"/exec/datediff.sh $(cat ${ps_name}.start) $(date +%s) s);EXEC" >>"${table}" || true
		[ -f "${ps_name}.q" ] && echo "${ps_name};$(cat ${ps_name}.q);UK;$(bash "${DN}"/exec/datediff.sh $(stat --printf=%Z ${ps_name}.q) $(date +%s) s);PEND" >>"${table}" || true
		[ -f "${ps_name}.f" ] && echo "${ps_name};$(cat ${ps_name}.f | head -n 1);$(cat ${ps_name}.f | tail -n 1);$(bash "${DN}"/exec/datediff.sh $(cat ${ps_name}.start) $(cat ${ps_name}.end) s);DONE" >>"${table}" || true
	done
	ylmktbl "${table}"
	rm "${table}"
}

if [ ${#STDS[@]} -eq 0 ]; then
	if ${VERBOSE}; then
		__psv $(ls -1 | grep '^[0-9]*\.[qif]$' | sed 's;.[qif]$;;' | xargs)
	else
		__psc $(ls -1 | grep '^[0-9]*\.[qif]$' | sed 's;.[qif]$;;' | xargs)
	fi
else
	if ${VERBOSE}; then
		__psv "${STDS[@]}"
	else
		__psc "${STDS[@]}"
	fi
fi
