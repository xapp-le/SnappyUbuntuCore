#!/bin/sh

echo $PWD
RELEASE_DIR=$PWD
echo $RELEASE_DIR
CURRENT_DIR=$PWD/../../../../
cd $CURRENT_DIR
echo $PWD

SYSTEM_OS=android
SDK_NAME=AD500A_android_sdk
PREBUILT_UTILS=android/android/device/actions/common/prebuilt/utils
SCRIPTS_DIR=android/owl/scripts/release_scripts
DEVICE_ACTIONS=android/android/device/actions
OWL_BOARDS=android/owl/s500/boards/android
TAR_NAME=ad500a_android.tar.bz2
RELEASE_BOARDS_TXT=AD500A_android_release_boards_cfg.txt
EXCLUDE_FILES_TXT=AD500A_android_exclude_files.txt
ANDROID_PREBUILTS=android/android/prebuilts
ANDROID_OWL=android/owl
BOARD_OUT_NAME=`grep "BOARD_NAME=" android/owl/.config | awk -F "BOARD_NAME=" '{print $2}'`
OUT_PRODUCT_LIB=android/android/out/target/product/$BOARD_OUT_NAME/system/lib

if [ -d $SDK_NAME ]; then
	echo "rm -rf $SDK_NAME"
	rm -rf $SDK_NAME
fi

if [ -f $TAR_NAME ]; then
	echo "rm $TAR_NAME"
	rm $TAR_NAME
fi

mkdir $SDK_NAME
echo "---rsync sdk---"
echo "please wait..."
rsync -r $SYSTEM_OS $SDK_NAME -l \
      --exclude-from=$SCRIPTS_DIR/$EXCLUDE_FILES_TXT \
      --exclude=.git \
      --exclude=.gitignore \
      --exclude=*.o \
      --exclude=*.cmd \
      --exclude=*.order
rsync -r $ANDROID_PREBUILTS/ $SDK_NAME/$ANDROID_PREBUILTS/ -l \
			--exclude=.git \
			--exclude=.gitignore

echo "---copy release board---"

cd $CURRENT_DIR/$SDK_NAME/$DEVICE_ACTIONS
ls | grep -v "common" | grep -v "populat_new_device.sh" | xargs rm -rf
cd $CURRENT_DIR

mkdir -p $SDK_NAME/$OWL_BOARDS
while read -r line || [[ -n $line ]]
do	
	if [ x$line != x ];then
		echo "+++ $line +++"
		cp -r $DEVICE_ACTIONS/$line $SDK_NAME/$DEVICE_ACTIONS
		cp -r $OWL_BOARDS/$line $SDK_NAME/$OWL_BOARDS
	fi
done < $SCRIPTS_DIR/$RELEASE_BOARDS_TXT

#dispose device/actions/performancemanager
echo "---dispose device/actions/performancemanager---"
cp ${OUT_PRODUCT_LIB}/libperformance.so $SDK_NAME/$PREBUILT_UTILS

echo "---tar sdk---"
tar -jc -f $TAR_NAME $SDK_NAME
#rm -rf $SDK_NAME
tar -jx -f $TAR_NAME -C .
echo "Finish."