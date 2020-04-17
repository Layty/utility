#!/bin/bash
# 参数为start 表示强制执行一次
# 限制每天启动的次数, 0 执行一次 1 等待执行时间 2 无法完成任务,ping不通
# 因为创建在/tmp/wechat_up.log 所以每次开机都执行
# 启动间隔为3600s,也就是1h
max=3600    





# 取得上次成功上报的时间戳
config="/tmp/wechat_up.log"
# 强制执行一次
if [[ "$#" = "0" ]] && [[ "$1" = "start" ]] ; then
echo 0 > $config
fi


if [  -f "$config" ]; then
    last=$(tail $config -n1 )
fi

if [ "$last" -gt 0 ] 2>/dev/null ;then 
    echo "$last is number." 
else 
    last=0 
fi
echo "last="$last

# 获得当前时间戳
now=$(date +%s)
echo "now ="$now

# 取得时间差
let abs="$now"-"$last"
if [ "$abs" -lt 0 ]; then
  let abs=0-$abs;
fi
echo "diff="$abs

#一小时只能运行一次,如果上次是失败的,可以马上再来
if [ $abs -lt $max ]; then
  echo "we have upload !!!"
  exit 2
fi



case $(uname -m) in
    i386)   title="ubuntu:"$(ifconfig ens33 |grep "ether" |awk '{print  $2}')"--"$(date +%Y-%m-%d-%H:%M) ;;
    x86_64) title="ubuntu:"$(ifconfig ens33 |grep "ether" |awk '{print  $2}')"--"$(date +%Y-%m-%d-%H:%M) ;;
    *)      title="imx:"$(cat /sys/fsl_otp/HW_OCOTP_CFG0)$(cat /sys/fsl_otp/HW_OCOTP_CFG1)"--"$(date +%Y-%m-%d-%H:%M) ;;
esac

i=0
loop=60
sleepTime=10 # 10*10*6=10 min 退出
while [ $i -le $loop ]; do

    let i++

    remote_ip="www.baidu.com"
    ping -c 1  -w 2  $remote_ip
    if [ $? -eq 0 ] ;then
            echo  "ping "$remote_ip" ok"
            title="$title"
            txt="$(ifconfig -a | grep -i -E "eth|mask")"
            txt="\`\`\`\n"+$txt+"\n\`\`\`";
            txt=`echo -e "${txt}"`
            #curl "http://sc.ftqq.com/SCU48595Ted99b0efd37887ebebf02013bb9fcd4b5caf442bd10eb999.send" -X POST -d "text=$title&desp=$txt"
            # ./curl_wechat.exe  "$title"  "$(ifconfig -a | grep -i -E "eth|mask")
            # 记录成功值
            echonow=$(date +%s)
            echo  $echonow > $config
            exit 0
    else
            echo  "ping "$remote_ip" Error, exit"
            sleep $sleepTime 
    fi
done
exit 1