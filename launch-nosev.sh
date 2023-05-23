#!/bin/bash

./usr/local/bin/qemu-system-x86_64 \
-enable-kvm \
-cpu EPYC-v4,host-phys-bits=true \
-smp 16 -m 16G \
-machine type=q35 \
-drive if=pflash,format=raw,unit=0,file=/scratch/roberto/gr/usr/local/share/qemu/OVMF_CODE.fd,readonly=on \
-drive if=pflash,format=raw,unit=1,file=./no-sev-server.fd \
-drive file=./images/server-cloud-config-nosev.iso,media=cdrom,index=0 \
-drive file=./images/no-sev-server.img,if=none,id=disk0,format=raw \
-device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true \
-device scsi-hd,drive=disk0 \
-nographic \
-monitor pty \
-monitor unix:monitor,server,nowait \
-netdev type=tap,script=no,downscript=no,id=net0,ifname=tap2 \
-device virtio-net-pci,mac=52:54:00:cc:62:02,netdev=net0,disable-legacy=on,iommu_platform=true,romfile= 