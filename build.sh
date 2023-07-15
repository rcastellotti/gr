#!/bin/bash
# SPDX-License-Identifier: MIT

build_install_ovmf(){
	GCCVERS="GCC5"
	git clone --single-branch -b snp-latest https://github.com/AMDESE/ovmf
	pushd ovmf >/dev/null
		git submodule update --init --recursive
	popd >/dev/null

	pushd ovmf >/dev/null
		git apply --ignore-space-change --ignore-whitespace ../ovmf.patch
		make -C BaseTools
		. ./edksetup.sh --reconfig
		nice build -q --cmd-len=64436 -DDEBUG_ON_SERIAL_PORT -n $(getconf _NPROCESSORS_ONLN) ${GCCVERS:+-t $GCCVERS} -a X64 -p OvmfPkg/OvmfPkgX64.dsc

		mkdir -p ../usr/local/share/qemu
		cp -f Build/OvmfX64/DEBUG_$GCCVERS/FV/OVMF_CODE.fd ../usr/local/share/qemu
		cp -f Build/OvmfX64/DEBUG_$GCCVERS/FV/OVMF_VARS.fd ../usr/local/share/qemu
	popd >/dev/null
}

build_install_qemu(){
	git clone --single-branch -b "snp-latest" https://github.com/AMDESE/qemu.git
	MAKE="make -j $(getconf _NPROCESSORS_ONLN)"
	pushd qemu >/dev/null
		git apply ../qemu.patch
		git submodule init
		git submodule update --recursive
		./configure --target-list=x86_64-softmmu --prefix=/mnt/roberto/gr/usr/local --disable-werror
		$MAKE
		$MAKE install
	popd >/dev/null
}

build_install_qemu
build_install_ovmf
