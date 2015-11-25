#!/bin/sh

echo $PWD
RELEASE_DIR=$PWD
echo $RELEASE_DIR
cd $PWD/../../../../
echo $PWD

SDK_NAME=AD500A_debian_sdk
SCRIPTS_DIR=debian/owl/scripts/release_scripts
OWL_BOARDS=debian/owl/boards/debian

if [ -d $SDK_NAME ]; then
	echo "rm -rf $SDK_NAME"
	rm -rf $SDK_NAME
fi

if [ -f ad500a_debian.tar.bz2 ]; then
	echo "rm ad500a_debian.tar.bz2"
	rm ad500a_debian.tar.bz2
fi

mkdir $SDK_NAME
echo "---rsync sdk---"
echo "please wait..."
rsync -r debian $SDK_NAME -l \
      --exclude-from=debian/owl/scripts/release_scripts/AD500A_debian_exclude_files.txt \
      --exclude=.git \
      --exclude=.gitignore \
      --exclude=*.o \
      --exclude=*.cmd \
      --exclude=*.order \
      --exclude=debian/owl/boards/debian/*

echo "---copy release board---"
while read -r line || [[ -n $line ]]
do	
	if [ x$line != x ];then
		echo "+++ $line +++"
		cp -r $OWL_BOARDS/$line $SDK_NAME/$OWL_BOARDS
	fi
done < $SCRIPTS_DIR/AD500A_debian_release_boards_cfg.txt

echo "---tar sdk---"
tar -jc -f ad500a_debian.tar.bz2 $SDK_NAME
rm -rf $SDK_NAME
tar -jx -f ad500a_debian.tar.bz2 -C .
echo "Finish."