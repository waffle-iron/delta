# Copyright (c) 2016 krycha
# See the 'license' file at the root directory

# Multiboot specification ver. 1.6
# http://nongnu.askapache.com/grub/phcoder/multiboot.pdf

.set multiboot_magic, 0xe85250d6 # magic number
.set multiboot_arch, 0           # architecture code (i386 protected mode)

.section .multiboot
.align 8
multiboot_header:
    .int multiboot_magic
    .int multiboot_arch

    # header length
    .int multiboot_footer - multiboot_header

    # checksum (hack inside)
    .int 0x100000000 - (multiboot_magic + multiboot_arch + (multiboot_footer - multiboot_header))

    # tag structure
    .short 0 # type
    .short 0 # flags
    .int 0   # size
multiboot_footer:
