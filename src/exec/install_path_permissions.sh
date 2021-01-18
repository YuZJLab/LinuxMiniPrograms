#!/usr/bin/env bash
# CONFIGURE v1
set -eu
OLDIFS="${IFS}"
DN="$(readlink -f "$(dirname "${0}")")/../../"
cd "${DN}"
. lib/libstr
. etc/path.sh
#========Install PATH========
if ! which yldoc &> /dev/null; then
	echo "export PATH=\"${DN}/bin/:\${PATH:-}\"" >> "${HOME}"/.bashrc
	infoh "Will configure PATH...\033[32mPASSED"
fi
#========Install PYTHONPATH========
if [ "${mypython}" != "ylukh" ] && ! echo "from LMP_Pylib.libylfile import *" | "${mypython}"; then
	echo "export PYTHONPATH=\"${DN}/libpy/:\${PYTHONPATH:-}\"" >> "${HOME}"/.bashrc
	infoh "Will configure PYTHONPATH...\033[32mPASSED"
fi
#========Install MANPATH========
if [ -e man/man1 ] && ! man yldoc &>> /dev/null ; then
	echo "export MANPATH=\"${DN}/man/:\${MANPATH:-}\"" >> "${HOME}"/.bashrc
	infoh "Will configure MANPATH...\033[32mPASSED"
fi
#========Install Permissions========
function add_dir() {
	"${myls}" -1 | while read file_name; do
		if [ -f ${file_name} ]; then
			"${mychmod}" -x ${file_name}
		else
			"${mychmod}" +x ${file_name}
			cd ${file_name}
			add_dir
			cd ..
		fi
	done
}
"${mychown}" -R $(id -u) *
"${mychmod}" -R +r+w *
add_dir
"${mychmod}" +x bin/* *.sh bin/exec/*.co* || true
infoh "Modifying file permissions...\033[32mPASSED"
IFS="${OLDIFS}"
infoh "Finished. Please execute 'exec bash' to restart bash"