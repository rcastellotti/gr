#!/bin/bash

# ./usr/local/bin/qemu-system-x86_64 \
#     -enable-kvm \
#     -cpu EPYC-v4,host-phys-bits=true \
#     -smp 16 \
#     -machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off \
#     -object memory-backend-memfd-private,id=ram1,size=16G,share=true \
#     -object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA \
#     -drive if=pflash,format=raw,unit=0,file=OVMF_files/OVMF_CODE_sev.fd,readonly=on \
#     -drive if=pflash,format=raw,unit=1,file=OVMF_files/OVMF_VARS_sev.fd \
#     -drive file=cloud-config-sev.iso,media=cdrom,index=0 \
#     -drive file=sev.img,if=none,id=disk0,format=raw \
#     -device virtio-scsi,id=scsi0 \
#     -device scsi-hd,drive=disk0 \
#     -nographic \
#     -device virtio-net-pci,netdev=net0 \
#     -netdev user,id=net0,hostfwd=tcp::2222-:22

    # ubuntu@sev:~$ lsblk
    # NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    # loop0     7:0    0  73.8M  1 loop /snap/core22/750
    # loop1     7:1    0 170.1M  1 loop /snap/lxd/24918
    # loop2     7:2    0  53.3M  1 loop /snap/snapd/19361
    # sda       8:0    0  23.5G  0 disk 
    # ├─sda1    8:1    0  23.4G  0 part /
    # ├─sda14   8:14   0     4M  0 part 
    # └─sda15   8:15   0   106M  0 part /boot/efi
    # sr0      11:0    1   366K  0 rom  

## virtio-blk:
# ./usr/local/bin/qemu-system-x86_64 \
#     -enable-kvm \
#     -cpu EPYC-v4,host-phys-bits=true \
#     -smp 16 \
#     -machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off \
#     -object memory-backend-memfd-private,id=ram1,size=16G,share=true \
#     -object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA \
#     -drive if=pflash,format=raw,unit=0,file=OVMF_files/OVMF_CODE_sev.fd,readonly=on \
#     -drive if=pflash,format=raw,unit=1,file=OVMF_files/OVMF_VARS_sev.fd \
#     -drive file=cloud-config-sev.iso,media=cdrom,index=0 \
#     -drive file=sev.img,if=none,id=disk0,format=raw \
#     -device virtio-blk-pci,drive=drive0,id=virtblk0,num-queues=4 \
#     -nographic \
#     -device virtio-net-pci,netdev=net0 \
#     -netdev user,id=net0,hostfwd=tcp::2222-:22

    # ubuntu@sev:~$ lsblk
    # NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    # loop0     7:0    0  73.8M  1 loop /snap/core22/750
    # loop1     7:1    0 170.1M  1 loop /snap/lxd/24918
    # loop2     7:2    0  53.3M  1 loop /snap/snapd/19361
    # sda       8:0    0  23.5G  0 disk 
    # ├─sda1    8:1    0  23.4G  0 part /
    # ├─sda14   8:14   0     4M  0 part 
    # └─sda15   8:15   0   106M  0 part /boot/efi
    # sr0      11:0    1   366K  0 rom  



## nvme
./usr/local/bin/qemu-system-x86_64 \
    -enable-kvm \
    -cpu EPYC-v4,host-phys-bits=true \
    -smp 16 \
    -machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off \
    -object memory-backend-memfd-private,id=ram1,size=16G,share=true \
    -object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA \
    -drive if=pflash,format=raw,unit=0,file=OVMF_files/OVMF_CODE_sev.fd,readonly=on \
    -drive if=pflash,format=raw,unit=1,file=OVMF_files/OVMF_VARS_sev.fd \
    -drive file=cloud-config-sev.iso,media=cdrom,index=0 \
    -drive file=sev.img,if=none,id=disk0,format=raw \
    -device nvme,serial=cafebabe,drive=disk0 \
    -nographic \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22
