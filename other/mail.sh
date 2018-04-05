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

## 初始化安装 ##

# 设置变量

# 读取参数
read -p '您的根域名: ' SERVER_NAME
read -p '您的邮件域名: ' MAIL_NAME
while true :
do
	read -r -p "安装Postfix? [Y/n] " input
	case $input in
	    [yY][eE][sS]|[yY])
                IS_P='1'
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
	read -r -p "安装Dovecot? [Y/n] " input
	case $input in
	    [yY][eE][sS]|[yY])
                IS_D='1'
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
	read -r -p "安装RainLoop? [Y/n] " input
	case $input in
	    [yY][eE][sS]|[yY])
                IS_RL='1'
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

## 正式安装开始 ##

# 更新apt
#apt update

# 安装Postfix
echo "postfix postfix/mailname string kaixinguo.site" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt install -y postfix

# 配置Postfix
PC="postconf -e"
$PC myhostname=${MAIL_NAME}
$PC mydomain=${SERVER_NAME}
$PC myorigin=${SERVER_NAME}
$PC home_mailbox=Maildir/
$PC mailbox_command=''
$PC smtpd_sasl_type=dovecot
$PC smtpd_sasl_path=private/auth
$PC smtpd_sasl_auth_enable=yes




















