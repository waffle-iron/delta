ENTRY(start32)

SECTIONS {
    . = 1M;
    
    .multiboot : {
        KEEP(*(.multiboot))
    }

    .text : ALIGN(0x1000) {
        *(.text)
    }
}
