include common.mk

OEM_UBOOT_BIN := oem/boot-assets/u-boot.bin
OEM_SNAP := $(OUTPUT_DIR)/*.snap

# for preloader packaging
ifneq "$(findstring ARM, $(shell grep -m 1 'model name.*: ARM' /proc/cpuinfo))" ""
BOOTLOADER_PACK=bootloader_pack.arm
else
BOOTLOADER_PACK=bootloader_pack
endif

all: build

clean:
		rm -f $(OEM_UBOOT_BIN)
		rm -f $(OEM_BOOT_DIR)/bootloader.bin
		rm -f $(OEM_SNAP)
distclean: clean

u-boot:
		@if [ ! -f $(UBOOT_BIN) ] ; then echo "Build u-boot first."; exit 1; fi
			cp -f $(UBOOT_BIN) $(OEM_UBOOT_BIN)

preload:
		cd $(TOOLS_DIR)/utils && ./$(BOOTLOADER_PACK) $(PRELOAD_DIR)/bootloader.bin $(PRELOAD_DIR)/bootloader.ini $(OEM_BOOT_DIR)/bootloader.bin

snappy:
		snappy build oem

oem: preload u-boot snappy

build: oem

.PHONY: u-boot snappy oem build
