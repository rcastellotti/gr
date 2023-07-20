Encryption at rest (designed to prevent the attacker from accessing the unencrypted data by ensuring the data is encrypted when on disk from Microsoft, cite properly) has been around for a long time, but this leaves a big part of daily computing unencrypted, namely RAM and CPU registers, to tackle this issue major chip producers started to develop a technlogy to enable "confidential computing", namely AMD Secure Encrypted Virtualization (SEV) and Intel Trusted Domain Extensions (TDX). In this short article we try to understand a little more about AMD SEV, assuming nothing and getting our hands dirty step by step.




- https://www.amd.com/system/files/documents/using-amd-secure-encrypted-virtualization-encrypted-state-on-think-system-servers.pdf
- https://documentation.suse.com/sles/15-SP1/html/SLES-amd-sev/art-amd-sev.html
- https://documentation.suse.com/de-de/sles/15-SP4/html/SLES-all/article-amd-sev.html#table-guestpolicy
- http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt
- https://cloud.google.com/docs/security/encryption/default-encryption
- https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-atrest
- https://docs.aws.amazon.com/whitepapers/latest/efs-encrypted-file-systems/encryption-of-data-at-rest.html
- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html
- https://www.amd.com/en/developer/sev.html
- https://arch.cs.ucdavis.edu/assets/papers/ipdps21-hpc-tee-performance.pdf
- https://cdrdv2.intel.com/v1/dl/getContent/690419
- https://www.amd.com/content/dam/amd/en/documents/developer/58207-using-sev-with-amd-epyc-processors.pdf
- https://www.amd.com/system/files/TechDocs/cloud-security-epyc-hardware-memory-encryption.pdf
- cpuid and some other interesting demos: https://blogs.oracle.com/linux/post/using-amd-secure-memory-encryption-with-oracle-linux
- https://jcadden.medium.com/confidential-computing-with-kubernetes-sev-guest-protection-for-kata-containers-8f29f0a3a2d7
- https://www.kernel.org/doc/html/v5.6/virt/kvm/amd-memory-encryption~.html
- https://www.qemu.org/docs/master/system/i386/amd-memory-encryption.html
- https://www.amd.com/system/files/TechDocs/58019-svsm-draft-specification.pdf

https://www.linux-kvm.org/images/archive/f/f5/20110823142849!2011-forum-virtio-scsi.pdf

Block devices are characterized by random access to data organized in fixed-size blocks. Examples of such devices are hard drives, CD-ROM drives, RAM disks, etc. The speed of block devices is generally much higher than the speed of character devices, and their performance is also important.

Designhttps://www.linux-kvm.org/page/Virtio
https://www.ovirt.org/develop/release-management/features/storage/virtio-scsi.html
https://www.qemu.org/2021/01/19/virtio-blk-scsi-configuration/
https://projectacrn.github.io/latest/developer-guides/hld/virtio-blk.html
https://linux-kernel-labs.github.io/refs/heads/master/labs/block_device_drivers.html
https://qemu-project.gitlab.io/qemu/system/devices/nvme.html
https://www.qemu.org/2020/09/14/qemu-storage-overview/
