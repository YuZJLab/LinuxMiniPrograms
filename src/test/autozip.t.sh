#!/usr/bin/env bash
set -eu
DN="$(readlink -f "$(dirname "${0}")")"
PROGNAME=autozip
. "${DN}"/00_libtest.sh
DO dd if=/dev/zero of=tf bs=512 count=1
AAA=($(echo $(autozip 2> /dev/null | grep '>' | cut -f 1 -d '(' | xargs) | tr ' ' '\n'))
for ext in gz bgz xz bz2 lzma lz4 zst lzo lz br Z lzfse;do
	echo "${AAA}" | grep '^'"${ext}"'$' &>> /dev/null || continue
	DO autozip --force --parallel tf "${ext}" 1
	DO azlist tf."${ext}"
	DO autounzip --force --remove --parallel tf."${ext}"
	DO cat tf \| azcat --parallel - "${ext}" 1 \> tf.azc.${ext}
	DO azlist tf.asc."${ext}"
done
for ext in 7z zip rar;do
	DO autozip --force --parallel tf "${ext}" 1
	DO azlist tf."${ext}"
	DO autounzip --force --remove --parallel tf."${ext}"
done
DO autozip --force --parallel tf
DO cat tf \| azcat --parallel \> tf.azc.ne
DO autozip --force --parallel -1 tf gz
DO cat tf \| azcat --parallel -1 - gz \> tf.azc.${ext}
# AUTOZIP WITH DIRECTORY
mkdir -p td
for i in {1..20};do
	DO dd if=/dev/zero of=td/${i} bs=512 count=1
done
DO autozip td --force --parallel -1
DO azcat --parallel td \> tf.azc.ne
for ext in tar tbz tar.gz tar.xz tar.bz2 tar.lzma tar.lz4 tar.zst tar.lzo tar.lz tar.br tar.7z tar.zip tar.Z tar.lzfse;do
	DO autozip td --force --parallel -1 "${ext}"
	DO azlist tf."${ext}"
	DO autounzip --force --remove --parallel td."${ext}"
	DO azcat --parallel td "${ext}" -1 \> tf.azc.${ext}
	DO azlist tf.asc."${ext}"
done
for ext in 7z zip rar;do
	DO autozip td --force --parallel -1 "${ext}"
	DO azlist tf."${ext}"
	DO autounzip --force --remove --parallel td."${ext}"
done
cd ..
rm -rf "${TDN}"
