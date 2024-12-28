#!/bin/bash
<<COMMENT
#
# 2023-10-30 AGX Orin V1.0
#
COMMENT

clear
red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for Sensing SG8A-ORING-GMSL on JetPack-6.0-L4T-36.3.0"
camera_array=([1]=sg2-ar0233c-gmsl2
		[2]=sg2-imx390c-gmsl2
        	[3]=sg2-imx662c-gmsl2
		[4]=sg2-ox03cc-gmsl2 
		[5]=sg8-ar0820c-gmsl2 
		[6]=sg8-ar0823c-gmsl2 
		[7]=sg8-imx728c-gmsl2
		[8]=sg8-ox08bc-gmsl2
		[9]=sg8-ox08dc-gmsl2
		[10]=sg8-s5k1h1sbc-gmsl2)


echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}
echo 4:${camera_array[4]}
echo 5:${camera_array[5]}
echo 6:${camera_array[6]}
echo 6:${camera_array[6]}
echo 7:${camera_array[7]}
echo 8:${camera_array[8]}
echo 9:${camera_array[9]}
echo 10:${camera_array[10]}

green_print "Press select your camera type:"
read key

cd $PWD/ko
if [ "`sudo lsmod | grep max9295`" == "" ];then
	sudo insmod max9295.ko
fi

if [ "`sudo lsmod | grep max9296`" == "" ];then
	sudo insmod max9296.ko
fi

if [ "`sudo lsmod | grep gmsl2`" == "" ];then
	sudo insmod ${camera_array[key]}.ko
fi

green_print "Press select your camera port [0-7]:" 
read port

#if you run this script on remote teminal,pls enable this commond
export DISPLAY=:0
gst-launch-1.0 nvarguscamerasrc sensor-id=${port} ! 'video/x-raw(memory:NVMM),framerate=30/1,format=NV12' ! nvvidconv ! xvimagesink
