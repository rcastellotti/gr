# GR - AMD Confidential Computing Technologies Evaluation Report

## Instructions to launch SEV machines

### Prepare the host toolchain
Compile the custom OVMF and QEMU provided by AMD:

```bash
./build.sh <dir>
```

### Misc

- [config](.config/) folder contains some configurations for ubuntu cloudimg.
- Download an ubuntu image: `wget https://cloud-images.ubuntu.com/kinetic/current/kinetic-server-cloudimg-amd64.img`
- before launching guests you should run `./prepare.sh`

This readme assumes ovmf and qemu are in `./usr`, i.e. that you ran `./build.sh ./usr`, if that is not the case adapt the following commands to reflect your edit.

### Launch a NOSEV guest. 

```bash
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./nosev.sh ./usr/qemu/usr/bin/
```

### Launch an AMD SEV-SNP guest. 

```bash
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./sev.sh ./usr/qemu/usr/bin/
```

## Inside the guest VM, verify SEV-SNP is enabled:
`sudo dmesg | grep snp -i ` should indicate `Memory Encryption Features active: AMD SEV SEV-ES SEV-SNP`

## Interact with the machines
- SEV machine: connect using ssh `ssh -p 2222 ubuntu@localhost`
- NOSEV machine: connect using ssh `ssh -p 2223 ubuntu@localhost`

## resources
- <https://cloudinit.readthedocs.io/en/latest/reference/examples.html>
- <https://github.com/AMDESE/linux>
- <https://github.com/AMDESE/qemu>
- <https://github.com/AMDESE/ovmf>
- <http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt>
- <https://www.kernel.org/doc/html/v5.6/virt/kvm/amd-memory-encryption~.html>
- <https://www.qemu.org/docs/master/system/i386/amd-memory-encryption.html>
- <https://www.amd.com/content/dam/amd/en/documents/developer/58207-using-sev-with-amd-epyc-processors.pdf>
- <https://www.amd.com/en/developer/sev.html>
- <https://www.linux-kvm.org/page/Virtio>
- <https://www.ovirt.org/develop/release-management/features/storage/virtio-scsi.html>
- <https://www.qemu.org/2021/01/19/virtio-blk-scsi-configuration/>
- <https://projectacrn.github.io/latest/developer-guides/hld/virtio-blk.html>
- <https://linux-kernel-labs.github.io/refs/heads/master/labs/block_device_drivers.html>
- <https://qemu-project.gitlab.io/qemu/system/devices/nvme.html>
- <https://www.qemu.org/2020/09/14/qemu-storage-overview/>
- <https://blogs.oracle.com/linux/post/using-amd-secure-memory-encryption-with-oracle-linux>
- <https://www.amd.com/system/files/documents/using-amd-secure-encrypted-virtualization-encrypted-state-on-think-system-servers.pdf>
- <https://documentation.suse.com/sles/15-SP1/html/SLES-amd-sev/art-amd-sev.html>
- <https://help.ovhcloud.com/csm/en-dedicated-servers-amd-sme-sev?id=kb_article_view&sysparm_article=KB0044018>
- <https://documentation.suse.com/de-de/sles/15-SP4/html/SLES-all/article-amd-sev.html#table-guestpolicy>
- <http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt>
- <https://www.amd.com/system/files/TechDocs/cloud-security-epyc-hardware-memory-encryption.pdf>
- <https://jcadden.medium.com/confidential-computing-with-kubernetes-sev-guest-protection-for-kata-containers-8f29f0a3a2d7>
