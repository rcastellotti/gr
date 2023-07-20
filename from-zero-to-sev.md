Encryption at rest (designed to prevent the attacker from accessing the unencrypted data by ensuring the data is encrypted when on disk from Microsoft, cite properly) has been around for a long time, but this leaves a big part of daily computing unencrypted, namely RAM and CPU registers, to tackle this issue major chip producers started to develop a technlogy to enable "confidential computing", namely AMD Secure Encrypted Virtualization (SEV) and Intel Trusted Domain Extensions (TDX). In this short article we try to understand a little more about AMD SEV, assuming nothing and getting our hands dirty step by step.


OVMF is a project maintanied by TianoCore aiming to enable UEFI support for virtual machines, it is based on EDK 2, we will use OVMF to generate the executable firmware and the non-volatile variable store, it is important to create a vm-specific cody of `OVMF_vars.fd` because the variable store should be private for every virtual machine

QEMU is a generic open source machine emulator and virtualizer, we will use QEMU toghether with KVM, the Kernel Virtual machine to virtualize our machines.

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


Block devices are characterized by random access to data organized in fixed-size blocks. Examples of such devices are hard drives, CD-ROM drives, RAM disks, etc. The speed of block devices is generally much higher than the speed of character devices, and their performance is also important.

## Virtio
+ Virtio was chosen to be the main platform for IO virtualization in KVM
+ The idea behind it is to have a common framework for hypervisors for IO virtualization


## virtio-blk
The virtio-blk device is a simple virtual block device. The FE driver (in the User VM space) places read, write, and other requests onto the virtqueue, so that the BE driver (in the Service VM space) can process them accordingly. Communication between the FE and BE is based on the virtio kick and notify mechanism.



## virtio-scsi

The virtio-scsi feature is a new para-virtualized SCSI controller device. It is the foundation of an alternative storage implementation for KVM Virtualization’s storage stack replacing__ virtio-blk__ and improving upon its capabilities. It provides the same performance as virtio-blk, and adds the following immediate benefits:

+ __Improved scalability__ virtual machines can connect to more storage devices (the virtio-scsi can handle multiple block devices per virtual SCSI adapter).
+ __Standard command set__ virtio-scsi uses standard SCSI command sets, simplifying new feature addition.
+ __Standard device naming__ virtio-scsi disks use the same paths as a bare-metal system. This simplifies physical-to-virtual and virtual-to-virtual migration.
+ __SCSI device passthrough__ virtio-scsi can present physical storage devices directly to guests.
Virtio-SCSI provides the ability to connect directly to SCSI LUNs and significantly improves scalability compared to virtio-blk. The advantage of virtio-SCSI is that it is capable of handling hundreds of devices compared to virtio-blk which can only handle approximately 30 devices and exhausts PCI slots.

Designed to replace virtio-blk, virtio-scsi retains virtio-blk’s performance advantages while improving storage scalability, allowing access to multiple storage devices through a single controller, and enabling reuse of the guest operating system’s SCSI stack.


https://www.linux-kvm.org/page/Virtio
https://www.ovirt.org/develop/release-management/features/storage/virtio-scsi.html
https://www.qemu.org/2021/01/19/virtio-blk-scsi-configuration/
https://projectacrn.github.io/latest/developer-guides/hld/virtio-blk.html
https://linux-kernel-labs.github.io/refs/heads/master/labs/block_device_drivers.html
https://qemu-project.gitlab.io/qemu/system/devices/nvme.html
https://www.qemu.org/2020/09/14/qemu-storage-overview/

virtio-blk with iothread and userspace driver: By offloading I/O processing to a separate thread and utilizing a userspace driver, you can achieve enhanced performance and efficiency for disk operations in the virtual machine.

ahci: AHCI (Advanced Host Controller Interface) is an interface specification for SATA (Serial ATA) host controllers. QEMU can emulate AHCI controllers to provide SATA disk support for virtual machines.

virtio-blk: virtio-blk is another virtualization standard that provides a disk interface for virtual machines. It allows the virtual machine to communicate with virtual disks using the virtio framework, providing good performance and flexibility.

virtio-scsi: virtio-scsi is a virtualization standard that provides a high-performance, lightweight, and efficient interface for storage devices in virtual machines. It allows virtual machines to directly communicate with SCSI devices using the virtio framework.

QEMU userspace NVMe driver: QEMU includes a userspace NVMe driver that enables virtual machines to interact with NVMe (Non-Volatile Memory Express) storage devices. This driver allows for efficient I/O operations and high-performance access to NVMe devices from within the virtual machine.
