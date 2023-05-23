#!/bin/bash

# -sev          enable SEV support"
# -sev-es       enable SEV-ES support"
# -sev-snp      enable SEV-SNP support"
# -sev-policy   policy to use for SEV (SEV=0x01, SEV-ES=0x41, SEV-SNP=0x30000)"
# -snp-flags    SEV-SNP initialization flags (0 is default)"

./usr/local/bin/qemu-system-x86_64 \
-enable-kvm \
-cpu EPYC-v4,host-phys-bits=true \
-smp 16 \
-machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off \
-object memory-backend-memfd-private,id=ram1,size=16G,share=true \
-object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA \
-drive if=pflash,format=raw,unit=0,file=/scratch/roberto/gr/OVMF_files/OVMF_CODE_server.fd,readonly=on \
-drive if=pflash,format=raw,unit=1,file=./sev-server.fd \
-drive file=./images/server-cloud-config-sev.iso,media=cdrom,index=0 \
-drive file=./images/sev-server.img,if=none,id=disk0,format=raw \
-device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true \
-device scsi-hd,drive=disk0 \
-nographic \
-monitor pty \
-monitor unix:sev-server,server,nowait \
-netdev type=tap,script=no,downscript=no,id=net0,ifname=tap1 \
-device virtio-net-pci,mac=52:54:00:cc:62:01,netdev=net0,disable-legacy=on,iommu_platform=true,romfile=