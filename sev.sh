#!/bin/bash

./usr/local/bin/qemu-system-x86_64 \
    -enable-kvm \
    -cpu EPYC-v4,host-phys-bits=true \
    -smp 16 \
    -machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off \
    -object memory-backend-memfd-private,id=ram1,size=16G,share=true \
    -object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA \
    -drive if=pflash,format=raw,unit=0,file=/mnt/roberto/gr/OVMF_files/OVMF_CODE_sev.fd,readonly=on \
    -drive if=pflash,format=raw,unit=1,file=/mnt/roberto/gr/OVMF_files/OVMF_VARS_sev.fd \
    -drive file=/mnt/roberto/gr/cloud-config-sev.iso,media=cdrom,index=0 \
    -drive file=/mnt/roberto/gr/sev.img,if=none,id=disk0,format=raw \
    -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true \
    -device scsi-hd,drive=disk0 \
    -nographic \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22
