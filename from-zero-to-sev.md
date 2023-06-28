# GR - Evaluating Confidential Computing with Unikernels

## from zero to SEV-SNP

Confidential Computing started to become relevant in the last 10 years. In these years the way software is shipped in production changed radically, almost everyone now uses cloud providers (Google, Microsoft and Amazon), this leads to customers running their code on machines they don't own. It is logic that customers want to be sure no one can access their code, not other customers running vms on the same hardware, nor whoever is controlling the hypervisor (cloud vendor) or in worst case scenarios malign actors who compromised the physical machine.
In some sectors it might be crucial that whoever is running our workloads has no access to our customer's data.

### demo attack to show how simple it is to read memory inside a vm if hypervisor is compromised or an human operator is acting maliciously

Let's demo a very simple attack, first of all we start two machines, `sev` and `nosev`, the former has SEV enabled, as we can check:

```bash
ubuntu@sev:~$ sudo dmesg | grep SEV
[   18.360846] Memory Encryption Features active: AMD SEV SEV-ES SEV-SNP
[   18.590902] SEV: Using SNP CPUID table, 31 entries present.
[   18.850633] SEV: SNP guest platform device initialized.
```

We will write something into a file and cat it in order to load the data in memory

```bash
ubuntu@sev:~$ echo "hello from the SEV machine!" > sev.txt
ubuntu@sev:~$ cat sev.txt
hello from the SEV machine!
```

```bash
ubuntu@nosev:~$ echo "hello from the NOSEV machine!" > nosev.txt
ubuntu@nosev:~$ cat nosev.txt
hello from the NOSEV machine!
```

We now get the processes' PIDS to inspect the memory:

```bash
[nix-shell:~]$ ps -aux | grep qemu
root     3095337  1.0  0.2 20358396 1275848 pts/0 Sl+ 12:43   0:22 ./usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4,host-phys-bits=true -smp 16 -m 16G -machine type=q35 -drive if=pflash,format=raw,unit=0,file=/scratch/roberto/gr/usr/local/share/qemu/OVMF_CODE.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=./nosev.fd -drive file=cloud-config-nosev.iso,media=cdrom,index=0 -drive file=nosev.img,if=none,id=disk0,format=raw -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -nographic -monitor pty -monitor unix:monitor,server,nowait -netdev type=tap,script=no,downscript=no,id=net0,ifname=tap3 -device virtio-net-pci,mac=52:54:00:cc:62:03,netdev=net0,disable-legacy=on,iommu_platform=true,romfile=
root     3115638  7.8  3.2 19789772 16820448 pts/4 Sl+ 13:11   0:44 ./usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4,host-phys-bits=true -smp 16 -machine type=q35,confidential-guest-support=sev0,memory-backend=ram1,kvm-type=protected,vmport=off -object memory-backend-memfd-private,id=ram1,size=16G,share=true -object sev-snp-guest,id=sev0,policy=0x30000,cbitpos=51,reduced-phys-bits=1,init-flags=0,host-data=b2l3bmNvd3FuY21wbXA -drive if=pflash,format=raw,unit=0,file=/scratch/roberto/gr/OVMF_files/OVMF_CODE_sev.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=./sev.fd -drive file=cloud-config-sev.iso,media=cdrom,index=0 -drive file=sev.img,if=none,id=disk0,format=raw -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -nographic -monitor pty -monitor unix:monitor,server,nowait -netdev type=tap,script=no,downscript=no,id=net0,ifname=tap4 -device virtio-net-pci,mac=52:54:00:cc:62:04,netdev=net0,disable-legacy=on,iommu_platform=true,romfile=
roberto  3121836  0.0  0.0   6632  1828 pts/3    S+   13:20   0:00 grep qemu
```

Now we can dump the memory for the processes using `gcore`

```bash
[nix-shell:~]$ sudo gcore -o mem-dump 3115638
[nix-shell:~]$ grep -rnw mem-dump.3115638 -e "hello from the SEV machine!"
[nix-shell:~]$
```

```bash
[nix-shell:~]$ sudo gcore -o mem-dump 3095337
[nix-shell:~]$ grep -rnw mem-dump.3095337 -e "hello from the NOSEV machine!"
grep: mem-dump.3095337: binary file matches
```

From the host machine we are able to see nosev's machine memory while this is not possible with SEV enabled.

Encryption at rest (designed to prevent the attacker from accessing the unencrypted data by ensuring the data is encrypted when on disk from Microsoft, cite properly) has been around for a long time, but this leaves a big part of daily computing unencrypted, namely RAM and CPU registers, to tackle this issue major chip producers started to develop a technlogy to enable "confidential computing", namely AMD Secure Encrypted Virtualization (SEV) and Intel Trusted Domain Extensions (TDX). In this short article we try to understand a little more about AMD SEV, assuming nothing and getting our hands dirty step by step.

### AMD Secure Memory Encryption (SME)

AMD SME is the basic building block for the more sophisticated thing we'll cover later, so it might be beneficial to understand how it works. Memory operations are performed via dedicated hardware, an entirely different chip on die. AMD EPYC™ (soc microprocessor) introduced two hardware security components:

1. **AES-128 hardware e_ncryption engine**: embedded in memory controller, makes sure data to main memory is encrypted during write opeartions and decrypted during read operations, this memory controller is inside the EPYC SOC, so memory lines leaving the soc are encrypted
2. **AMD Secure Processor**: provides cryptographic functionality for secure key generation and key management

![read-write](img/read_write.png)


The key used to encyrpt and decrypt memory is generated securely by the AMD Secure-Processor (SMD-SP), a 32 bit microcontroller and it is not accesible by software running on the main CPU, furthermore SME does not require software running on main CPU to partecipate in Key Management making this enclave more secure.

Control over which pages to encrpyt is handled by checking a bit in page tables, the specific bit, called C-bit, can be retrieved toghether with some additional infos by running the following command:

```console
[nix-shell:/scratch/roberto/gr]$ cpuid -1 -l 0x8000001F
    CPU:
    AMD Secure Encryption (0x8000001f):
        SME: secure memory encryption support    = true
        SEV: secure encrypted virtualize support = true
        VM page flush MSR support                = true
        SEV-ES: SEV encrypted state support      = true
        SEV-SNP: SEV secure nested paging        = true
        VMPL: VM permission levels               = true
        Secure TSC supported                     = true
        virtual TSC_AUX supported                = false
        hardware cache coher across enc domains  = true
        SEV guest exec only from 64-bit host     = true
        restricted injection                     = true
        alternate injection                      = true
        full debug state swap for SEV-ES guests  = true
        disallowing IBS use by host              = true
        VTE: SEV virtual transparent encryption  = true
        VMSA register protection                 = true
        encryption bit position in PTE           = 0x33 (51)
        physical address space width reduction   = 0x5 (5)
        number of VM permission levels           = 0x4 (4)
        number of SEV-enabled guests supported   = 0x1fd (509)
        minimum SEV guest ASID                   = 0x80 (128)
```
In our case it is the 51th bit (0x33 in hex).

Encryption and decryption may lead to an increase in latency in memory operations, this will be matter of further discussion.

SME is a very powerful mechanism to provide memory encryption, but it requires support from the Operating System/Hypervisor, Transparent SME (TSME) is a solution to encrypt every memmory page regardeless of the C-bit, this provides encryption without further modification to OS/HV. 

We now introduce AMD SEV, a technology powered by AMD SME that enables condfidential computing for virtual machines.

### AMD Secure Encrypyted Virtualization (SEV)

AMD SEV is an attempt to make virtual machines more secure to use by encrypting data to and from a virtual machine, and enables a new security model protecting code from higher privileged resources, such as hypervisors. In this context, as mentioned before, we should never trust the hypervisor since it may be compromised or acting maliciously by default.

![](img/security-layers.png)

Let's now explore how SEV works, SEV is an extension to the AMD-V architecture, when SEV is enabled SEV machines tag data with VM ASID (an unique identifier for that specific machine), this tag is used inside the SOC and prevents external entities to access it, when data leaves the chip we have no such problem because it is encrypted using the previously exchanged AES-128 bit key. These two things provide strong cryptography isolation between VMs run by the same hypervisor and between VMs and the hypervisor by itself. SEV guests can choose which pages to encrypt, this is handled setting the c-bit as mentioned before for SME. Only pages meant fot oustide communcations are considered shared and thus not encrypted.



### AMD Secure Encrypted Virtualization-Encrypted State (SEV-ES)

Up until now we only discussed encryption for memory, but a crucial portion of the system we want to protect are CPU registers, AMD SEV-ES encrypts all CPU register contents when a VM stops running. What this means is a malevolent actor is not able to read CPU's register contents when the machine is shutdown.

The CPU register's state is saved and encrypted when the machine is shutdown.

Protecting CPU register may be a daunting task because sometimes an Hypervisor may need to access VM CPU's register to provide services such as device emulation. These accesses must be protected, ES technlogy allows the guest VM to decide which registers are encrypted, in the same vein a machine can choose which memory pages are to be encrypted via the C-bit.

SEV-ES introuduce a single atomic hardware instruction: `VMRUN`, when this intruction is executed for a guest the CPU loads all registers,
when the VM is stops runnning (`VMEXIT`), register's state is saved automatically to  back to memory. These instructions are atomic because we need to be sure no one can sneak into this process and alter it and it is impossible to leak memory.

Whenever hardware saves register it encrypts them with the very same AES-128 key we mentioned before, furthermore the CPU computes an integrity-check value and saves it into memory not accessible by the CPU, on next `VMRUN` instruction this will be checked to ensure nobody tried to tamper register's state. For further information about external communication consult the whitepaper (CITE) and amd reference manual chapter 15.


Similarly to AMD-SEV AMD-ES is completely transparent to application code, only the guest VM and the Hypervisor need to implement these specific features.

### AMD Secure Encrypted Virtualization-Secure Nested Paging (SEV-SNP)

After the introduction of AMD-SEV an AMD-ES AMD decided to introduce the next generation of SEV called Secure Nested Paging (SEV-SNP), this technlogy build on top of the aforementioned technlogies and extends them further to implement strong memory integrity protection to prevent Hypervisor based attacks, such as replay attacks and memory remapping, data corruction and memory aliasing

+ replay attacks: a malicious actor captures a state at a certain moment and modifies memory succesfully with those values
+ data corruction: even though an attacker cannot read a memory he can simply corrupt the memory to trick the machine into unpredicted behaviour
+ memory aliasing: an external actor may map a memory page to multiple physical pages
+ memory remapping: the intruder maps a page to a different physical page

These attacks are a problem because a running program has no notion of memory integrity, they could end up in a state that was not originally considered by the developers and this may lead to huge security issues.

The basic principle of SEV-SNP integrity is that if a VM is able to read a private (encrypted) page of memory, it must always read the value it last wrote. (cite) What this means is the VM should be able to throw an exception if the memory a process is trying to access was tampered by external actors.


#### Threat Model

In this computing model we consider:

+ **AMD System-On-Chip (SOC) hardware**, **AMD Secure Processor (AMD-SP)** and the **VM** are fully trusted, to this extend the VM should enable Full Disk Encryption (FDE) at rest, such as LUKS (cite), major cloud providers have been supporting FDE for long time:  https://cloud.google.com/docs/security/encryption/default-encryption

+ BIOS on the host system, the Hypervisor, device drivers, other VMS are fully untrusted, this means the threat model assumes they are malicious and may conspire to compromise the securiy of our Confidential Virtual Machine.

more details discussed here: https://www.amd.com/system/files/TechDocs/SEV-SNP-strengthening-vm-isolation-with-integrity-protection-and-more.pdf


The way SEV-SNP ensures protection against the attacks we mentioned before is by introudcing a new data structure, a Reverse Map Table (RMP) that tracks owners of memory pages, in this way we can enforce that only the owner of a certain memory page can alter it. A page can be owned by the VM, the Hypervisor or by the AMD Secure Processor. The RMP is used in conjunction with standard x86 page tables mechanisms to enforce memory restrictions and page access rights. RMP fixes replay, remapping and data corruction attacks. 

RMP checks are introduced for write operations on memory, however external (Hypervisor) read accesses do not require them because we have AES encryption protecting our memory.

To prevent memory remapping a technique called Page Validation is introduced.
Inside each RMP entry there is a Validated bit, pages assigned to guests that have no validated bit set are not usable by the Hypervisor, the guest can only use the page after setting the validated bit through a `PVALIDATE` instruction. The VM will make sure that it is not possible to validate a SPA (system phyiscal address) corresponding to a GPA (Guest Physical Address) more than once.


We now introduced every part of AMD's effort to popularize Confidential Computing, now we will proceed by giving instructions to start such machines using QEMU/KVM and we will run some benchmarks to measure how these technlogies impact performance


First of all we need to launch some machines with SEV enabled, we could use libvirt, check `launch-libvirt.sh` to see instructions to launch a SEV machine with SEV enabled, but since SEV-SNP is not supported yet by upstream QEMU we will use QEMU and OVMF patched by AMD.

OVMF is a project maintanied by TianCore aiming to enable UEFI support for virtual machines, it is based on EDK 2, we will use OVMF to generate the executable firmware and the non-volatile variable store, it is important to create a vm-specific cody of `OVMF_vars.fd` because the variable store should be private for every virtual machine

QEMU is a generic open source machine emulator and virtualizer, we will use QEMU toghether with KVM, the Kernel Virtual machine to virtualize our machines.

We are using nix as a package manager to make our experiments reproducible, before running any command below activate the nix shell with `nix-shell` (make sure to run this command in the home directory).  The first thing we need to do is build our patched versions of QEMU and OVMF, we can do so by running the `./build.sh` script we provided (cite). As operating system we are going to use ubuntu cloud images as they are way smaller than the desktop relaeases, this means we will need to use `cloud-localds` (cite) to create a disk for `cloud-init` to setup our machines, see the configuration files in `./config`, we also provide a `prepare_net_cfg.sh` script that takes as a parameter the virtual bridge where the VMs will be connected to and modifies the IP prefix in the network configuration (given as a secord parameter) appropriately. (cite correctly, is this something Dimitris created or is it from AMD?) We can then run the following commands to setup normal guest:

```bash
sudo qemu-img convert kinetic-server-cloudimg-amd64.img nosev.img
sudo qemu-img resize nosev.img +20G
./prepare_net_cfg.sh -br virbr0 -cfg config/network-config-nosev.yml
sudo cloud-localds -N ./config/network-config-nosev.yml cloud-config-nosev.iso config/cloud-config-nosev.yml
```

While to setup a SEV-SNP machine we need to run:

```bash
sudo qemu-img convert kinetic-server-cloudimg-amd64.img sev.img
sudo qemu-img resize sev.img +20G 
./prepare_net_cfg.sh -br virbr0 -cfg ./config/network-config-sev.yml
sudo cloud-localds -N ./config/network-config-sev.yml cloud-config-sev.iso ./config/cloud-config-sev.yml
mkdir OVMF_files
cp ./usr/local/share/qemu/OVMF_CODE.fd ./OVMF_files/OVMF_CODE_sev.fd
cp ./usr/local/share/qemu/OVMF_VARS.fd ./OVMF_files/OVMF_VARS_sev.fd
```

Now running the machines is simply a matter of launching them with the `./launch.sh` script provided, for the normal machine use:

```bash
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./launch.sh \
    -hda nosev.img \
    -cdrom cloud-config-nosev.iso \
    -bridge virbr0 
```

While to run the SEV-SNP machine use:

```bash
sudo LD_LIBRARY_PATH=$LD_LIBRARY_PATH ./launch.sh \
    -hda sev.img \
    -cdrom cloud-config-sev.iso \
    -sev-snp \
    -bridge virbr0 \
    -bios ./OVMF_files/OVMF_CODE_sev.fd \
    -bios-vars ./OVMF_files/OVMF_VARS_sev.fd
```

The launch script is configurable (memory, CPUs, etc), here is the configuration we are using:

INSERT A TABLE TO REPRESENT THE MACHINES


We can now verify that confidential computing features are enabled by running: `sudo dmesg | grep snp -i`


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
Long uses 8 bytes. Allocating 2*134217728 elements = 2147483648 bytes of memory.
Using 262144 bytes as blocks for memcpy block copy test.
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
- set ovmf version
- AMD Secure Encrypted Virtualization-Secure Trusted I/O (SEV-TIO)
- SEV on containers (kata)
- bios configuration
- numa enabled/disabled
- barplot with benchmark results (maybe split by category: memory, cpu, io use seaborn)

## References
+ https://manpages.debian.org/testing/cloud-image-utils/cloud-localds.1.en.html
https://www.amd.com/system/files/documents/using-amd-secure-encrypted-virtualization-encrypted-state-on-think-system-servers.pdf
- https://www.amd.com/system/files/TechDocs/memory-encryption-white-paper.pdf
- https://www.amd.com/system/files/techdocs/sev-snp-strengthening-vm-isolation-with-integrity-protection-and-more.pdf
- https://documentation.suse.com/sles/15-SP1/html/SLES-amd-sev/art-amd-sev.html
- https://www.amd.com/system/files/TechDocs/Protecting%20VM%20Register%20State%20with%20SEV-ES.pdf
- https://help.ovhcloud.com/csm/en-dedicated-servers-amd-sme-sev?id=kb_article_view&sysparm_article=KB0044018
- https://libvirt.org/kbase/launch_security_sev.html
- https://documentation.suse.com/de-de/sles/15-SP4/html/SLES-all/article-amd-sev.html#table-guestpolicy
- http://www.linux-kvm.org/downloads/lersek/ovmf-whitepaper-c770f8c.txt
- https://www.qemu.org/docs/master/system/i386/amd-memory-encryption.html
- https://cloud.google.com/docs/security/encryption/default-encryption
- https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-atrest
- https://docs.aws.amazon.com/whitepapers/latest/efs-encrypted-file-systems/encryption-of-data-at-rest.html
- https://www.intel.com/content/www/us/en/developer/articles/technical/intel-trust-domain-extensions.html
- https://www.amd.com/en/developer/sev.html
- https://arch.cs.ucdavis.edu/assets/papers/ipdps21-hpc-tee-performance.pdf
- https://cdrdv2.intel.com/v1/dl/getContent/690419
- https://www.amd.com/content/dam/amd/en/documents/developer/sev-tio-whitepaper.pdf
- https://www.amd.com/system/files/TechDocs/58019-svsm-draft-specification.pdf
- https://www.amd.com/content/dam/amd/en/documents/developer/58207-using-sev-with-amd-epyc-processors.pdf
- https://www.amd.com/system/files/TechDocs/40332.pdf
- https://www.amd.com/system/files/TechDocs/cloud-security-epyc-hardware-memory-encryption.pdf
- http://events17.linuxfoundation.org/sites/events/files/slides/AMD%20SEV-ES.pdf
- cpuid and some other interesting demos: https://blogs.oracle.com/linux/post/using-amd-secure-memory-encryption-with-oracle-linux
- https://jcadden.medium.com/
confidential-computing-with-kubernetes-sev-guest-protection-for-kata-containers-8f29f0a3a2d7
- https://www.kernel.org/doc/html/v5.6/virt/kvm/amd-memory-encryption.html
## imported from the old report:

We report a preliminary performance evaluation of AMD SEV (Secure
We run our experiments on ryan, we using a patched version of QEMU from
AMD. Do we need additional info about the system? Specify what is
enabled (SEV-SNP and other stuff) Specify the CPU
We use QEMU/KVM as a hypervisor. We assign the guest the same amount of
CPUs (16) and 16G of memory.

|              |                                                                              |
| ------------ | ---------------------------------------------------------------------------- |
| Host CPU     | AMD EPYC 7713P 64-Cores                                                      |
| Host Memory  | HMAA8GR7AJR4N-XN (Hynix) 3200MHz 64 GB\* 8 (512GB)                           |
| Host Config  | Automatic numa balancing disabled; Side channel mitigation default (enabled) |
| Host Kernel  | 6.1.0-rc4 #1-NixOS SMP PREEMPT_DYNAMIC (NixOS 22.11)                         |
| Qemu         | 7.2.0 (patched)                                                              |
| OVMF         | Stable 202211 (patched) ????                                                 |
| Guest vCPU   | 16                                                                           |
| Guest Memory | 16GB                                                                         |
| Guest Kernel | 5.19.0-41-generic #42-Ubuntu SMP PREEMPT_DYNAMIC (Ubuntu 22.10 )             |


#### Section 3.2 "BIOS Configurations"\



## investigating I/O related perfomance


+ QEMU emulated devices
+ QEMU virtio IOThread
+ QEMU userspace NVMe driver
+ vfio-pci device assignment
+ virtio-scsi
+ virtio-blk
+ vfio-pci
+ ahci
+ virtio-blk, w/ iothread, userspace driver

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

# I/O testing
Test with SEV-SNP enabled, I still need to provide commands
Test with both raw images and qcow2?
