# Copyright (c) 2016 krycha
# See the 'license' file at the root directory
#
# Loader from 32-bit protected mode to
# 64-bit long mode

# Errors are reported in 'eax' register
# 0xdeadbeef -> multiboot checking failed
# 0xdead1337 -> cpuid instruction is not supported
# 0xdeadfeed -> extended cpuid instruction is not supported

.section .text
.code32

.global start32
start32:
.multiboot:
    cmp $0x36d76289, %eax
    je .cpuid

    mov $0xdeadbeef, %eax
    hlt

.cpuid:
    pushfl

    pop %eax
    mov %eax, %ebx

    xor $(1 << 21), %eax
    push %eax

    popfl
    pushfl

    pop %eax
    cmp %eax, %ebx
    jne .extended_cpuid

    mov $0xdead1337, %eax
    hlt

.extended_cpuid:
    mov $0x80000000, %eax
    cpuid

    cmp $0x80000001, %eax
    jae .longmode

    mov $0xdeadfeed, %eax
    hlt

.longmode:
    hlt
