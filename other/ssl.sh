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
SITE_CONF_ROOT='/etc/nginx/sites-enabled/'
MY_CONF_ROOT='/etc/nginx/my/'
SSL_PATH='/etc/nginx/ssl/'

# 读取参数

read -p '您的网站域名: ' SERVER_NAME
read -p '您的网站的本地配置文件名: ' SITE_NAME
SITE_CONF=${SITE_CONF_ROOT}'${SITE_NAME}
MY_CONF=${MY_CONF_ROOT}${SITE_NAME}/


# 正式安装开始

#安装 acme.sh 以自动获取SSL证书
ACME="${HOME}/.acme.sh/acme.sh"
if [ ! -x ${ACME} ]; then
    su - $SUDO_USER -c "curl  https://get.acme.sh | sh" && source "${HOME}/.acme.sh/acme.sh.env"
fi

# 获取SSL证书
${ACME} --issue  -d  ${SERVER_NAME}  --nginx || exit -1

# 安装SSL证书
mkdir -p ${SSL_PATH}
${ACME}  --installcert  -d  ${SERVER_NAME} \
        --key-file  ${SSL_PATH}${SERVER_NAME}.key \
        --fullchain-file  ${SSL_PATH}fullchain.cer \
        --reloadcmd  "service nginx force-reload" || exit -1

# 初始化Nginx-MY配置环境
if [ ! -e ${MY_CONF} ]; then
    mkdir -p ${MY_CONF}
    sed "s/#include snippets\/snakeoil.conf;/include my\/${SITE_NAME}\/\*.conf;/g" ${SITE_CONF} -i
    sed "s/# Virtual Host configuration for example.com/include my\/${SITE_NAME}\/\*.ser;/g" ${SITE_CONF} -i
fi

# 修改Nginx配置,打开SSL端口
sed "s/#listen 443 ssl/listen 443 ssl/g" ${SITE_CONF} -i
sed "s/#listen \[::\]:443 ssl/listen \[::\]:443 ssl/g" ${SITE_CONF} -i

# 增加Nginx-MY配置文件 - ssl.conf
cat > ${MY_CONF}ssl.conf << HERE
ssl_certificate ${SSL_PATH}fullchain.cer;
ssl_certificate_key ${SSL_PATH}${SERVER_NAME}.key;
keepalive_timeout   70;
HERE

# 重启Nginx
service nginx force-reload


