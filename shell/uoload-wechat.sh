#!/bin/bash
# ���뿪���ű�����������ϱ�Ip mac
# ����Ϊstart ��ʾǿ��ִ��һ��
# ����ÿ�������Ĵ���, 0 ִ��һ�� 1 �ȴ�ִ��ʱ�� 2 �޷��������,ping��ͨ

# �������Ϊ3600s,Ҳ����1h
max=3600    




# ȡ���ϴγɹ��ϱ���ʱ���
config="/tmp/wechat_up.log"
# ǿ��ִ��һ��
if [[ $# > 0 ]] && [[ $1 = "start" ]]; then 
    rm $config
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

# ��õ�ǰʱ���
now=$(date +%s)
echo "now ="$now

# ȡ��ʱ���
let abs="$now"-"$last"
if [ "$abs" -lt 0 ]; then
  let abs=0-$abs;
fi
echo "diff="$abs

#һСʱֻ������һ��,����ϴ���ʧ�ܵ�,������������
if [ $abs -lt $max ]; then
  echo "we have upload !!!"
  exit 2
fi



case $(uname -m) in
    i386)   title="ubuntu:"$(ifconfig ens33 |grep "ether" |awk '{print  $2}')"--"$(date +%Y-%m-%d-%H:%M) ;;
    x86_64) title="ubuntu:"$(ifconfig ens33 |grep "ether" |awk '{print  $2}')"--"$(date +%Y-%m-%d-%H:%M) ;;
    *)      title="imx:"$(cat /sys/fsl_otp/HW_OCOTP_CFG0)$(cat /sys/fsl_otp/HW_OCOTP_CFG1)"--"$(date +%Y-%m-%d-%H:%M) ;;
esac


sleepTime=10 # 10*10*6=10 min �˳�
for((i=1;i<=((10*6));i++)); do 
    remote_ip="www.baidu.com"
    ping -c 1  -w 2  $remote_ip
    if [ $? -eq 0 ] ;then
            echo  "ping "$remote_ip" ok"
            title="$title"
            txt="$(ifconfig -a | grep -i -E "eth|mask")"
            txt="\`\`\`\n"+$txt+"\n\`\`\`";
            txt=`echo -e "${txt}"`
            #curl "http://sc.ftqq.com/SCU48595Ted99b0efd37887ebebf02013bb9fcd4b5caf442bd10eb9.send" -X POST -d "text=$title&desp=$txt"
            # ./curl_wechat.exe  "$title"  "$(ifconfig -a | grep -i -E "eth|mask")
            # ��¼�ɹ�ֵ
            echonow=$(date +%s)
            echo  $echonow > $config
            exit 0
    else
            echo  "ping "$remote_ip" Error, exit"
            sleep $sleepTime 
    fi
done
exit 1