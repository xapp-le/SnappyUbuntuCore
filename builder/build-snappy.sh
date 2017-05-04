#!/bin/sh
SNAPPY_IMAGE=uc16-roseapple-pi-`date +%Y%m%d`-0.img

sudo ubuntu-image -d -c edge roseapple.model
#sudo dd conv=notrunc if=./gadget/bootloader.bin of=${SNAPPY_IMAGE} seek=2097664 oflag=seek_bytes
#sudo dd conv=notrunc if=./gadget/u-boot.bin of=${SNAPPY_IMAGE} seek=3145728 oflag=seek_bytes

if [ -f roseapple-pi.img ]; then
	sudo mv roseapple-pi.img ${SNAPPY_IMAGE}
	sudo xz -0 uc16-roseapple-pi-`date +%Y%m%d`-0.img
fi
