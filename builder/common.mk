CPUS := $(shell getconf _NPROCESSORS_ONLN)

include .config 

OUTPUT_DIR := $(PWD)
SCRIPT_DIR := $(OUTPUT_DIR)/scripts
TOOLS_DIR := $(OUTPUT_DIR)/tools
PRELOAD_DIR := $(OUTPUT_DIR)/preloader
CONFIG_DIR := $(OUTPUT_DIR)/config/$(IC_NAME)/$(BOARD_NAME)
OEM_BOOT_DIR := $(OUTPUT_DIR)/gadget/boot-assets

# VNEDOR: toolchain from BSP ; DEB: toolchain from deb
TOOLCHAIN := DEB

ARCH := arm
KERNEL_DTS := actduino_bubble_gum_sdboot_linux
KERNEL_DEFCONFIG := snappy-actduino_bubble_gum_linux_defconfig
UBOOT_DEFCONFIG := actduino_bubble_gum_v10_defconfig

KERNEL_REPO := https://github.com/asac/roseapple-pi-kernel.git
KERNEL_BRANCH := Ubuntu-Snappy-Core
KERNEL_SRC := $(PWD)/kernel
KERNEL_MODULES := $(PWD)/kernel-build
KERNEL_OUT := $(PWD)/kernel-build
KERNEL_UIMAGE := $(KERNEL_OUT)/arch/arm/boot/zImage
KERNEL_DTB := $(KERNEL_OUT)/arch/arm/boot/dts/$(KERNEL_DTS).dtb

UBOOT_REPO := https://github.com/xapp-le/u-boot.git
UBOOT_BRANCH := Ubuntu-Snappy-Core
UBOOT_SRC := $(PWD)/u-boot
UBOOT_OUT := $(PWD)/u-boot-build
UBOOT_BIN := $(UBOOT_OUT)/u-boot-dtb.img

UDF := $(TOOLS_DIR)/ubuntu-device-flash

ifeq ($(TOOLCHAIN),VENDOR)
CC :=
else
CC := arm-linux-gnueabihf-
endif
