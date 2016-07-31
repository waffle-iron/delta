# Copyright (c) 2016 krycha
# See the 'license' file at the root directory
#
# Loader from 32-bit protected mode to
# 64-bit long mode

# Errors are reported in 'eax' register
# 0xdeadbeef -> multiboot checking failed
# 0xdead1337 -> cpuid instruction is not supported
# 0xdeadfeed -> extended cpuid instruction is not supported
# 0xdeadf001 -> long mode is not available

.section .text
.code32

.global start32
start32:
.multiboot:
    mov $stack_top, %esp

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
    jae .long_mode

    mov $0xdeadfeed, %eax
    hlt

.long_mode:
    mov $0x80000001, %eax
    cpuid

    test $(1 << 29), %eax
    jz .prepare_paging

    mov $0xdeadf001, %eax
    hlt

.prepare_paging:
    mov $p3_table, %eax
    or $0b11, %eax
    mov %eax, p4_table

    mov $p2_table, %eax
    or $0b11, %eax
    mov %eax, p3_table

.map_p2_table_loop:
    xor %ecx, %ecx
    mov $p2_table, %edi

.map_p2_table:
    mov $0x200000, %eax
    mul %ecx

    or $0b10000011, %eax
    mov %eax, (%edi, %ecx, 8)

    inc %ecx
    cmp $512, %ecx
    jne .map_p2_table

.setup_long_mode:
    lgdt gdt_ptr
    hlt

.section .bss
.align 4096
p4_table:
    .lcomm p4, 4096
p3_table:
    .lcomm p3, 4096
p2_table:
    .lcomm p2, 4096

stack_bottom:
    .lcomm stack, 64
stack_top:

.section .rodata
.align 8
gdt:
    .quad 0 # null segment
    .quad 1 << 53 | 1 << 47 | 1 << 42 # code segment
    .quad 1 << 47 # data segment
gdt_end:

gdt_ptr:
    .short (gdt_end - gdt) - 1
    .quad gdt
