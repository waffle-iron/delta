# Copyright (c) 2016 krycha
# See the 'license' file at the root directory
#
# Loader from 32-bit protected mode to
# 64-bit long mode

.section .text
.code32

.global start32
start32:
    movl $0xb8000, %eax
    movl $0x41414141, (%eax)

    hlt
