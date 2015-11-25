#! /bin/sh
#get cpu arc
OS_ARC=0
if [ "`uname -a | grep 64`" ];then
	OS_ARC=64
else
	OS_ARC=32
fi


#get linux version
CURRENT_VER=`cat /etc/issue`
INSTALL_VER=10
LINUX_VER=10

VER10="buntu *10"
echo "$CURRENT_VER" | grep -q "$VER10"
if [ $? -eq 0 ]; then
	LINUX_VER=10
fi 

VER11="buntu *11"
echo "$CURRENT_VER" | grep -q "$VER11"
if [ $? -eq 0 ]; then
	LINUX_VER=11
fi

VER12="buntu *12"
echo "$CURRENT_VER" | grep -q "$VER12"
if [ $? -eq 0 ]; then
	LINUX_VER=12
fi

#get python ver
U_V1=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $1}'`
U_V2=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $2}'`
U_V3=`python -V 2>&1|awk '{print $2}'|awk -F '.' '{print $3}'`
PY_VER=0

if [ $U_V1 -lt 2 ];then
	echo 'Your python version is not OK!(1)'
	exit 1
else
	if [ $U_V2 -eq 6 ];then
		PY_VER=26     
	elif [ $U_V2 -eq 7 ];then
		PY_VER=27     
	else
		echo 'Your python version is not OK!(3)'
		exit 1
	fi
fi    
echo "$OS_ARC" bit,Ubuntu "$LINUX_VER",Python "$PY_VER"

cp ./AllRelease/"$INSTALL_VER"_"$OS_ARC"/* ./Output
cp ./AllRelease/"$PY_VER"/* ./Output

