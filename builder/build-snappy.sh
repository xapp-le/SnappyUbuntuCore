#!/bin/sh

sudo ./tools/ubuntu-device-flash core 16 \
	--gadget roseapple-pi \
	--developer-mode \
	--channel edge \
	--kernel roseapple-pi-kernel \
	--os ubuntu-core \
	-o roseapple-pi-all-snap.img
