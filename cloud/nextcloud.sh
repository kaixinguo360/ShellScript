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
NC_URL='https://download.nextcloud.com/server/releases/nextcloud-13.0.1.zip'
NGINX_CONF='/etc/nginx/sites-enabled/'
SITE_CONF='https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/cloud/nginx_site_conf'
NEW_SITE_URL="https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/other/new_site.sh"

# 读取用户输入
read -p '您的网站域名: ' SERVER_NAME

while true :
do
    read -r -p "创建新的MySQL用户? [Y/n] " input

    case $input in
        [yY][eE][sS]|[yY])
            CREATE_USER='1'
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

if [ -n "${CREATE_USER}" ];then
read -p '请输入MySQL根用户密码(!务必正确!): ' MYSQL_PW
read -p '请设置新的MySQL用户名: ' MYSQL_USER
while true :
do
    read -s -p "请设置MySQL用户 ${MYSQL_USER} 的密码: " MYSQL_PASSWORD_1
    echo ''
    read -s -p '再输一遍: ' MYSQL_PASSWORD_2
    echo ''
    if [ "${MYSQL_PASSWORD_1}" = "${MYSQL_PASSWORD_2}" ]; then
        MYSQL_PW=${MYSQL_PASSWORD_1}
        break
    else
        echo -e "两次输入密码不一致!\n"
    fi
done
fi

## 正式安装开始 ##

# 下载安装NextCloud
wget -O tmp_nextcloud.zip ${NC_URL}
mkdir tmp_nextcloud
unzip -d tmp_nextcloud tmp_nextcloud.zip
mkdir -p /var/www/nextcloud
cp -a tmp_nextcloud/nextcloud/. /var/www/nextcloud/
chown -R www-data:www-data /var/www/nextcloud/
rm -rf tmp_nextcloud tmp_nextcloud.zip

# 创建数据目录
mkdir -p /var/cloud/data
chown -R www-data:www-data /var/cloud/data

# 安装PHP扩展插件
#apt-get install libapache2-mod-php7.0 -y
apt-get install php7.0-gd php7.0-json php7.0-mysql php7.0-curl php7.0-mbstring -y
apt-get install php7.0-intl php7.0-mcrypt php-imagick php7.0-xml php7.0-zip -y
systemctl restart php7.0-fpm


## 配置Nginx ##

# 创建新的网站
wget -O new_site.sh ${NEW_SITE_URL}
chmod +x new_site.sh

expect << HERE
  spawn ./new_site.sh
  
  expect "*本地配置文件名*"
  send "nextcloud\r"
  
  expect "*默认根目录*"
  send "y\r"
  
  expect "*域名*"
  send "${SERVER_NAME}\r"
  
  expect "*启用SSL*"
  send "y\r"
  
  expect eof
HERE

rm -rf new_site.sh

# 下载配置文件
wget -O ${NGINX_CONF}nextcloud ${SITE_CONF}

# 修改配置文件
sed -i "s/TMP_SERVER_NAME/${SERVER_NAME}/g" ${NGINX_CONF}nextcloud
sed -i "s/SITE_NAME/nextcloud/g" ${NGINX_CONF}nextcloud

# 重启Nginx
service nginx restart


## 创建MySQL用户 ##

if [ -n "${CREATE_USER}" ];then

# 数据库操作
MYSQL_SHORTCUT="mysql -u root -p${MYSQL_PW} -e"
# 创建数据库
${MYSQL_SHORTCUT} "CREATE DATABASE oc DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
# 创建WP用户
${MYSQL_SHORTCUT} "GRANT ALL ON oc.* TO '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PW}';"
# 刷新特权, 令MySQL知道最近的改变:
${MYSQL_SHORTCUT} "FLUSH PRIVILEGES;"

fi

echo -e "\n  ## NextCloud安装完成 ##"
echo -e "   您可以通过 http://${SERVER_NAME}/ 访问NextCloud\n"


















