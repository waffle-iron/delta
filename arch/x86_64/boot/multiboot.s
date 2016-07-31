# Copyright (c) 2016 krycha
# See the 'license' file at the root directory
#
# Multiboot specification ver. 1.6
# http://nongnu.askapache.com/grub/phcoder/multiboot.pdf
#
# Multiboot header for proper load delta kernel

.set multiboot_magic, 0xe85250d6 # magic number
.set multiboot_arch, 0           # architecture code (i386 protected mode)

.section .multiboot
.align 8
multiboot_header:
    .long multiboot_magic
    .long multiboot_arch

    # header length
    .long multiboot_footer - multiboot_header

    # checksum (hack inside)
    .long 0x100000000 - (multiboot_magic + multiboot_arch + (multiboot_footer - multiboot_header))

    # tag structure
    .word 0 # type
    .word 0 # flags
    .long 0   # size
multiboot_footer:
