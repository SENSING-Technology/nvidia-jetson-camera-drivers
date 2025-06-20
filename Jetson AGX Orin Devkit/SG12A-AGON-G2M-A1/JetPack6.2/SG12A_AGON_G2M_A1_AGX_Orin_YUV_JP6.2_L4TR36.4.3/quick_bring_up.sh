#!/bin/bash
<<COMMENT
#
# 2024-12-25
#
COMMENT

clear
red_print(){
    echo -e "\e[1;31m$1\e[0m"
}
green_print(){
    echo -e "\e[1;32m$1\e[0m"
}

red_print "This package is use for Sensing SG12A_AGON_G2M_A1 on JetPack-6.2-L4T-36.4.3"
camera_array=([1]=1920x1080
              [2]=1920x1536
			  [3]=2880x1860
      	      [4]=3840x2160)

echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}
echo 4:${camera_array[4]}

if [ "`sudo lsmod | grep sgx_yuv_gmsl2`" == "" ];then
	sudo busybox devmem 0x0c302050 w 0x0009
	sudo busybox devmem 0x0c302038 w 0x0009
	sudo insmod ./ko/sgx-yuv-gmsl2.ko 
fi	

green_print "Press select your YUV camera resolution:"
read key

green_print "Press select your camera port [0-11]:" 
read port

if [[ "$key" == "1" || "$key" == "2" ]]; then
	green_print "Please select your camera serializer type [0: GMSL2_6G, 1: GMSL2_3G]:"
	read gmslmode
fi

green_print "Select your trigger mode [0:Internal trigger, 1:External trigger]:" 
read trig_mode

green_print "Start bring up camera!" 

string=(`echo ${camera_array[key]} | tr 'x' ' '`)

if [ $trig_mode == 1 ];then
	if [ $port -le 7 ];then
		if [ $key == 1 ];then
			if [ $gmslmode == 0 ];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=0,trig_mode=2,trig_pin=0x27 -d /dev/video${port}
			elif [ $gmslmode == 1 ];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=1,trig_mode=2,trig_pin=0x27 -d /dev/video${port}
			fi
		elif [ $key == 2 ];then
			if [ $gmslmode == 0 ];then
    	            v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=0,trig_mode=2,trig_pin=0x27 -d /dev/video${port}
			elif [ $gmslmode == 1 ];then
					v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=1,trig_mode=2,trig_pin=0x27 -d /dev/video${port}
			fi
		elif [ $key == 3 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=2,trig_pin=0x27 -d /dev/video${port}
		elif [ $key == 4 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=2,trig_pin=0x27 -d /dev/video${port}
		fi
	else
		if [ $key == 1 ];then
			if [ $gmslmode == 0 ];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=0,trig_mode=2,trig_pin=0x67 -d /dev/video${port}
			elif [ $gmslmode == 1];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=1,trig_mode=2,trig_pin=0x67 -d /dev/video${port}
			fi
		elif [ $key == 2 ];then
    	   	if [ $gmslmode == 0 ];then
    	            v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=0,trig_mode=2,trig_pin=0x67 -d /dev/video${port}
			elif [ $gmslmode == 1 ];then
					v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=1,trig_mode=2,trig_pin=0x67 -d /dev/video${port}
			fi
		elif [ $key == 3 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=2,trig_pin=0x67 -d /dev/video${port}
		elif [ $key == 4 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=2,trig_pin=0x67 -d /dev/video${port}
		fi
	fi
else
	if [ $port -le 7 ];then
		if [ $key == 1 ];then
			if [ $gmslmode == 0 ];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=0,trig_mode=0,trig_pin=0x27 -d /dev/video${port}
			elif [ $gmslmode == 1 ];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=1,trig_mode=0,trig_pin=0x27 -d /dev/video${port}
			fi
		elif [ $key == 2 ];then
			if [ $gmslmode == 0 ];then
    	            v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=0,trig_mode=0,trig_pin=0x27 -d /dev/video${port}
			elif [ $gmslmode == 1 ];then
					v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=1,trig_mode=0,trig_pin=0x27 -d /dev/video${port}
			fi
		elif [ $key == 3 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=1,trig_pin=0x27 -d /dev/video${port}
		elif [ $key == 4 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=0,trig_pin=0x27 -d /dev/video${port}
		fi
	else
		if [ $key == 1 ];then
			if [ $gmslmode == 0 ];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=0,trig_mode=0,trig_pin=0x67 -d /dev/video${port}
			elif [ $gmslmode == 1 ];then
				v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=1,gmsl_mode=1,trig_mode=0,trig_pin=0x67 -d /dev/video${port}
			fi
		elif [ $key == 2 ];then
			if [ $gmslmode == 0 ];then
    	            v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=0,trig_mode=0,trig_pin=0x67 -d /dev/video${port}
			elif [ $gmslmode == 1 ];then
					v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=2,gmsl_mode=1,trig_mode=0,trig_pin=0x27 -d /dev/video${port}
			fi
		elif [ $key == 3 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=3,trig_mode=1,trig_pin=0x67 -d /dev/video${port}
		elif [ $key == 4 ];then
			v4l2-ctl -V --set-fmt-video=width=${string[0]},height=${string[1]} --set-ctrl bypass_mode=0,sensor_mode=4,trig_mode=0,trig_pin=0x67 -d /dev/video${port}
		fi
	fi
fi	

#if you run this script on remote teminal,pls enable this commond
#export DISPLAY=:0
gst-launch-1.0 v4l2src device=/dev/video${port}  ! xvimagesink -ev
