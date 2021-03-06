#GITM_GETURL.sh v1
. "${DN}"/../lib/libman

tmpf="$(mktemp -t gitm.XXXXX)"
USELOCAL=false
for opt in "${@}"; do
	if isopt "${opt}"; then
		case "${opt}" in
		"-l" | "--local")
			USELOCAL=true
			;;
		esac
	fi
done
[ ${#STDS[@]} -gt 0 ] || errh "Need more than ONE argument"
for url in "${STDS[@]}"; do
	grep_uuidtable "${url}" "${tmpf}" &>> /dev/null || warnh "${url} yields no results"
done
cat "${tmpf}" | while read line; do
	IFS=$'\t'
	fields=(${line})
	IFS=''
	[ ! -f "${fields[1]}".lock ] || warnh "Repos UUID=${fields[1]} is being locked: $(cat "${fields[1]}".lock)"
	printf ${fields[0]}" "
	${USELOCAL} && echo "$(readlink -f ${fields[1]})" || echo "$(getuser)@${HOSTNAME}:$(readlink -f ${fields[1]})"
	echo -e "$(timestamp)\tGETURL\tSUCCESS\t${fields[0]}\t${fields[1]}" >> act.log
done
rm -f "${tmpf}"
infoh "Repository geturl success"
