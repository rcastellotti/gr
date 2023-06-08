# GR - Evaluating Confidential Computing with Unikernels

## from zero to SEV-SNP

## libvirt

### questions:
+ can we provide a demo of docker protected by SEV?

https://www.amd.com/system/files/TechDocs/memory-encryption-white-paper.pdf
https://www.amd.com/system/files/techdocs/sev-snp-strengthening-vm-isolation-with-integrity-protection-and-more.pdf
https://documentation.suse.com/sles/15-SP1/html/SLES-amd-sev/art-amd-sev.html
https://help.ovhcloud.com/csm/en-dedicated-servers-amd-sme-sev?id=kb_article_view&sysparm_article=KB0044018
https://libvirt.org/kbase/launch_security_sev.html
https://documentation.suse.com/de-de/sles/15-SP4/html/SLES-all/article-amd-sev.html#table-guestpolicy
http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt
https://www.qemu.org/docs/master/system/i386/amd-memory-encryption.html

https://arch.cs.ucdavis.edu/assets/papers/ipdps21-hpc-tee-performance.pdf
## launching a sev machine 

```bash
wget https://cloud-images.ubuntu.com/focal/current/jammy-server-cloudimg-amd64.img
sudo qemu-img convert jammy-server-cloudimg-amd64.img /var/lib/libvirt/images/sev.img
sudo cloud-localds /var/lib/libvirt/images/sev-cloud-config.iso cloud-config.yml
```

```bash
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
```

## connect to the machine

`sudo virsh -c qemu:///system console sev`

## delete the machine
```bash
sudo virsh -c qemu:///system undefine --nvram sev
sudo virsh -c qemu:///system destroy sev

When launching a SEV machine like this I cannot enable SEV-SNP
I guess this is because it is not supported, 

# qemu-img create -f qcow2 ubuntu-18.04.qcow2 30G questo comando cosa fa?

# ovmf what the f is this 

```

ok so apparently the ovmf fd stuff is something that contians the executable firmware and the non-volatile variable store,  we shall make a vm specific copy because the variable store 
should be private to each virtual machine

