#!/bin/bash
##注意! 此脚本写的巨烂...
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
cat > tmp_proxys.sh << "HERE"
#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export RESULT=${RESULT}$1.$2
expect << HERE2
    spawn ./proxy.sh
    
    expect "*您的网站域名*"
    send "$2\r"
    
    expect "*目标网站域名*"
    send "$1\r"
    
    expect "*默认本地配置*"
    send "y\r"
    
    expect "*acme.sh签名*"
    send "n\r"
    
    expect "*开启Cookies*"
    send "y\r"
    
    expect eof
HERE2
HERE
chmod +x tmp_proxys.sh

# 正式开始运行
wget -O proxy.sh ${PROXY_URL}
chmod +x proxy.sh
cat ${SOURCE_PATH} | awk '{print "https://"$1"\t-->\thttps://"$2;cmd1="./tmp_proxys.sh "$1" "$2"> /dev/null";system(cmd1);}'
rm -rf proxy.sh
rm -rf tmp_proxys.sh

# 运行完成
echo -e "\n  ## 运行完成 ##\n"
