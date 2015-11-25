#!/bin/sh

echo $PWD
RELEASE_DIR=$PWD
echo $RELEASE_DIR
cd $PWD/../../../../
echo $PWD

SDK_NAME=AD500A_ubuntu_sdk
SCRIPTS_DIR=ubuntu/owl/scripts/release_scripts
OWL_BOARDS=ubuntu/owl/s500/boards/ubuntu

if [ -d $SDK_NAME ]; then
	echo "rm -rf $SDK_NAME"
	rm -rf $SDK_NAME
fi

if [ -d omx_vd_so ]; then
	echo "rm -rf omx_vd_so"
	rm -rf omx_vd_so
fi

if [ -f ad500a_ubuntu.tar.bz2 ]; then
	echo "rm ad500a_ubuntu.tar.bz2"
	rm ad500a_ubuntu.tar.bz2
fi

mkdir $SDK_NAME
echo "---rsync sdk---"
echo "please wait..."
rsync -r ubuntu $SDK_NAME -l \
      --exclude-from=ubuntu/owl/scripts/release_scripts/AD500A_ubuntu_exclude_files.txt \
      --exclude=ubuntu/owl/s500/boards/ubuntu/*

echo "---copy release board---"
while read -r line || [[ -n $line ]]
do	
	if [ x$line != x ];then
		echo "+++ $line +++"
		cp -r $OWL_BOARDS/$line $SDK_NAME/$OWL_BOARDS
	fi
done < $SCRIPTS_DIR/AD500A_ubuntu_release_boards_cfg.txt

mkdir omx_vd_so
cp ubuntu/ubuntu/omx/vd* omx_vd_so
rm omx_vd_so/vd_xvid.so
rm omx_vd_so/vd_vp8.so
tar -jc -f omx_vd_so.tar.bz2 omx_vd_so
rm -rf omx_vd_so

echo "copy vd_xvid.so && vd_vp8.so to sdk"
copy ubuntu/ubuntu/omx/vd_xvid.so $SDK_NAME/ubuntu/ubuntu/omx
copy ubuntu/ubuntu/omx/vd_vp8.so $SDK_NAME/ubuntu/ubuntu/omx

echo "---tar sdk---"
tar -jc -f ad500a_ubuntu.tar.bz2 $SDK_NAME
rm -rf $SDK_NAME
tar -jx -f ad500a_ubuntu.tar.bz2 -C .
cho "Finish."