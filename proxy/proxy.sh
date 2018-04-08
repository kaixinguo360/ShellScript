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


## 初始化安装参数 ##

# 设置静态变量
MY_CONF='/etc/nginx/my/'
NGINX_CONF='/etc/nginx/sites-enabled/'
PROXY_CONF_URL='https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/proxy/nginx_proxy_config'
NEW_SITE_URL="https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/other/new_site.sh"

# 读取用户输入
read -p '您的网站域名: ' SERVER_NAME
read -p '您的目标网站域名: ' TARGET_NAME

SITE_NAME="$SERVER_NAME"
while true :
do
	read -r -p "使用本默认本地配置文件:(${SITE_NAME})? [Y/n] " input
	case $input in
	    [yY][eE][sS]|[yY])
			break
            		;;

	    [nN][oO]|[nN])
			read -p '设置新的本地配置文件名:: ' SITE_NAME
			echo -e "已设置新的本地配置文件名:(${SITE_NAME})"
            		break
            		;;

	    *)
		echo "Invalid input..."
		;;
	esac
done

# 安装正式开始

# 建立MY-INCLUDE环境
if [ -e ${NGINX_CONF}include ]; then
HAS_PROXY=$(sed -n "/include my\/proxy/\*;/p" ${NGINX_CONF}include)
fi
if [ -n "${HAS_PROXY}" ]; then
mkdir -p ${MY_CONF}proxy
cat >> ${NGINX_CONF}include << HERE
include my/proxy/*;
HERE
fi

# 运行new_site.sh
wget -O new_site.sh ${NEW_SITE_URL}
chmod +x new_site.sh

expect << HERE
  spawn ./new_site.sh
  
  expect "*本地配置文件名*"
  send "${SITE_NAME}\r"
  
  expect "*默认根目录*"
  send "n\r"
  
  expect "*新的根目录*"
  send "tmp_proxy"
  
  expect "*域名*"
  send "${SERVER_NAME}\r"
  
  expect "*启用SSL*"
  send "y\r"
  
  expect eof
HERE

rm -rf new_site.sh
rm -rf /etc/nginx/my/${SITE_NAME}
rm -rf /var/www/tmp_proxy

# 下载配置文件
wget -O ${MY_CONF}proxy/${SITE_NAME} ${PROXY_CONF_URL}

# 修改配置文件
sed -i "s/TMP_SERVER_NAME/${SERVER_NAME}/g" ${MY_CONF}proxy/${SITE_NAME}
sed -i "s/TMP_TARGET_NAME/${TARGET_NAME}/g" ${MY_CONF}proxy/${SITE_NAME}

# 重启Nginx服务器
service nginx restart
