Encryption at rest (designed to prevent the attacker from accessing the unencrypted data by ensuring the data is encrypted when on disk from Microsoft, cite properly) has been around for a long time, but this leaves a big part of daily computing unencrypted, namely RAM and CPU registers, to tackle this issue major chip producers started to develop a technlogy to enable "confidential computing", namely AMD Secure Encrypted Virtualization (SEV) and Intel Trusted Domain Extensions (TDX). In this short article we try to understand a little more about AMD SEV, assuming nothing and getting our hands dirty step by step.







OVMF is a project maintanied by TianoCore aiming to enable UEFI support for virtual machines, it is based on EDK 2, we will use OVMF to generate the executable firmware and the non-volatile variable store, it is important to create a vm-specific cody of `OVMF_vars.fd` because the variable store should be private for every virtual machine

QEMU is a generic open source machine emulator and virtualizer, we will use QEMU toghether with KVM, the Kernel Virtual machine to virtualize our machines.


It is now our interest to run some benchmarks to understand if and how this tecnhlogies impact the performance of machines, we will run 3 categories of micro-benchmarks: cpu-based benchmarks (compiling some popular open source projects and running the LZ4 compression and decompression algorithm), memory-related benchmarks (TinyMembench and MBW) and I/O related benchmarks (time to perform a number of insertions in a SQLite database and Redis Benchmark)


SEV: 
Linux compilation (defconfig):  357.29826259613037 s   
SQlite 2500 insertions: 3.213946580886841 s   
Mbw:

```console
ubuntu@sev:~/tinyben/results$ cat mbw-2023-06-19-10\:45\:04.txt 
Long uses 8 bytes. Allocating 2*134217728 elements = 2147483648 bytes of memory.
Using 262144 bytes as blocks for memcpy block copy test.
Getting down to business... Doing 10 runs per test.
AVG     Method: MEMCPY  Elapsed: 0.05567        MiB: 1024.00000 Copy: 18394.207 MiB/
AVG     Method: DUMB    Elapsed: 0.18993        MiB: 1024.00000 Copy: 5391.466 MiB/s
AVG     Method: MCBLOCK Elapsed: 0.10281        MiB: 1024.00000 Copy: 9959.849 MiB/s
```

NOSEV:
Linux compilation (defconfig): 319.93260073661804 s
SQLite 2500 insertions: 3.0814554691314697 s         
  

```console
Getting down to business... Doing 10 runs per test.
AVG	Method: MEMCPY	Elapsed: 0.05345	MiB: 1024.00000	Copy: 19159.418 MiB/s
AVG	Method: DUMB	Elapsed: 0.19166	MiB: 1024.00000	Copy: 5342.700 MiB/s
AVG	Method: MCBLOCK	Elapsed: 0.09631	MiB: 1024.00000	Copy: 10632.322 MiB/s
```

### benchmarks

+ Test different system configs (memory and CPUS)
+ AMD-ES enabled and disabled only run cpu intensive benchmarks?
+ Test different machines running at the same time

## todo
- AMD Secure Encrypted Virtualization-Secure Trusted I/O (SEV-TIO)
- SEV on containers (kata)
- bios configuration
- numa enabled/disabled

## References

- https://www.amd.com/system/files/documents/using-amd-secure-encrypted-virtualization-encrypted-state-on-think-system-servers.pdf
- https://documentation.suse.com/sles/15-SP1/html/SLES-amd-sev/art-amd-sev.html
- https://help.ovhcloud.com/csm/en-dedicated-servers-amd-sme-sev?id=kb_article_view&sysparm_article=KB0044018
- https://documentation.suse.com/de-de/sles/15-SP4/html/SLES-all/article-amd-sev.html#table-guestpolicy
- http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt
- https://cloud.google.com/docs/security/encryption/default-encryption
- https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-atrest
- https://docs.aws.amazon.com/whitepapers/latest/efs-encrypted-file-systems/encryption-of-data-at-rest.html
- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html
- https://www.amd.com/en/developer/sev.html
- https://arch.cs.ucdavis.edu/assets/papers/ipdps21-hpc-tee-performance.pdf
- https://cdrdv2.intel.com/v1/dl/getContent/690419
- https://www.amd.com/content/dam/amd/en/documents/developer/sev-tio-whitepaper.pdf
- https://www.amd.com/content/dam/amd/en/documents/developer/58207-using-sev-with-amd-epyc-processors.pdf
- https://www.amd.com/system/files/TechDocs/40332.pdf
- https://www.amd.com/system/files/TechDocs/cloud-security-epyc-hardware-memory-encryption.pdf
- cpuid and some other interesting demos: https://blogs.oracle.com/linux/post/using-amd-secure-memory-encryption-with-oracle-linux
- https://jcadden.medium.com/confidential-computing-with-kubernetes-sev-guest-protection-for-kata-containers-8f29f0a3a2d7
- https://www.kernel.org/doc/html/v5.6/virt/kvm/amd-memory-encryption~.html
- https://www.qemu.org/docs/master/system/i386/amd-memory-encryption.html


- https://www.amd.com/system/files/TechDocs/58019-svsm-draft-specification.pdf

#### Section 3.2 "BIOS Configurations"

## investigating I/O related perfomance

benchmark they ran: fio randread bs=4k iodepth=1 numjobs=1


First of all, what the heck is a block device?

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



We divide 

● Emulation (Full Virtualization)
○ Best option for correctness and abstraction
○ High performance cost
● Paravirtualization
○ Optimize driver and virtual device interaction
○ Guest is “aware” of virtualization
● Pass-Through Mode
○ Best option for performance
○ Strong coupling with hardware

https://compas.cs.stonybrook.edu/~nhonarmand/courses/sp17/cse506/slides/io_virtualization.pdf


virtio-blk with iothread and userspace driver: By offloading I/O processing to a separate thread and utilizing a userspace driver, you can achieve enhanced performance and efficiency for disk operations in the virtual machine.

ahci: AHCI (Advanced Host Controller Interface) is an interface specification for SATA (Serial ATA) host controllers. QEMU can emulate AHCI controllers to provide SATA disk support for virtual machines.

virtio-blk: virtio-blk is another virtualization standard that provides a disk interface for virtual machines. It allows the virtual machine to communicate with virtual disks using the virtio framework, providing good performance and flexibility.

virtio-scsi: virtio-scsi is a virtualization standard that provides a high-performance, lightweight, and efficient interface for storage devices in virtual machines. It allows virtual machines to directly communicate with SCSI devices using the virtio framework.


vfio-pci device assignment: VFIO (Virtual Function I/O) is a framework that allows direct device assignment to virtual machines. VFIO enables bypassing the QEMU emulation layer and providing direct access to the hardware for improved performance and compatibility. VFIO can be used with devices like GPUs, network adapters, and storage controllers.

QEMU emulated devices: QEMU provides emulation for a wide range of devices, including network devices (e.g., Intel e1000, virtio-net), storage devices (e.g., IDE, SCSI), graphics devices (e.g., VGA, QXL), sound devices, input devices (e.g., keyboard, mouse), and more. These emulated devices allow virtual machines to interact with virtualized hardware.

QEMU virtio IOThread: QEMU provides an IOThread option for virtio devices, such as virtio-net (network) and virtio-scsi (storage). IOThread allows offloading the device I/O processing to a separate thread, improving performance by leveraging multiple CPU cores.

QEMU userspace NVMe driver: QEMU includes a userspace NVMe driver that enables virtual machines to interact with NVMe (Non-Volatile Memory Express) storage devices. This driver allows for efficient I/O operations and high-performance access to NVMe devices from within the virtual machine.