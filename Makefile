PREFIX ?= /usr/local
ARCH := $(shell uname -m)
MODULES := loopback xfs btrfs fat exfat ntfscomp ext2 iso9660 lvm squash4 part_gpt part_msdos \
	msdospart blocklist configfile linux chain echo test probe search minicmd sleep \
	all_video videotest serial png gfxterm_background videoinfo keystatus

ifeq ($(ARCH), x86_64)
	TARGETS = bootx64.efi bootia32.efi eltorito.img
	# DO NOT INCLUDE "ahci" HERE.  It makes booting regular PC impossible.
	MODULES += ata cpuid multiboot multiboot2 
else ifeq ($(ARCH), i686)
	TARGETS = bootia32.efi eltorito.img
	# DO NOT INCLUDE "ahci" HERE.  It makes booting regular PC impossible.
	MODULES += ata cpuid multiboot multiboot2 
else ifeq ($(ARCH), aarch64)
	TARGETS = bootaa64.efi
	MODULES += fdt
else ifeq ($(ARCH), riscv64)
	TARGETS = bootriscv64.efi
else
	$(error Unsupported architecture: $(ARCH))
endif

all: $(TARGETS)

bootx64.efi: grub.cfg
	grub-mkimage -O x86_64-efi -o $@ -p /boot/grub -c $< $(MODULES)

bootia32.efi: grub.cfg
	grub-mkimage -O i386-efi -o $@ -p /boot/grub -c $< $(MODULES)

eltorito.img: grub.cfg
	grub-mkimage -O i386-pc-eltorito -o $@ -p /boot/grub -c $< $(MODULES) biosdisk

bootaa64.efi: grub.cfg
	grub-mkimage -O arm64-efi -o $@ -p /boot/grub -c $< $(MODULES)

bootriscv64.efi: grub.cfg
	grub-mkimage -O riscv64-efi -o $@ -p /boot/grub -c $< $(MODULES)

install: $(TARGETS)
	mkdir -p $(DESTDIR)$(PREFIX)/lib/genpack-bootloader
	cp -a $(TARGETS) $(DESTDIR)$(PREFIX)/lib/genpack-bootloader/

clean:
	rm -f *.efi *.img *.tmp
