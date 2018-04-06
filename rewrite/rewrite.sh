#!/bin/bash
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
 
# 正式安装开始

# 设置变量
NGINX_CONF='/etc/nginx/sites-enabled/'
NGINX_REWRITE_CONF_URL='https://raw.githubusercontent.com/kaixinguo360/Shellcript/master/rewrite/nginx_rewrite_config'

# 读取参数
read -p '您的网站域名: ' SERVER_NAME

# 安装配置
wget -O "${NGINX_CONF}rewrite" "${NGINX_REWRITE_CONF_URL}"
sed "s/TMP_SERVER_NAME/${SERVER_NAME}/g" "${NGINX_CONF}rewrite" -i
sed "s/ default_server//g" "${NGINX_CONF}default" -i

# 重启Nginx服务
service nginx restart
