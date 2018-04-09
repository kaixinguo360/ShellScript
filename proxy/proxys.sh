#!/bin/bash
##注意! 此脚本写的巨烂！
##将就着用吧...
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# 检查是否为Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

# 检查系统信息
if [ ! -z "`cat /etc/issue | grep 'Ubuntu 16'`" ];
    then
        OS='Ubuntu'
    else
        echo "Not support OS(Ubuntu 16), Please reinstall OS and retry!"
        #exit 1
fi


## 设置静态参数 ##
PROXY_URL='https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/proxy/proxy.sh'

## 读取输入参数 ##
SOURCE_PATH=$1

if [ "${SOURCE_PATH}" = "" ];then
echo -e "用法: $0 参数文件\n"
echo -e "参数文件格式: 每行: 目标域名 本地域名\n"
exit 0
fi

if [ ! -e ${SOURCE_PATH} ];then
echo "错误! 文件${SOURCE_PATH}不存在!"
exit 0
fi

# 工具函数
cat > tmp_proxys.sh <<- "HERE"
  #!/bin/bash
  export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
  
  if [ "$3" = "y" ]; then
    IS_ACME="y"
  elif [ "$3" = "s" ]; then
    IS_ACME="s"
  else
    IS_ACME="n"
  fi
  
expect <<- HERE2
    spawn ./proxy.sh
    
    expect "*您的网站域名*"
    send "$2\r"
    
    expect "*目标网站域名*"
    send "$1\r"
    
    expect "*默认本地配置*"
    send "y\r"
    
    expect "*证书*"
    send "${IS_ACME}\r"
    
    expect "*开启Cookies*"
    send "y\r"
    
    expect eof
HERE2

HERE
chmod +x tmp_proxys.sh

# 正式开始运行
wget -O proxy.sh ${PROXY_URL} -q
echo ""
chmod +x proxy.sh
cat ${SOURCE_PATH} | awk '
    BEGIN {
        print "目标网站域名", "        -->        ", "本地网站域名";
        print "==================================================================";
    }
    {
        printf "https://%s    -->    https://%s    ", $1, $2;
        if ( $1!="" && $2!="") {
                cmd="./tmp_proxys.sh " $1 " " $2 " " $3 " > /dev/null";
                res=system(cmd);
        } else {
                res=1
        }
        if (res == 0) {
                print "[\033[32m OK \033[0m]";
        } else {
                print "[\033[31m Fail \033[0m]";
        }
    }
    END {
        print "==================================================================";
        print "总共建立了", NR, "个代理";
    }
'
rm -rf proxy.sh
rm -rf tmp_proxys.sh

# 运行完成
echo -e "正在重启Nginx服务器..."
sleep 5s
service nginx restart
echo -e "重启Nginx服务器完成!"
echo -e "\n全部任务完成\n"
