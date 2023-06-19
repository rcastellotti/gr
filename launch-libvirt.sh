#!/bin/bash

# this scripts launches a SEV ubuntu machine with upstream QEMU and Libvirt,
# it assumes `config/cloud-config-sev.yml` exists and is correct

wget https://cloud-images.ubuntu.com/focal/current/jammy-server-cloudimg-amd64.img
sudo qemu-img convert jammy-server-cloudimg-amd64.img /var/lib/libvirt/images/sev.img
sudo cloud-localds /var/lib/libvirt/images/sev-cloud-config.iso config/cloud-config-sev.yml

sudo virt-install \
              --name sev \
              --memory 4096 \
              --memtune hard_limit=4563402 \
              --boot uefi \
              --os-variant ubuntu22.04 \
              --import \
              --controller type=scsi,model=virtio-scsi,driver.iommu=on \
              --controller type=virtio-serial,driver.iommu=on \
              --network network=default,model=virtio,driver.iommu=on \
              --memballoon driver.iommu=on \
              --graphics none \
              --launchSecurity sev,policy=0x07

# connect to the machine: `sudo virsh -c qemu:///system console sev`

# delete the machine: 
# sudo virsh -c qemu:///system undefine --nvram sev 
# sudo virsh -c qemu:///system destroy sev
