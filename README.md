# SnappyUbuntuCore
Roseapple Pi [Snappy Ubuntu Core](http://developer.ubuntu.com/snappy/) 

## Changelog
- Change oem snap from local to public store.

## Structure
builder: build Snappy via makefiles, and that includes OEM snap and device part.  
prebuild: prebuild iamge for test purpose.

## Requirements
To build all parts, a couple of dependencies are required. On Ubuntu you can install all build dependencies with the following command.

```bash
sudo apt-get install build-essential u-boot-tools lzop debootstrap debootstrap gcc-arm-linux-gnueabihf device-tree-compiler
```

Make sure your build environment is based on Ubuntu 14.04 or later. Then, you need to install snappy tools from PPA, for creating image.

```bash
sudo add-apt-repository -y ppa:snappy-dev/tools
sudo apt-get update
sudo apt-get install ubuntu-device-flash
```

Generate ssh key-pair if you did not have one

```bash
ssh-keygen -t rsa
```

## Quick Build
A `Makefile` is provided to build Snappy, OEM snap, U-Boot, Kernel and Initrd from source. The sources will be cloned into local folders if not there already.

To build it all, just run `make snappy`. This will produce a Snappy image, a oem snap `roseapple-pi_x.y_all.snap` and a `device-roseapple-pi_x.y.tar.gz` device part, which can be used to build your own Snappy image.

### Custom Image
If you want to build the speical version with including the snap you'd like to install from ubuntu store, you can modify the snappy.mk to reach it. For example:  

```bash
sudo ubuntu-device-flash core 15.04 \
	--oem roseapple-pi.woodrow \
	--device-part=device-roseapple-pi_0.2.tar.xz \
	--channel stable \
	-o roseapple-pi-`date +%Y%m%d`-0.img \
	--install docker.canonical/stable
```

### Build U-boot

```bash
make u-boot
```

### Build OEM snap

```bash
make oem
```

### Build device part

```bash
make device
```

### Rebuild a snappy
To rebuild the snappy or other parts, just type `make clean` or `make clean-{prefix}`. The prefix will be u-boot, oem, linux, etc. 

## Flash to SD card
Before dd, we suggest the SD card storage should be umounted to safely clean up.

```bash
xzcat ${image} | pv | sudo dd of=/dev/${device} bs=32M ; sync
```
