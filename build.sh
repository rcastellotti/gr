#!/bin/bash
# SPDX-License-Identifier: MIT

SCRIPT_DIR="$(dirname $0)"
. ${SCRIPT_DIR}/stable-commits
[ -e /etc/os-release ] && . /etc/os-release

run_cmd()
{
	echo "$*"

	eval "$*" || {
		echo "ERROR: $*"
		exit 1
	}
}

build_install_ovmf()
{
	DEST="$1"

	GCC_VERSION=$(gcc -v 2>&1 | tail -1 | awk '{print $3}')
	GCC_MAJOR=$(echo $GCC_VERSION | awk -F . '{print $1}')
	GCC_MINOR=$(echo $GCC_VERSION | awk -F . '{print $2}')
	if [ "$GCC_MAJOR" == "4" ]; then
		GCCVERS="GCC${GCC_MAJOR}${GCC_MINOR}"
	else
		GCCVERS="GCC5"
	fi

	# captures all the OVMF debug messages on qemu serial log. remove -DDEBUG_ON_SERIAL_PORT to disable it.
	BUILD_CMD="nice build -q --cmd-len=64436 -DDEBUG_ON_SERIAL_PORT -n $(getconf _NPROCESSORS_ONLN) ${GCCVERS:+-t $GCCVERS} -a X64 -p OvmfPkg/OvmfPkgX64.dsc"

	[ -d ovmf ] || {
		run_cmd git clone --single-branch -b ${OVMF_BRANCH} ${OVMF_GIT_URL} ovmf

		pushd ovmf >/dev/null
			run_cmd git submodule update --init --recursive
		popd >/dev/null
	}

	pushd ovmf >/dev/null
		run_cmd git apply --ignore-space-change --ignore-whitespace ../ovmf.patch
		run_cmd make -C BaseTools
		. ./edksetup.sh --reconfig
		run_cmd $BUILD_CMD

		mkdir -p $DEST
		run_cmd cp -f Build/OvmfX64/DEBUG_$GCCVERS/FV/OVMF_CODE.fd $DEST
		run_cmd cp -f Build/OvmfX64/DEBUG_$GCCVERS/FV/OVMF_VARS.fd $DEST
	popd >/dev/null
}

build_install_qemu()
{
	DEST="$1"

	[ -d qemu ] || run_cmd git clone --single-branch -b ${QEMU_BRANCH} ${QEMU_GIT_URL} qemu

	MAKE="make -j $(getconf _NPROCESSORS_ONLN) LOCALVERSION="

	pushd qemu >/dev/null
		run_cmd git apply ../qemu.patch
		run_cmd ./configure --target-list=x86_64-softmmu --prefix=$DEST --disable-werror
		run_cmd $MAKE
		run_cmd $MAKE install
	popd >/dev/null
}

function usage()
{
	echo "Usage: $0 [OPTIONS] [COMPONENT]"
	echo "  where COMPONENT is an individual component to build:"
	echo "    qemu, ovmf, kernel [host|guest]"
	echo "    (default is to build all components)"
	echo "  where OPTIONS are:"
	echo "  --install PATH          Installation path (default $INSTALL_DIR)"
	echo "  -h|--help               Usage information"

	exit 1
}

INSTALL_DIR="`pwd`/usr/local"

while [ -n "$1" ]; do
	case "$1" in
	--install)
		[ -z "$2" ] && usage
		INSTALL_DIR="$2"
		shift; shift
		;;
	-h|--help)
		usage
		;;
	-*|--*)
		echo "Unsupported option: [$1]"
		usage
		;;
	*)
		break
		;;
	esac
done

mkdir -p $INSTALL_DIR
IDIR=$INSTALL_DIR
INSTALL_DIR=$(readlink -e $INSTALL_DIR)
[ -n "$INSTALL_DIR" -a -d "$INSTALL_DIR" ] || {
	echo "Installation directory [$IDIR] does not exist, exiting"
	exit 1
}

if [ -z "$1" ]; then
	build_install_qemu "$INSTALL_DIR"
	build_install_ovmf "$INSTALL_DIR/share/qemu"
else
	case "$1" in
	qemu)
		build_install_qemu "$INSTALL_DIR"
		;;
	ovmf)
		build_install_ovmf "$INSTALL_DIR/share/qemu"
		;;
	esac
fi
