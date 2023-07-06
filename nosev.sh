#!/bin/bash

# ./usr/local/bin/qemu-system-x86_64 \
#     -enable-kvm \
#     -cpu EPYC-v4,host-phys-bits=true \
#     -smp 16 \
#     -m 16G \
#     -machine type=q35 \
#     -drive if=pflash,format=raw,unit=0,file=/mnt/roberto/gr/OVMF_files/OVMF_CODE_nosev.fd,readonly=on \
#     -drive if=pflash,format=raw,unit=1,file=/mnt/roberto/gr/OVMF_files/OVMF_VARS_nosev.fd \
#     -drive file=cloud-config-nosev.iso,media=cdrom,index=0 \
#     -drive file=nosev.img,if=none,id=disk0,format=raw \
#     -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true \
#     -device scsi-hd,drive=disk0 \
#     -nographic \
#     -device virtio-net-pci,netdev=net0 \
#     -netdev user,id=net0,hostfwd=tcp::2223-:22



## virtio-blk:
# ./usr/local/bin/qemu-system-x86_64 \
#     -enable-kvm \
#     -cpu EPYC-v4,host-phys-bits=true \
#     -smp 16 \
#     -m 16G \
#     -machine type=q35 \
#     -drive if=pflash,format=raw,unit=0,file=/mnt/roberto/gr/OVMF_files/OVMF_CODE_nosev.fd,readonly=on \
#     -drive if=pflash,format=raw,unit=1,file=/mnt/roberto/gr/OVMF_files/OVMF_VARS_nosev.fd \
#     -drive file=cloud-config-nosev.iso,media=cdrom,index=0 \
#     -drive file=nosev.img,if=none,id=drive0,format=raw \
#     -device virtio-blk-pci,drive=drive0,id=virtblk0,num-queues=4 \
#     -nographic \
#     -device virtio-net-pci,netdev=net0 \
#     -netdev user,id=net0,hostfwd=tcp::2223-:22

    # ubuntu@nosev:~$ lsblk
    # NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    # loop0     7:0    0  73.8M  1 loop /snap/core22/750
    # loop1     7:1    0 170.1M  1 loop /snap/lxd/24918
    # loop2     7:2    0  53.3M  1 loop /snap/snapd/19361
    # loop3     7:3    0  53.3M  1 loop /snap/snapd/19457
    # loop4     7:4    0  73.9M  1 loop /snap/core22/766
    # loop5     7:5    0 173.5M  1 loop /snap/lxd/25112
    # sr0      11:0    1   366K  0 rom  
    # sr1      11:1    1  1024M  0 rom  
    # vda     252:0    0  23.5G  0 disk 
    # ├─vda1  252:1    0  23.4G  0 part /
    # ├─vda14 252:14   0     4M  0 part 
    # └─vda15 252:15   0   106M  0 part /boot/efi



## nvme
./usr/local/bin/qemu-system-x86_64 \
    -enable-kvm \
    -cpu EPYC-v4,host-phys-bits=true \
    -smp 16 \
    -m 16G \
    -machine type=q35 \
    -drive if=pflash,format=raw,unit=0,file=/mnt/roberto/gr/OVMF_files/OVMF_CODE_nosev.fd,readonly=on \
    -drive if=pflash,format=raw,unit=1,file=/mnt/roberto/gr/OVMF_files/OVMF_VARS_nosev.fd \
    -drive file=cloud-config-nosev.iso,media=cdrom,index=0 \
    -drive file=nosev.img,if=none,id=disk0,format=raw \
    -device nvme,serial=cafebabe,drive=disk0 \
    -nographic \
    -device virtio-net-pci,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2223-:22

    # ubuntu@nosev:~$ lsblk
    # NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
    # loop0          7:0    0  73.8M  1 loop /snap/core22/750
    # loop1          7:1    0  73.9M  1 loop /snap/core22/766
    # loop2          7:2    0 170.1M  1 loop /snap/lxd/24918
    # loop3          7:3    0 173.5M  1 loop /snap/lxd/25112
    # loop4          7:4    0  53.3M  1 loop /snap/snapd/19361
    # loop5          7:5    0  53.3M  1 loop /snap/snapd/19457
    # sr0           11:0    1   366K  0 rom  
    # sr1           11:1    1  1024M  0 rom  
    # nvme0n1      259:0    0  23.5G  0 disk 
    # ├─nvme0n1p1  259:1    0  23.4G  0 part /
    # ├─nvme0n1p14 259:2    0     4M  0 part 
    # └─nvme0n1p15 259:3    0   106M  0 part /boot/efi


