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

### Launching a SEV machine raw QEMU + libvirt

```bash
wget https://cloud-images.ubuntu.com/focal/current/jammy-server-cloudimg-amd64.img
sudo qemu-img convert jammy-server-cloudimg-amd64.img /var/lib/libvirt/images/sev.img
sudo cloud-localds /var/lib/libvirt/images/sev-cloud-config.iso config/cloud-config-sev.yml
```

```console
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

### benchmarks

+ Test different system configs (memory and CPUS)
+ Test different machines running at the same time
+ memory: Tinymembench, MBW
+ cpu: compilation (linux llvm godot imagemagick) + LZ4 ~> This measures the compression and decompression time with LZ4 algorithm.
+ I/O: SQLite ~> This measures the time to perform a pre-defined number of insertions to a SQLite database, Redis benchmark

### AMD Secure Encrypted Virtualization-Secure Trusted I/O (SEV-TIO)


### Sev on containers (kata)




## todo
- set ovmf version
- bios configuration
- numa enabled/disabled
- barplot with benchmark results (maybe split by category: memory, cpu, io use seaborn)
## References
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


#### Section 3.2 "BIOS Configurations"