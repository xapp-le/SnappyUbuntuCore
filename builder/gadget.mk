include common.mk

OEM_UBOOT_BIN := gadget/u-boot.bin
OEM_SNAP := $(OUTPUT_DIR)/roseapple-pi_16.04-*.snap

# for preloader packaging
ifneq "$(findstring ARM, $(shell grep -m 1 'model name.*: ARM' /proc/cpuinfo))" ""
BOOTLOADER_PACK=bootloader_pack.arm
else
BOOTLOADER_PACK=bootloader_pack
endif

all: build

clean:
	rm -f $(OEM_UBOOT_BIN)
	rm -f $(OEM_BOOT_DIR)/uboot.conf
	rm -f $(OEM_BOOT_DIR)/bootloader.bin
	rm -f $(OEM_BOOT_DIR)/uboot.env
	rm -f $(OEM_SNAP)
distclean: clean

u-boot:
	@if [ ! -f $(UBOOT_BIN) ] ; then echo "Build u-boot first."; exit 1; fi
		cp -f $(UBOOT_BIN) $(OEM_UBOOT_BIN)

preload:
	cd $(TOOLS_DIR)/utils && ./$(BOOTLOADER_PACK) $(PRELOAD_DIR)/bootloader.bin $(PRELOAD_DIR)/bootloader.ini $(OEM_BOOT_DIR)/bootloader.bin
	mkenvimage -r -s 131072  -o $(OEM_BOOT_DIR)/uboot.env $(OEM_BOOT_DIR)/uboot.env.in
	cd $(OEM_BOOT_DIR) && ln -s uboot.env uboot.conf

snappy:
	snapcraft snap gadget

gadget: preload u-boot snappy

build: gadget

.PHONY: u-boot snappy gadget build
