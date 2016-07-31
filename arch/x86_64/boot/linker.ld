/* Copyright (c) 2016 krycha
 * See the 'license' file at the root directory
 *
 * Linker (ld) script for delta
 */

ENTRY(start32)

SECTIONS {
    . = 1M;

    .multiboot : {
        KEEP(*(.multiboot))
    }

    .text : ALIGN(0x1000) {
        *(.text)
    }

    .bss : ALIGN(0x1000) {
        *(.bss)
    }
}
