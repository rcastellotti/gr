# GR - Evaluating Confidential Computing with Unikernels

## from zero to SEV-SNP

Confidential Computing started to become relevant in the last 10 years. In these years the way software is shipped in production changed radically, almost everyone now uses cloud providers (Google, Microsoft and Amazon), this leads to customers running their code on machines they don't own. It is logic that customers want to be sure no one can access their code, not other customers running vms on the same hardware, nor whoever is controlling the hypervisor (cloud vendor) or in worst case scenarios malign actors who compromised the physical machine. 
In some sectors it might be crucial that whoever is running our workloads has no access to our customer's data.

Encryption  at rest (designed to prevent the attacker from accessing the unencrypted data by ensuring the data is encrypted when on disk from Microsoft, cite properly) has been around for a long time, but this leaves a big part of daily computing unencrypted, namely RAM and CPU registers, to tackle this issue major chip producers started to develop a technlogy to enable "confidential computing", namely AMD Secure Encrypted Virtualization (SEV) and Intel Trusted Domain Extensions (TDX). In this short article we try to understand a little more about AMD SEV, assuming nothing and getting our hands dirty step by step.


### AMD Secure Memory Encryption (SME)
AMD SME is the basic building block for the more sophisticated thing we'll cover later, so it might be beneficial to understand how it works. Memory operations are performed via dedicated hardware, an entirely different chip on die 
![read-write](img/read_write.png)

TSME-m memory guard on ryzen pro

### AMD Secure Encrypyted Virtualization (SEV)
### AMD Secure Encrypted Virtualization-Encrypted State (SEV-ES)
### AMD Secure Encrypted Virtualization-Secure Nested Paging (SEV-SNP)
### AMD Secure Encrypted Virtualization-Secure Trusted I/O  (SEV-TIO)


### Launching a SEV machine with QEMU

## libvirt

What is libvirt? 

```bash
wget https://cloud-images.ubuntu.com/focal/current/jammy-server-cloudimg-amd64.img
sudo qemu-img convert jammy-server-cloudimg-amd64.img /var/lib/libvirt/images/sev.img
sudo cloud-localds /var/lib/libvirt/images/sev-cloud-config.iso config/cloud-config-sev.yml
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

#### OVMF
ok so apparently the ovmf fd stuff is something that contians the executable firmware and the non-volatile variable store,  we shall make a vm specific copy because the variable store 
should be private to each virtual machine

When launching a SEV machine like this I cannot enable SEV-SNP
I guess this is because it is not supported, 

```


### questions:
+ can we provide a demo of docker protected by SEV?

## References
+ https://www.amd.com/system/files/TechDocs/memory-encryption-white-paper.pdf
+ https://www.amd.com/system/files/techdocs/sev-snp-strengthening-vm-isolation-with-integrity-protection-and-more.pdf
+ https://documentation.suse.com/sles/15-SP1/html/SLES-amd-sev/art-amd-sev.html
+ https://help.ovhcloud.com/csm/en-dedicated-servers-amd-sme-sev?id=kb_article_view&sysparm_article=KB0044018
+ https://libvirt.org/kbase/launch_security_sev.html
+ https://documentation.suse.com/de-de/sles/15-SP4/html/SLES-all/article-amd-sev.html#table-guestpolicy
+ http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt
+ https://www.qemu.org/docs/master/system/i386/amd-memory-encryption.html
+ https://cloud.google.com/docs/security/encryption/default-encryption
+ https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-atrest
+ https://docs.aws.amazon.com/whitepapers/latest/efs-encrypted-file-systems/encryption-of-data-at-rest.html
+ https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html
+ https://www.amd.com/en/developer/sev.html
+ https://arch.cs.ucdavis.edu/assets/papers/ipdps21-hpc-tee-performance.pdf
+ https://cdrdv2.intel.com/v1/dl/getContent/690419 
+ https://www.amd.com/content/dam/amd/en/documents/developer/sev-tio-whitepaper.pdf
+ https://www.amd.com/system/files/TechDocs/58019-svsm-draft-specification.pdf
+ https://www.amd.com/content/dam/amd/en/documents/developer/58207-using-sev-with-amd-epyc-processors.pdf
+ https://www.amd.com/system/files/TechDocs/cloud-security-epyc-hardware-memory-encryption.pdf