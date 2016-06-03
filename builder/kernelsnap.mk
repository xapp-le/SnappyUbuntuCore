include common.mk

all: build

clean:
	rm -f roseapple-pi-kernel*.snap
	if [ -d $(KERNEL_SRC) ] ; then cd $(KERNEL_SRC); snapcraft clean; fi

distclean: clean
	rm -rf $(wildcard $(KERNEL_SRC))
	
build:
	if [ ! -d $(KERNEL_SRC) ] ; then git clone $(KERNEL_REPO) -b $(KERNEL_BRANCH) kernel; fi
	cd $(KERNEL_SRC); snapcraft clean; snapcraft --target-arch armhf snap
	
.PHONY: build
