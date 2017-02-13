#!/bin/sh
SNAPPY_IMAGE=uc16-roseapple-pi-`date +%Y%m%d`-0.img

sudo /snap/bin/ubuntu-image --channel stable --image-size 4G --extra-snaps roseapple-pi_16.04-1.2_armhf.snap --extra-snaps bluez --extra-snaps snapweb --extra-snaps modem-manager --extra-snaps network-manager -o ${SNAPPY_IMAGE} roseapple.model --debug

sudo dd conv=notrunc if=./gadget/bootloader.bin of=${SNAPPY_IMAGE} seek=2097664 oflag=seek_bytes
sudo dd conv=notrunc if=./gadget/u-boot.bin of=${SNAPPY_IMAGE} seek=3145728 oflag=seek_bytes

if [ -f uc16-roseapple-pi-`date +%Y%m%d`-0.img ]; then
	sudo xz -0 uc16-roseapple-pi-`date +%Y%m%d`-0.img
fi
