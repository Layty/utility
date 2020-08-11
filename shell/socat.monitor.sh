#!/bin/bash


ip="192.168.1.114"
port="5555"

arm_plc=/dev/ttymxc6
arm_bps=921600
arm_pty1=/tmp/mypty1
arm_pty2=/tmp/mypty2
linux_pty=/tmp/ptyplc
#`cat   socat.log  | grep "pts" | awk -F " " '{print $7}' | sed -n '1p'`


armFun()
{
        killall socat  2>/dev/null
		# 1. PTY
        socat -d -d  -x  -lf socat.log   PTY,link=$arm_pty1,user=`whoami`,raw,echo=0,ignoreeof  PTY,link=$arm_pty2,user=`whoami`,raw,echo=0,ignoreeof &
		sleep 1
        #2. 网络端
        socat   udp-listen:$port,reuseaddr,fork  $arm_pty1,raw,nonblock,ignoreeof,echo=0  &
        #3. 实际串口端
        socat   $arm_pty2,raw,nonblock,ignoreeof,echo=0   GOPEN:$arm_plc,b$arm_bps,raw,echo=0 &
}

ubuntuFun()
{
        killall socat  2>/dev/null
        socat -d -d -x  PTY,link=$linux_pty,user=`whoami`,raw,echo=0,ignoreeof   udp4:$ip:$port &
}


result=$(echo `uname -a ` | grep "arm")
if [[  "$result" != ""  ]]
then
    echo "arm"
        armFun
else
    echo "ubuntu"
        ubuntuFun
fi
