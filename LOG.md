this file is meant to be a log (scratchpad) to note things down.

# 04/05 -> 08/05
+ launch a normal ubuntu machine2
+ consult <amd.com/system/files/TechDocs/40332.pdf> to understand how to check wheter SEV is enabled
    + **7.10.1 Determining Support for Secure Memory Encryption**: Support for memory encryption features is reported in CPUID Fn8000_001F[EAX]. Bit 0 indicates support for Secure Memory Encryption. When this feature is present, CPUID Fn8000_001F[EBX] supplies additional information regarding the use of memory encryption such as which page table bit is used to mark pages as encrypted.
    + **15.34.1 Determining Support for SEV**: Support for memory encryption features is reported in CPUID 8000_001F[EAX] as described in Section 7.10.1, “Determining Support for Secure Memory Encryption,” on page 239. Bit 1 indicates support for Secure Encrypted Virtualization.
    + **15.35.1 Determining Support for SEV-ES**: SEV-ES support can be determined by reading CPUID Fn8000_001F[EAX] as described in Section 15.34.1. Bit 3 of EAX indicates support for SEV-ES.
    + **15.36.1 Determining Support for SEV-SNP**: Support for SEV-SNP can be determined by reading CPUID Fn8000_001F[EAX] as described in Section 15.34.1. Bit 4 indicates support for SEV-SNP, while bit 5 indicates support for VMPLs. The number of VMPLs available in an implementation is indicated in bits 15:12 of CPUID Fn8000_001F[EBX].
    CPUID Fn8000_001F[EAX] also indicates support for additional security features used with SEV-SNP guests, which are described in the following sections.
