

.PHONY: all clean kernel_clean u-boot_clean bootloader_clean rootfs_clean distclean mrproper spec
.PHONY: kernel kernel-config modules u-boot bootloader rootfs initramfs upramfs misc firmware md5sum recovery

include .config

TOP_DIR=$(shell pwd)
CPUS=$$(($(shell cat /sys/devices/system/cpu/present | awk -F- '{ print $$2 }')+1))
#CPUS=1
Q=

KERNEL_SRC=$(TOP_DIR)/../kernel
UBOOT_SRC=$(TOP_DIR)/../u-boot

BOOTLOADER_SRC=$(TOP_DIR)/private/boot
SCRIPT_DIR=$(TOP_DIR)/scripts
BOARD_CONFIG_DIR=$(TOP_DIR)/$(IC_NAME)/boards/$(OS_NAME)/$(BOARD_NAME)
TOOLS_DIR=$(TOP_DIR)/tools

OUT_DIR=$(TOP_DIR)/out/$(IC_NAME)_$(OS_NAME)_$(BOARD_NAME)
IMAGE_DIR=$(OUT_DIR)/images
BURN_DIR=$(OUT_DIR)/burn
BOOTLOAD_DIR=$(OUT_DIR)/bootloader
MISC_DIR=$(OUT_DIR)/misc
UPRAMFS_ROOTFS=$(BURN_DIR)/upramfs
KERNEL_OUT_DIR=$(OUT_DIR)/kernel
UBOOT_OUT_DIR=$(OUT_DIR)/u-boot
K_BLD_CONFIG=$(KERNEL_OUT_DIR)/.config

ifneq "$(findstring ARM, $(shell grep -m 1 'model name.*: ARM' /proc/cpuinfo))" ""
  BOOTLOADER_PACK=bootloader_pack.arm
  CROSS_COMPILE=
else
  BOOTLOADER_PACK=bootloader_pack
  CROSS_COMPILE=arm-linux-gnueabihf-
endif

export PATH:=$(TOOLS_DIR)/utils:$(PATH)

DATE_STR=$(shell date +%y%m%d)
FW_NAME=$(IC_NAME)_$(OS_NAME)_$(BOARD_NAME)_$(DATE_STR)

all: kernel modules u-boot bootloader rootfs initramfs upramfs misc firmware md5sum

$(K_BLD_CONFIG):
	$(Q)mkdir -p $(KERNEL_OUT_DIR)
	$(Q)$(MAKE) -C $(KERNEL_SRC) ARCH=$(ARCH) O=$(KERNEL_OUT_DIR) $(KERNEL_DEFCONFIG)

kernel: $(K_BLD_CONFIG)
	$(Q)mkdir -p $(KERNEL_OUT_DIR)
	$(Q)$(MAKE) -C $(KERNEL_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(KERNEL_OUT_DIR) dtbs
	$(Q)$(MAKE) -C $(KERNEL_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(KERNEL_OUT_DIR) -j$(CPUS) uImage

modules: $(K_BLD_CONFIG)
	$(Q)mkdir -p $(KERNEL_OUT_DIR)
	$(Q)$(MAKE) -C $(KERNEL_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(KERNEL_OUT_DIR) -j$(CPUS) modules

kernel-config: $(K_BLD_CONFIG)
	$(Q)$(MAKE) -C $(KERNEL_SRC) ARCH=$(ARCH) O=$(KERNEL_OUT_DIR) menuconfig

u-boot:
	$(Q)mkdir -p $(UBOOT_OUT_DIR)
	$(Q)$(MAKE) -C $(UBOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) KBUILD_OUTPUT=$(UBOOT_OUT_DIR) $(UBOOT_DEFCONFIG)
	$(Q)$(MAKE) -C $(UBOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) KBUILD_OUTPUT=$(UBOOT_OUT_DIR) -j$(CPUS) all u-boot-dtb.img
	$(Q)cd $(SCRIPT_DIR) && ./padbootloader $(UBOOT_OUT_DIR)/u-boot-dtb.img

bootloader:
	$(Q)mkdir -p $(BOOTLOAD_DIR)
	$(Q)cd $(TOOLS_DIR)/utils && ./$(BOOTLOADER_PACK) $(TOP_DIR)/$(IC_NAME)/bootloader/bootloader.bin $(BOARD_CONFIG_DIR)/bootloader.ini $(BOOTLOAD_DIR)/bootloader.bin

misc: initramfs
	$(Q)echo "-- Build Fat Misc image --"
	$(Q)mkdir -p $(MISC_DIR)
	$(Q)mkdir -p $(IMAGE_DIR)
	$(Q)cp -r $(BOARD_CONFIG_DIR)/misc/* $(MISC_DIR)/
	$(Q)cp $(KERNEL_OUT_DIR)/arch/$(ARCH)/boot/uImage $(MISC_DIR)
	$(Q)cp $(KERNEL_OUT_DIR)/arch/$(ARCH)/boot/dts/$(KERNEL_DTS).dtb $(MISC_DIR)/kernel.dtb
	$(Q)cp $(BOARD_CONFIG_DIR)/uenv.txt $(MISC_DIR)
	$(Q)dd if=/dev/zero of=$(IMAGE_DIR)/misc.img bs=1M count=$(MISC_IMAGE_SIZE)
	$(Q)$(TOOLS_DIR)/utils/makebootfat -o $(IMAGE_DIR)/misc.img -L misc -b $(SCRIPT_DIR)/bootsect.bin $(MISC_DIR)

upramfs:
	$(Q)rm -rf $(UPRAMFS_ROOTFS)
	$(Q)mkdir -p $(UPRAMFS_ROOTFS)
	$(Q)$(SCRIPT_DIR)/populate_dir $(UPRAMFS_ROOTFS)
	$(Q)cp -rf $(TOP_DIR)/$(IC_NAME)/burn/initramfs/* $(UPRAMFS_ROOTFS)
	$(Q)$(CROSS_COMPILE)strip --strip-unneeded $(UPRAMFS_ROOTFS)/lib/modules/*.ko
	
	$(Q)$(SCRIPT_DIR)/gen_initramfs_list.sh -u 0 -g 0 $(UPRAMFS_ROOTFS) > $(BURN_DIR)/upramfs.list
	$(Q)${SCRIPT_DIR}/gen_init_cpio $(BURN_DIR)/upramfs.list > ${BURN_DIR}/upramfs.img.tmp
	$(Q)$(TOOLS_DIR)/utils/mkimage -n "RAMFS" -A arm -O linux -T ramdisk -C none -a 02000000 -e 02000000 -d ${BURN_DIR}/upramfs.img.tmp ${BURN_DIR}/upramfs.img
	$(Q)rm ${BURN_DIR}/upramfs.img.tmp
	$(Q)rm ${BURN_DIR}/upramfs.list

firmware: bootloader upramfs misc recovery
	$(Q)mkdir -p $(BURN_DIR)
	$(Q)cp $(KERNEL_OUT_DIR)/arch/$(ARCH)/boot/uImage $(BURN_DIR)
	$(Q)cp $(KERNEL_OUT_DIR)/arch/$(ARCH)/boot/dts/$(KERNEL_DTS).dtb $(BURN_DIR)/kernel.dtb
	$(Q)cp $(UBOOT_OUT_DIR)/u-boot-dtb.img $(BURN_DIR)/
	$(Q)cp $(UBOOT_OUT_DIR)/u-boot-dtb.img $(IMAGE_DIR)/
	
	$(Q)cp $(BOOTLOAD_DIR)/bootloader.bin $(BURN_DIR)/
	$(Q)cp $(BOOTLOAD_DIR)/bootloader.bin $(IMAGE_DIR)/
	$(Q)cp $(TOP_DIR)/$(IC_NAME)/burn/adfudec/adfudec.bin $(BURN_DIR)/
	
	$(Q)cp $(BOARD_CONFIG_DIR)/partition.cfg $(SCRIPT_DIR)/partition.cfg
	$(Q)python $(SCRIPT_DIR)/partition_create.py $(SCRIPT_DIR)/partition.cfg  $(SCRIPT_DIR)/partition_tmp.cfg
	$(Q)sed -i 's/\\boardname\\/\\$(IC_NAME)_$(OS_NAME)_$(BOARD_NAME)\\/' $(SCRIPT_DIR)/partition_tmp.cfg
	
	$(Q)cp $(SCRIPT_DIR)/fwimage_linux.cfg  $(SCRIPT_DIR)/fwimage_linux_tmp.cfg
	$(Q)sed -i 's/boardname/$(IC_NAME)_$(OS_NAME)_$(BOARD_NAME)/' $(SCRIPT_DIR)/fwimage_linux_tmp.cfg
	
	$(Q)echo "--Build Firmwares.."
	$(Q)cd $(SCRIPT_DIR) && ./linux_build_fw fwimage_linux_tmp.cfg $(IMAGE_DIR) $(FW_NAME)
	$(Q)rm $(SCRIPT_DIR)/partition_tmp.cfg $(SCRIPT_DIR)/partition.cfg $(SCRIPT_DIR)/fwimage_linux_tmp.cfg

md5sum:
	@cd $(IMAGE_DIR) && md5sum *.* > image.md5


clean: kernel_clean u-boot_clean bootloader_clean
	#$(Q)rm -rf $(TOP_DIR)/out

kernel_clean:
	$(Q)$(MAKE) -C $(KERNEL_SRC) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) O=$(KERNEL_OUT_DIR) clean

u-boot_clean:
	$(Q)$(MAKE) -C $(UBOOT_SRC) CROSS_COMPILE=$(CROSS_COMPILE) KBUILD_OUTPUT=$(UBOOT_OUT_DIR) clean

bootloader_clean:
	@echo ""

distclean:
	$(Q)$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT_DIR) distclean
	$(Q)$(MAKE) -C $(UBOOT_SRC) KBUILD_OUTPUT=$(UBOOT_OUT_DIR) distclean
	rm -f $(TOP_DIR)/.config
	rm -rf $(TOP_DIR)/out

mrproper:
	$(Q)$(MAKE) -C $(KERNEL_SRC) O=$(KERNEL_OUT_DIR) mrproper
	$(Q)$(MAKE) -C $(UBOOT_SRC) KBUILD_OUTPUT=$(UBOOT_OUT_DIR) mrproper

include $(BOARD_CONFIG_DIR)/os.mk
include $(TOP_DIR)/$(IC_NAME)/pcba_linux/pcba_linux.mk
