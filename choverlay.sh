#!/bin/sh
# sudo apt install fuse_overlayfs

choverlay() {
	if [ "${1}" == "-s" ]; then
		# use superuser mounter
		local SUDO=true
		shift
	fi

	# tp_apt_i fuse_overlayfs
	SUDO=${SUDO} choverlay_ ${1-$(pwd)} $(mktemp -d) $(mktemp -d)
}

choverlay_() {
	local L0=${1} UPPERDIR=${2} L1=${3}
	local NAME0=$(echo "${L0}" | sed s#/#_#g)
	local NAME1=$(echo "${L1}" | sed s#/#_#g)
	local METAFILE0=/tmp/choverlay.${NAME0}
	local METAFILE1=/tmp/choverlay.${NAME1}
	[ -f "${METAFILE0}" ] && local LDS0=$(cat ${METAFILE0}) || local LDS0=${L0}
	local LDS1=${LDS0}:${UPPERDIR}
	echo ${LDS1} > ${METAFILE1}
	if [ "${SUDO}" ]; then
		sudo mount -t overlay stack_${NAME1} -o lowerdir=${LDS0},upperdir=${UPPERDIR},workdir=$(mktemp -d) ${L1}
	else
		fuse-overlayfs -o lowerdir=${LDS0},upperdir=${UPPERDIR},workdir=$(mktemp -d)  ${L1}
	fi
	pushd ${L1}/
}

choverlayx() {
	if [ "${1}" == "-s" ]; then
		local SUDO=true
		shift
	fi

	local L=${PWD}
	local NAME=$(echo "${L}" | sed s#/#_#g)
	popd
	if [ "${SUDO}" ]; then
		sudo umount ${L}
	else
		sudo fusermount -u ${L}
	fi
	rm /tmp/choverlay.${NAME}
}
