include common.mk

V := 0

all: build

clean:
		if test -d "$(KERNEL_SRC)" ; then $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CC) -C $(KERNEL_SRC) mrproper ; fi
		rm -f $(KERNEL_UIMAGE)
		rm -rf $(wildcard $(KERNEL_OUT))

distclean: clean
		rm -rf $(wildcard $(KERNEL_SRC))

$(KERNEL_SRC):
		git clone $(KERNEL_REPO) -b $(KERNEL_BRANCH) kernel

$(KERNEL_SRC)/.config: $(KERNEL_SRC)
		mkdir -p $(KERNEL_OUT)
		$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CC) -C $(KERNEL_SRC) O=$(KERNEL_OUT) $(KERNEL_DEFCONFIG)

$(KERNEL_UIMAGE): $(KERNEL_SRC)/.config
		echo "building kernel and make image"
		rm -f $(KERNEL_SRC)/arch/$(ARCH)/boot/zImage
		rm -f $(KERNEL_UIMAGE)
		$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CC) -C $(KERNEL_SRC) V=$(V) O=$(KERNEL_OUT) dtbs 
		$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CC) -C $(KERNEL_SRC) V=$(V) O=$(KERNEL_OUT) -j$(CPUS) uImage

kernel: $(KERNEL_UIMAGE)
		#mkimage -A $(ARCH) -O linux -T kernel -C none -a 80008000 -e 80008000 -n "Linux Kernel Image" -d  $(KERNEL_SRC)/arch/$(ARCH)/boot/zImage uImage

modules: $(KERNEL_SRC)/.config
		$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CC) -C $(KERNEL_SRC) -j$(CPUS) O=$(KERNEL_OUT) modules
modules_install: modules 
		$(MAKE) INSTALL_MOD_PATH=$(OUTPUT_DIR)/device/system ARCH=$(ARCH) CROSS_COMPILE=$(CC) -C $(KERNEL_SRC) -j$(CPUS) O=$(KERNEL_OUT) modules_install

build: kernel

.PHONY: kernel modules build
