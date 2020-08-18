#!/usr/bin/env bash
# DATEDIFF V2
if [[ "$(date --version 2>&1||true)" =~ "GNU" ]];then
	Start_Sec=$(date -d "${1}" "+%s")
	End_Sec=$(date -d "${2}" "+%s")
else
	Start_Sec=$(date -j -f "%Y-%m-%d %H:%M:%S" "${1}" "+%s")
	End_Sec=$(date -j -f "%Y-%m-%d %H:%M:%S" "${2}" "+%s")
fi
[ ${Start_Sec} -ge ${End_Sec} ] && Diff_Sec=$((${Start_Sec} - ${End_Sec})) || Diff_Sec=$((${End_Sec} - ${Start_Sec}))
Diff_H=$((${Diff_Sec} / 3600))
Diff_M=$(((${Diff_Sec} - ($Diff_H * 3600)) / 60))
Diff_S=$((${Diff_Sec} % 60))
echo "${Diff_H}:${Diff_M}:${Diff_S}"
