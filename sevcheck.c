// this very basic program checks whether AMD SEV features are enabled
// we are extracting data from register 0x8000001f[EAX], as specified in 
// paragraphs 7.10.1,15.34.1,15.35.1,15.36.1 of AMD64 Architecture Programmer’s Manual
// amd.com/system/files/TechDocs/40332.pdf

#include "cpuid.h"
#include <stdio.h>
int main()
{
    int eax, ebx, ecx, edx = 0;
    unsigned int leaf = 0x8000001f;
    __get_cpuid(leaf, &eax, &ebx, &ecx, &edx);
    printf("id: %x :: eax %b :: ebx %x\n", leaf, eax, ebx);
    if (eax && 0x00000001)
    {
        printf("AMD SEV is supported.\n");
    }
    if (eax && 0x00001000)
    {
        printf("AMD SEV ES is supported.\n");
    }
    if (eax && 0x00010000)
    {
        printf("AMD SEV-SNP is supported.\n");
    }
    else
    {
        printf("No AMD SEV related technologies are enabled\n");
    }
}
