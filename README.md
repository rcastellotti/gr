# GR - Evaluating Confidential Computing with Unikernels

## from zero to SEV-SNP

## libvirt

### questions:
+ can we provide a demo of docker protected by SEV?

https://www.amd.com/system/files/TechDocs/memory-encryption-white-paper.pdf
https://documentation.suse.com/sles/15-SP1/html/SLES-amd-sev/art-amd-sev.html


## launching a sev machine 

```bash
wget https://cloud-images.ubuntu.com/focal/current/jammy-server-cloudimg-amd64.img
sudo qemu-img convert focal-server-cloudimg-amd64.img /var/lib/libvirt/images/sev.img
sudo cloud-localds /var/lib/libvirt/images/sev-cloud-config.iso cloud-config.yml
```

```bash
sudo virt-install \
              --name sev \
              --memory 4096 \
              --boot uefi \
              --disk /var/lib/libvirt/images/sev.img,device=disk,bus=scsi \
              --disk /var/lib/libvirt/images/sev-cloud-config.iso,device=cdrom \
              --os-variant ubuntu-lts-latest \
              --import \
              --controller type=scsi,model=virtio-scsi,driver.iommu=on \
              --controller type=virtio-serial,driver.iommu=on \
              --network network=default,model=virtio,driver.iommu=on \
              --memballoon driver.iommu=on \
              --graphics none \
              --launchSecurity sev
```


wget https://cloud-images.ubuntu.com/focal/current/jammy-server-cloudimg-amd64.img
