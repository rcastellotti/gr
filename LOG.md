this file is meant to be a log (scratchpad) to note things down.

# 04/05 -> 08/05
+ launched a normal ubuntu machine2
+ consulted [amd.com/system/files/TechDocs/40332.pdf](amd.com/system/files/TechDocs/40332.pdf) to understand how to check wheter SEV is enabled
    + **7.10.1 Determining Support for Secure Memory Encryption**: Support for memory encryption features is reported in CPUID Fn8000_001F[EAX]. Bit 0 indicates support for Secure Memory Encryption. When this feature is present, CPUID Fn8000_001F[EBX] supplies additional information regarding the use of memory encryption such as which page table bit is used to mark pages as encrypted.
    + **15.34.1 Determining Support for SEV**: Support for memory encryption features is reported in CPUID 8000_001F[EAX] as described in Section 7.10.1, “Determining Support for Secure Memory Encryption,” on page 239. Bit 1 indicates support for Secure Encrypted Virtualization.
    + **15.35.1 Determining Support for SEV-ES**: SEV-ES support can be determined by reading CPUID Fn8000_001F[EAX] as described in Section 15.34.1. Bit 3 of EAX indicates support for SEV-ES.
    + **15.36.1 Determining Support for SEV-SNP**: Support for SEV-SNP can be determined by reading CPUID Fn8000_001F[EAX] as described in Section 15.34.1. Bit 4 indicates support for SEV-SNP, while bit 5 indicates support for VMPLs. The number of VMPLs available in an implementation is indicated in bits 15:12 of CPUID Fn8000_001F[EBX].
    CPUID Fn8000_001F[EAX] also indicates support for additional security features used with SEV-SNP guests, which are described in the following sections.

# 09/05 -> 14/05

+ install pts on both machines
    + wget https://phoronix-test-suite.com/releases/repo/pts.debian/files/phoronix-test-suite_10.8.4_all.deb
+ run benchmarks on both machines
    + `phoronix-test-suite benchmark pts/sqlite pts/redis pts/sysbench pts/compilation`
    + running with "all" for every test is not feasible at the moment (10 h run time)
    + `pts/compression` fails to download something (see `compress_failure_log.txt`)

    + `phoronix-test-suite benchmark pts/sqlite`
        + running with option 1 
            + results: `14-05-sev-sqlite-1`
            + results: `14-05-nosev-sqlite-1`
    + `phoronix-test-suite benchmark pts/redis`
        + running with options 1,2 and 1 (set,get - 50 insertions)
            + results: `14-05-sev-redis-1,2-1`
            + results: `14-05-nosev-redis-1,2-1`
    + `phoronix-test-suite benchmark pts/sysbench`
        + running with option 3
            + results: `14-05-sev-sysbench-3`
            + results: `14-05-nosev-sysbench-3`
    + `phoronix-test-suite benchmark pts/compilation`
        + running with option 3
            + results: `14-05-sev-compilation`
            + results: `14-05-nosev-compilation`


+ see results
    + `phoronix-test-suite show-result RESULT_ID`

+ export results
    + `phoronix-test-suite result-file-to-csv RESULT_ID`
    
+ copy them to ryan: `scp -r ubuntu@192.168.122.48:/home/ubuntu/*.csv .`

# misc
+ `result-file-to-suite` -> allows to create our custom testing suite



ubuntu@nosev:~$ cat 14-05-nosev-compilation.csv 
14-05-nosev-compilation
KVM testing on Ubuntu 22.10 via the Phoronix Test Suite.

 ,,"14-05-nosev-compilation"
Processor,,AMD EPYC-v4 (16 Cores)
Motherboard,,QEMU Standard PC (Q35 + ICH9 2009)
Chipset,,Intel 82G33/G31/P35/P31 + ICH9
Memory,,16GB
Disk,,25GB QEMU HDD
Graphics,,EFI VGA
Network,,Red Hat Virtio device
OS,,Ubuntu 22.10
Kernel,,5.19.0-41-generic (x86_64)
Vulkan,,1.3.224
Compiler,,GCC 12.2.0
File-System,,ext4
Screen Resolution,,1280x800
System Layer,,KVM

 ,,"14-05-nosev-compilation"
"Timed Apache Compilation - Time To Compile (sec)",LIB,26.449
"Timed FFmpeg Compilation - Time To Compile (sec)",LIB,47.152
"Timed GCC Compilation - Time To Compile (sec)",LIB,1031.908
"Timed GDB GNU Debugger Compilation - Time To Compile (sec)",LIB,67.078
"Timed Gem5 Compilation - Time To Compile (sec)",LIB,427.151
"Timed Godot Game Engine Compilation - Time To Compile (sec)",LIB,396.772
"Timed ImageMagick Compilation - Time To Compile (sec)",LIB,27.167
"Timed Linux Kernel Compilation - Build: defconfig (sec)",LIB,107.189
"Timed Linux Kernel Compilation - Build: allmodconfig (sec)",LIB,1277.463
"Timed LLVM Compilation - Build System: Ninja (sec)",LIB,774.417



ubuntu@nosev:~$ cat 14-05-nosev-redis-12-1.csv 
14-05-nosev-redis-1,2-1
KVM testing on Ubuntu 22.10 via the Phoronix Test Suite.

 ,,"14-05-nosev-redis-1,2-1"
Processor,,AMD EPYC-v4 (16 Cores)
Motherboard,,QEMU Standard PC (Q35 + ICH9 2009)
Chipset,,Intel 82G33/G31/P35/P31 + ICH9
Memory,,16GB
Disk,,25GB QEMU HDD
Graphics,,EFI VGA
Network,,Red Hat Virtio device
OS,,Ubuntu 22.10
Kernel,,5.19.0-41-generic (x86_64)
Vulkan,,1.3.224
Compiler,,GCC 12.2.0
File-System,,ext4
Screen Resolution,,1280x800
System Layer,,KVM

 ,,"14-05-nosev-redis-1,2-1"
"Redis - Test: GET - Parallel Connections: 50 (Reqs/sec)",HIB,2277704.58
"Redis - Test: SET - Parallel Connections: 50 (Reqs/sec)",HIB,1570497.58

ubuntu@nosev:~$ 
