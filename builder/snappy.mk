include common.mk

SNAPPY_VERSION := `date +%Y%m%d`-0
SNAPPY_IMAGE := roseapple-pi-${SNAPPY_VERSION}.img
# yes for latest version; no for the specific revision of edge/stable channel
SNAPPY_CORE_NEW := yes
SNAPPY_CORE_VER ?=
SNAPPY_CORE_CH := stable
GADGET_VERSION := `gadget/meta/snap.yaml | grep version: | awk '{print $2}'`
GADGET_SNAP := roseapple-pi_$(GADGET_VERSION)_armhf.snap
KERNEL_SNAP_VERSION := `kernelsnap/meta/snap.yaml | grep version: | awk '{print $2}'` 
KERNEL_SNAP := roseapple-pi-kernel_$(KERNEL_SNAP_VERSION)_amdhf.snap
REVISION ?=
SNAPPY_WORKAROUND := no

all: build

clean:
	rm -f $(OUTPUT_DIR)/*.img.xz
distclean: clean

build-snappy:
ifeq ($(SNAPPY_CORE_NEW),no)
		$(eval REVISION = --revision $(SNAPPY_CORE_VER))
endif
	@echo "build snappy..."
	sudo ubuntu-device-flash core 16 -v \
		--channel $(SNAPPY_CORE_CH) \
		--size 4 \
		--gadget $(GADGET_SNAP) \
		--kernel $(KERNEL_SNAP) \
		--os ubuntu-core \
		-o $(SNAPPY_IMAGE) \
		$(REVISION)

fix-bootflag:
	dd conv=notrunc if=boot_fix.bin of=$(SNAPPY_IMAGE) seek=440 oflag=seek_bytes

workaround:
ifeq ($(SNAPPY_WORKAROUND),yes)
	@echo "workaround something..."
endif

pack:
	xz -0 $(SNAPPY_IMAGE)

build: build-snappy fix-bootflag workaround pack 

.PHONY: build-snappy fix-bootflag workaround pack build
