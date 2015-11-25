include common.mk

all: build

clean:
		if test -d "$(UBOOT_SRC)" ; then $(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_SRC) clean ; fi
		rm -f $(UBOOT_BIN)
		rm -rf $(wildcard $(UBOOT_OUT))

distclean: clean
		rm -rf $(wildcard $(UBOOT_SRC))

$(UBOOT_BIN): $(UBOOT_SRC)
		mkdir -p $(UBOOT_OUT)
		$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=${CC} -C $(UBOOT_SRC) KBUILD_OUTPUT=$(UBOOT_OUT) $(UBOOT_DEFCONFIG)
		$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=${CC} -C $(UBOOT_SRC) KBUILD_OUTPUT=$(UBOOT_OUT) -j$(CPUS) all u-boot-dtb.img
		cd $(SCRIPT_DIR) && ./padbootloader $(UBOOT_OUT)/u-boot-dtb.img

$(UBOOT_SRC):
		git clone $(UBOOT_REPO) -b $(UBOOT_BRANCH) u-boot

u-boot: $(UBOOT_BIN)

build: u-boot

.PHONY: u-boot build
