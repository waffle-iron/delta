# Copyright (c) 2016 krycha
# See the 'license' file at the root directory
#
# Makefile for delta x86_64

arch := x86_64
target := $(arch)-elf

tools := tools/$(arch)
cross := $(tools)/cross/bin
grub := $(tools)/grub/bin

as := $(cross)/$(target)-as
ld := $(cross)/$(target)-ld
ld_flags := -n --gc-sections -T
mkrescue := $(grub)/grub-mkrescue

rm := rm -r
cp := cp
mkdir := mkdir -p
qemu := qemu-system-x86_64 -monitor stdio -cdrom

boot := arch/$(arch)/boot

build := build
build_boot := $(build)/$(boot)
build_iso := $(build)/iso

asm_files := $(wildcard $(boot)/*.s)
asm_obj := $(patsubst $(boot)/%.s, $(build)/$(boot)/%.o, $(asm_files))

ld_script := $(boot)/linker.ld
grub_cfg := $(boot)/grub.cfg

kernel := $(build_iso)/delta_kernel-x86_64
iso := $(build_iso)/delta-x86_64

.PHONY: all
all: dirs $(iso)

.PHONY += dirs
dirs:
	if [ ! -d $(build) ]; then $(mkdir) $(build); fi
	if [ ! -d $(build_boot) ]; then $(mkdir) $(build_boot); fi
	if [ ! -d $(build_iso) ]; then $(mkdir) $(build_iso); fi

$(iso): $(kernel) $(grub_cfg)
	$(mkdir) $(build_iso)/boot
	$(cp) $(kernel) $(build_iso)/boot
	$(mkdir) $(build_iso)/boot/grub
	$(cp) $(grub_cfg) $(build_iso)/boot/grub
	$(mkrescue) $(build_iso) -o $(iso)

$(kernel): $(asm_obj) $(ld_script)
	$(ld) $(ld_flags) $(ld_script) -o $(kernel) $(asm_obj)

$(build_boot)/%.o: $(boot)/%.s
	$(as) $< -o $@

clean:
	$(rm) $(build)

run: all
	$(qemu) $(iso)
