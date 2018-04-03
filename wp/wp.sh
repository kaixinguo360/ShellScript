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
NGINX_CONF='/etc/nginx/sites-available/default'
NGINX_CONF_URL='https://raw.githubusercontent.com/kaixinguo360/BashScript/master/wp/nginx_site_config'
WP_CONF='/var/www/html/wp-config.php'
WP_URL='https://cn.wordpress.org/wordpress-4.9.4-zh_CN.tar.gz'

# 读取参数
read -p '当前用户名: ' USER_NAME

read -p '您的网站域名: ' SERVER_NAME

read -p "请设置WP数据库用户名: " WP_USER

while true :
do
    read -s -p "请设置WP数据库密码: " WP_PW_1
    read -s -p "请再输入一遍: " WP_PW_2
    if [ "${WP_PW_1}"="${WP_PW_2}" ]; then
        WP_PW = ${WP_PW_1}
        break
    else
        echo "两次输入密码不一致!"
    fi
done
echo ''

read -s -p "请输入MySQL根密码: " MYSQL_PW
echo ''


# 数据库操作
MYSQL_SHORTCUT = "mysql -u root -p ${MYSQL_PW} -e"
# 创建数据库
${MYSQL_SHORTCUT} "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
# 创建WP用户
${MYSQL_SHORTCUT} "GRANT ALL ON wordpress.* TO '${WP_USER}'@'localhost' IDENTIFIED BY '${WP_PW}';"
# 刷新特权, 令MySQL知道最近的改变:
${MYSQL_SHORTCUT} "FLUSH PRIVILEGES;"

# 配置Nginx
wget -O ${NGINX_CONF} ${NGINX_CONF_URL}
sed "s/TMP_SERVER_NAME/${SERVER_NAME}/g" ${NGINX_CONF} -i
systemctl restart nginx

# 安装PHP扩展插件
apt-get install php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc -y
systemctl restart php7.0-fpm

# 下载WordPress
cd /tmp
wget -O wp.tar.gz ${WP_URL}
tar xzvf wp.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/html

# 配置WordPress文件夹权限
chown -R ${USER_NAME}:www-data /var/www/html
find /var/www/html -type d -exec chmod g+s {} \;
chmod g+w /var/www/html/wp-content
chmod -R g+w /var/www/html/wp-content/themes
chmod -R g+w /var/www/html/wp-content/plugins

# 修改WordPress配置
sed "s/database_name_here/wordpress/g" ${WP_CONF} -i
sed "s/username_here/${WP_USER}/g" ${WP_CONF} -i
sed "s/password_here/${WP_PW}/g" ${WP_CONF} -i
echo "\n/** 设置写入文件系统的方法 */\ndefine('FS_METHOD', 'direct');" >> ${WP_CONF}

# 不知为何加上这句才能用...
chown -R www-data /var/www/html
