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

# 14-05 -> 22-05

+ `wget http://parsec.cs.princeton.edu/download/3.0/parsec-3.0.tar.gz`
+ configured correctly the config file mentioned in readme 
+ compiling with the command `parsecmgmt -a build` does not work, see PARSEC_LOG.md (ps cannot kill processes because they are in uninterruptible wait)

x264 benchmark does not work? 

+ [roberto@ryan:/scratch/roberto/parsec/parsec-3.0]$ bin/parsecmgmt -a run -p x264
[PARSEC] Benchmarks to run:  parsec.x264

[PARSEC] [========== Running benchmark parsec.x264 [1] ==========]
[PARSEC] Setting up run directory.
[PARSEC] Unpacking benchmark input 'test'.
eledream_32x18_1.y4m
[PARSEC] Running 'time /scratch/roberto/parsec/parsec-3.0/pkgs/apps/x264/inst/amd64-linux.gcc/bin/x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads 1 -o eledream.264 eledream_32x18_1.y4m':
[PARSEC] [---------- Beginning of output ----------]
PARSEC Benchmark Suite Version 3.0-beta-20150206
yuv4mpeg: 32x18@25/1fps, 0:0
double free or corruption (!prev)
bin/parsecmgmt: line 1222: 1048714 Aborted                 (core dumped) /scratch/roberto/parsec/parsec-3.0/pkgs/apps/x264/inst/amd64-linux.gcc/bin/x264 --quiet --qp 20 --partitions b8x8,i4x4 --ref 5 --direct auto --b-pyramid --weightb --mixed-refs --no-fast-pskip --me umh --subme 7 --analyse b8x8,i4x4 --threads 1 -o eledream.264 eledream_32x18_1.y4m

real	0m0.081s
user	0m0.000s
sys	0m0.004s
[PARSEC] [----------    End of output    ----------]
[PARSEC]
[PARSEC] BIBLIOGRAPHY
[PARSEC]
[PARSEC] [1] Bienia. Benchmarking Modern Multiprocessors. Ph.D. Thesis, 2011.
[PARSEC]
[PARSEC] Done.


# 22-05 starting to write some report
