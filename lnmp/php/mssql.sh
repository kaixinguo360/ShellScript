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
PHP_CONF='/etc/php/7.0/fpm/php.ini'

## 正式安装开始 ##
apt-get update

# 安装完整php
apt install -y php7.0 php7.0-dev php7.0-xml php-pear

# 安装 Linux 和 macOS 上的 Microsoft ODBC Driver for SQL Server
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add 
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update
sudo ACCEPT_EULA=Y apt-get install msodbcsql17
sudo ACCEPT_EULA=Y apt-get install mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install unixodbc-dev

# 安装php插件
pecl install sqlsrv
pecl install pdo_sqlsrv
echo extension=pdo_sqlsrv.so >> /etc/php/7.0/fpm/conf.d/30-pdo_sqlsrv.ini
echo extension=sqlsrv.so >> /etc/php/7.0/fpm/conf.d/20-sqlsrv.ini

# 重启php
service php7.0-fpm restart
