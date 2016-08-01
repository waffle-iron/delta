# Copyright (c) 2016 krycha
# See the 'license' file at the root directory
#
# Loader from 32-bit protected mode to
# 64-bit long mode

# Errors are reported in 'eax' register
# 0xdeadbeef -> multiboot magic number checking failed
# 0xdeadc0de -> cpuid instruction is not supported
# 0xdeadf00d -> extended cpuid instruction is not supported
# 0xdeadf001 -> long mode is not available

.global start32

.section .text
.code32

start32:
.multiboot:
    # setup stack for boot time
    movl $stack_top, %esp

    # check for magic number
    cmpl $0x36d76289, %eax
    je .cpuid

.no_multiboot:
    movl $0xdeadbeef, %eax
    hlt

# cpuid is supported if software can change 'id' bit
.cpuid:
    pushfl

    popl %eax
    movl %eax, %ebx

    xorl $(1 << 21), %eax
    pushl %eax

    popfl
    pushfl

    popl %eax
    cmpl %eax, %ebx
    jne .extended_cpuid

.no_cpuid:
    movl $0xdeadc0de, %eax
    hlt

.extended_cpuid:
    movl $0x80000000, %eax
    cpuid

    cmpl $0x80000001, %eax
    jae .long_mode

.no_extended_cpuid:
    movl $0xdeadf00d, %eax
    hlt

.long_mode:
    movl $0x80000001, %eax
    cpuid

    testl $(1 << 29), %edx
    jnz .prepare_paging

.no_long_mode:
    movl $0xdeadf001, %eax
    hlt

.prepare_paging:
    movl $pdp, %eax
    orl $0b11, %eax
    movl %eax, pml4

    movl $pd, %eax
    orl $0b11, %eax
    movl %eax, pdp

.map_p2_table_prepare:
    xorl %ebx, %ebx
    xorl %ecx, %ecx

    movl $pd, %edi

# identity maping of 1gb
.map_p2_table:
    orl $0b10000011, %ebx
    movl %ebx, (%edi)

    addl $0x200000, %ebx
    addl $8, %edi
    addl $1, %ecx

    cmpl $0x200, %ecx
    jne .map_p2_table

.setup_long_mode:
    movl %cr4, %eax
    orl $(1 << 5), %eax
    movl %eax, %cr4

    movl $pml4, %eax
    movl %eax, %cr3

    movl $0xc0000080, %ecx
    rdmsr
    orl $(1 << 8), %eax
    wrmsr

    movl %cr0, %eax
    orl $(1 << 31), %eax
    movl %eax, %cr0

.heaven:
    lgdt gdt64_ptr

    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %ss
    movw %ax, %es

    # gas treat undefined symbols as extern
    ljmp $0x8, $start64

.section .bss
.align 4096
pml4:
    .space 4096
pdp:
    .space 4096
pd:
    .space 4096

stack_bottom:
    .space 64
stack_top:

.section .rodata
.align 8
gdt64:
    .quad 0 # null segment
    .quad (1 << 53) | (1 << 47) | (1 << 44) | (1 << 43) | (1 << 41) # code segment
    .quad (1 << 47) | (1 << 44) | (1 << 41) # data segment
gdt64_end:

gdt64_ptr:
    .word (gdt64_end - gdt64) - 1
    .quad gdt64
