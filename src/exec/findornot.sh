#!/usr/bin/env bash
# FINDORNOT.sh V2
if ! grep ^"${PROGNAME}"= "${path_sh}"; then
	if which "${PROGNAME}" &>> /dev/null; then
		line="$(which "${PROGNAME}")"
		echo "my${PROGNAME}=\"${line}\" #UNIVERSE" >> "${path_sh}"
		echo "${PROGNAME} found in ${line}"
	else
		echo "my${PROGNAME}=\"ylukh\" #UNKNOWN" >> "${path_sh}"
		warnh "${PROGNAME} still not found. Please configure it manually in $(readlink -f "${path_sh}")"
	fi
	unset line
else
	infoh "${PROGNAME} configured"
fi
