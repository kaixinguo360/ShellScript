#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# 检查是否为Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

# 检查系统信息
if [ ! -z "`cat /etc/issue | grep 'Ubuntu 16.04'`" ];
    then
        OS='Ubuntu'
    else
        echo "Not support OS(Ubuntu 16.04), Please reinstall OS and retry!"
        #exit 1
fi


# 正式安装开始

# 设置变量
PHP_CONF='/etc/php/7.0/fpm/php.ini'
NGINX_CONF='/etc/nginx/sites-available/default'
NGINX_CONF_URL='https://raw.githubusercontent.com/kaixinguo360/BashScript/master/lnmp/nginx_site_config'

# 读取设置

read -p '您的网站域名: ' SERVER_NAME
read -s -p '请设置MySQL根密码: ' MYSQL_PASSWORD
echo ''

while true :
do
	read -r -p "跳过MySQL安全性增强脚本? [Y/n] " input

	case $input in
	    [yY][eE][sS]|[yY])
			break
            		;;

	    [nN][oO]|[nN])
	    		ENSURE_MYSQL='1'
            		break
            		;;

	    *)
		echo "Invalid input..."
		;;
	esac
done

while true :
do
	read -r -p "自动配置PHP以增强安全性? [Y/n] " input

	case $input in
	    [yY][eE][sS]|[yY])
			ENSURE_PHP='1'
			break
            ;;

	    [nN][oO]|[nN])
            break
            ;;

	    *)
		echo "Invalid input..."
		;;
	esac
done

while true :
do
	read -r -p "自动配置Nginx以使用PHP? [Y/n] " input

	case $input in
	    [yY][eE][sS]|[yY])
			ENSURE_NGINX='1'
			break
            ;;

	    [nN][oO]|[nN])
            break
            ;;

	    *)
		echo "Invalid input..."
		;;
	esac
done

# 更新apt
apt-get update

# 安装Nginx
apt-get install nginx -y

# 安装MySQL
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
apt-get install mysql-server -y
# 可选，配置MySQL(提升安全性)
if [ -n "$ENSURE_MYSQL" ]; then
mysql_secure_installation
fi

# 安装PHP
apt-get install php-fpm php-mysql -y
#修改php配置文件(提升安全性)
if [ -n "$ENSURE_PHP" ]; then
sed 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' ${PHP_CONF} -i
fi
# 重启php
systemctl restart php7.0-fpm

# 配置Nginx以使用PHP
if [ -n "$ENSURE_NGINX" ]; then
wget -O ${NGINX_CONF} ${NGINX_CONF_URL}
sed "s/TMP_SERVER_NAME/${SERVER_NAME}/g" ${NGINX_CONF} -i
systemctl restart nginx
else
echo '请手动配置Nginx以使用PHP'
echo '提示：'
echo '    1. index.php'
echo '    2. server_name'
echo '    3. php loaction'
echo '    4. ht location'
fi

# 测试安装结果
echo '<?php phpinfo();' > /var/www/html/info.php
echo '安装完成!'
echo "您可以打开 http://${SERVER_NAME}/info.php 来检查安装结果"
echo "(建议检查完后删除info.php以增强安全性)"

