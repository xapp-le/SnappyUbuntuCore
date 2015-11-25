include common.mk

DEVICE_VERSION := 0.2
DEVICE_PREINSTALLED := http://cdimage.ubuntu.com/ubuntu-core/vivid/daily-preinstalled/current/vivid-preinstalled-core-armhf.device.tar.gz

DEVICE_SRC := $(PWD)/device
DEVICE_UIMAGE := $(DEVICE_SRC)/assets/vmlinuz
DEVICE_INITRD := $(DEVICE_SRC)/initrd
DEVICE_INITRD_IMG := $(DEVICE_SRC)/initrd.img
DEVICE_UINITRD := $(DEVICE_SRC)/assets/initrd.img
DEVICE_MODULES := $(DEVICE_SRC)/system
DEVICE_MODPROBE_D := $(DEVICE_SRC)/system/lib/modprobe.d
DEVICE_FIRMWARE := $(DEVICE_SRC)/system/lib/firmware
DEVICE_TAR := $(PWD)/device-roseapple-pi_$(DEVICE_VERSION).tar.xz
DEVICE_DTBS := $(DEVICE_SRC)/assets/dtbs

all: build

clean:
	rm -f $(DEVICE_UIMAGE) $(DEVICE_UINITRD) $(DEVICE_INITRD_IMG) $(DEVICE_TAR)
	rm -rf $(DEVICE_DTBS)
	rm -rf $(DEVICE_MODULES)
	rm -rf $(DEVICE_INITRD)
	rm -rf $(DEVICE_SRC)/preinstalled
	rm -rf $(DEVICE_MODPROBE_D)

distclean: clean
	rm -rf $(DEVICE_SRC)/preinstalled.tar.gz
	rm -rf $(DEVICE_TAR)

$(DEVICE_SRC):
	mkdir -p $(DEVICE_SRC)

$(DEVICE_SRC)/preinstalled.tar.gz: | $(DEVICE_SRC)
	@wget $(DEVICE_PREINSTALLED) -O $@

$(DEVICE_UIMAGE):
	@if [ ! -f $(KERNEL_UIMAGE) ] ; then echo "Build linux first."; exit 1; fi
	@mkdir -p $(DEVICE_SRC)/assets
	cp -f $(KERNEL_UIMAGE) $(DEVICE_UIMAGE)

$(DEVICE_UINITRD): $(DEVICE_INITRD_IMG)
	@mkdir -p $(DEVICE_SRC)/assets
	@rm -f $(DEVICE_UINITRD)
	mkimage -A arm -T ramdisk -C none -n "Snappy Initrd" -d $(DEVICE_INITRD_IMG) $(DEVICE_UINITRD)

$(DEVICE_INITRD_IMG): preinstalled
	@rm -f $(DEVICE_INITRD_IMG)
	@rm -rf $(DEVICE_INITRD)
	@mkdir -p $(DEVICE_INITRD)
	lzcat $(DEVICE_SRC)/preinstalled/initrd.img | ( cd $(DEVICE_INITRD); cpio -i )
	@rm -rf $(DEVICE_INITRD)/lib/modules
	@rm -rf $(DEVICE_INITRD)/lib/firmware
	( cd $(DEVICE_INITRD); find | sort | cpio --quiet -o -H newc ) | lzma > $(DEVICE_INITRD_IMG)

preinstalled: $(DEVICE_SRC)/preinstalled.tar.gz
	@rm -rf $(DEVICE_SRC)/preinstalled
	@mkdir -p $(DEVICE_SRC)/preinstalled
	tar xzvf $< -C $(DEVICE_SRC)/preinstalled --wildcards 'system/boot/initrd.img-*' --wildcards 'system/lib/firmware/*'
	cp $(DEVICE_SRC)/preinstalled/system/boot/initrd.img-* $(DEVICE_SRC)/preinstalled/initrd.img

modules:
	@if [ ! -e $(KERNEL_MODULES) ] ; then echo "Build linux first."; exit 1; fi
	@rm -rf $(DEVICE_MODULES)
	@mkdir -p $(DEVICE_MODULES)
	make -f linux.mk modules_install
	@rm -rf $(DEVICE_MODULES)/lib/modules/3.10.37/build
	@rm -rf $(DEVICE_MODULES)/lib/modules/3.10.37/source

dtbs:
	@if [ ! -f $(KERNEL_DTB) ] ; then echo "Build linux first."; exit 1; fi
	@mkdir -p $(DEVICE_DTBS)
	cp $(KERNEL_DTB) $(DEVICE_DTBS)

modprobe.d:
	@rm -rf $(DEVICE_MODPROBE_D)
	@mkdir -p $(DEVICE_MODPROBE_D)
	cp -a $(DEVICE_SRC)/modprobe.d/* $(DEVICE_MODPROBE_D)

firmware:
	rsync -rva --exclude "*-generic" $(KERNEL_MODULES)/firmware/ $(DEVICE_FIRMWARE)/

device: $(DEVICE_UIMAGE) $(DEVICE_UINITRD) modules dtbs modprobe.d firmware
	@rm -f $(DEVICE_TAR)
	tar -C $(DEVICE_SRC) -cavf $(DEVICE_TAR) --exclude ./preinstalled --exclude ./preinstalled.tar.gz --exclude ./initrd --exclude ./initrd.img --exclude ./modprobe.d --xform s:'./':: .

build: device

.PHONY: preinstalled modules device build $(DEVICE_INITRD_IMG) $(DEVICE_UIMAGE)
