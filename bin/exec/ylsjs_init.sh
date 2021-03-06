#!/usr/bin/env bash
#YLSJS_INIT v1
STDS=()
NAME="UK"
for opt in "${@}"; do
	if isopt "${opt}";then
		case "${opt}" in
		-n\:*)
			NAME=${opt:3}
			;;
		--name\:*)
			NAME=${opt:7}
			;;
		*)
			warnh "Option '${opt}' invalid. Ignored"
			;;
		esac
	fi
done
MAX_JOB=$(ls -1 *.sh | wc -l | awk '{print $1}')
MAX_JOB=$((${MAX_JOB}+1))
echo "${NAME}" > ${MAX_JOB}.q
echo "${WD}" > ${MAX_JOB}.wd
cat /dev/stdin > ${MAX_JOB}.sh
echo ${MAX_JOB}
infoh "$(cat ${MAX_JOB}.q)"
