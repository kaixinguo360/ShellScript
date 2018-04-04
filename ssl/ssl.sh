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


# 安装准备

# 设置变量
NGINX_CONF='/etc/nginx/sites-enabled/default'
SSL_CONF='/etc/nginx/sites-enabled/default'
SSL_CONF_URL='https://raw.githubusercontent.com/kaixinguo360/BashScript/master/ssl/nginx_ssl_config'

# 读取参数

read -p '您的网站域名: ' SERVER_NAME


# 正式安装开始

#安装 acme.sh 以自动获取SSL证书
ACME_HOME="${HOME}/.acme.sh"
if [ ! -x ${ACME_HOME}/acme.sh ]; then
    su - $SUDO_USER -c "curl  https://get.acme.sh | sh"
    source ${ACME_HOME}/acme.sh.env
fi

# 获取SSL证书
~/.acme.sh/acme.sh --issue  -d  ${SERVER_NAME}  --nginx

# 安装SSL证书
~/.acme.sh/acme.sh  --installcert  -d  ${SERVER_NAME} \
        --key-file  /etc/nginx/ssl/${SERVER_NAME}.key \
        --fullchain-file  /etc/nginx/ssl/fullchain.cer \
        --reloadcmd  "service nginx force-reload"

# 修改Nginx配置文件 - sites-enabled/default
sed "s/#listen 443 ssl/listen 443 ssl/g" ${NGINX_CONF} -i
sed "s/#listen [::]:443/listen [::]:443/g" ${NGINX_CONF} -i
sed "/#include snippets\/snakeoil.conf;/a\include my\/ssl.conf;" ${NGINX_CONF} -i

# 修改Nginx配置文件 - my/ssl.conf
mkdir /etc/nginx/my
echo -e "ssl_certificate /etc/nginx/ssl/fullchain.cer;" >> /etc/nginx/my/ssl.conf
echo -e "ssl_certificate_key /etc/nginx/ssl/${SERVER_NAME}.key;" >> /etc/nginx/my/ssl.conf
echo -e "keepalive_timeout   70;" >> /etc/nginx/my/ssl.conf

# 重启Nginx
service nginx force-reload


