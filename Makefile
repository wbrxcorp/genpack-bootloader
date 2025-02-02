ARCH := $(shell uname -m)
MODULES := loopback xfs btrfs fat exfat ntfscomp ext2 iso9660 lvm squash4 part_gpt part_msdos \
	blocklist configfile linux chain echo test probe search minicmd sleep \
    all_video videotest serial png gfxterm_background videoinfo keystatus

ifeq ($(ARCH), x86_64)
	TARGETS = bootx64.efi bootia32.efi
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

bootaa64.efi: grub.cfg
	grub-mkimage -O arm64-efi -o $@ -p /boot/grub -c $< $(MODULES)

bootriscv64.efi: grub.cfg
	grub-mkimage -O riscv64-efi -o $@ -p /boot/grub -c $< $(MODULES)

install: $(TARGETS)
	mkdir -p $(DESTDIR)/boot/efi/boot
	cp -a $(TARGETS) $(DESTDIR)/boot/efi/boot/

clean:
	rm -f *.efi
