#!/usr/bin/env bash
# CONFIGPATH V1P2
set -eu
cd src
. ../lib/libstr
path_sh="../etc/path.sh"
if ! [ -f "${path_sh}" ]; then
	mkdir -p ../etc
	touch "${path_sh}"
else
	. "${path_sh}"
fi
#=====os=====
if [ -z "${myos:-}" ]; then
	os_type=$(uname -mrs)
	echo "Current OS: ${os_type}"
	os_type_main=$(echo ${os_type} | cut -f 1 -d ' ')
	os_type_version=$(echo ${os_type} | cut -f 2 -d ' ')
	echo "myos=\"${os_type_main}\" #${os_type_version}" >> "${path_sh}"
	unset os_type os_type_main os_type_version
fi
#=====path=====
infoh "Enumerating valid path..."
INPATH="${PATH}"
. ../lib/libpath
unset invalid_path duplicated_path binpath
echo ${valid_path} | tr ':' '\n'
infoh "End locating valid path"
unset valid_path

myls="ls"
mygrep="grep"
mysed="sed"
myrm="rm"
for PROGNAME in ls grep sed rm ; do
	. exec/findcoreutils.sh
done
for PROGNAME in python ps parallel; do
	. exec/find${PROGNAME}.sh
done
for PROGNAME in cat chmod chown cp cut find gtar gzip head mkdir more mv sort split tail tar; do
	. exec/findcoreutils.sh
done
for PROGNAME in 7z 7za bgzip brotli bzip2 compress lz4 lzfse lzip lzma lzop pbz2 pigz rar unzip unrar xz zip zstd git asciidoctor-pdf asciidoctor; do
	. exec/findornot.sh
done
"${mysed}" -i 's;^mygtar;mytar;' "${path_sh}"
"${mysed}" -i 's;^myasciidoctor-pdf;myasciidoctor_pdf;' "${path_sh}"
. "${path_sh}"
infoh "All configurations are printed as follows:"
"${mycat}" "${path_sh}" | "${mygrep}" -v '^$' | "${mygrep}" -v '^#' | "${mysed}" 's/^my//' | "${mysed}" 's/=/\\\\033[33m in \\\\033[0m/ ' | "${mysed}" 's/ #/\\\\033[33m, \\\\033[32m/' | "${mysort}" | while read line; do echo -e "${line}\033[0m"; done
cd ..