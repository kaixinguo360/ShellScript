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

# 设置静态变量
P_CF_MASTER="/etc/postfix/master.cf"


# 交互式读取参数
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

## 安装Postfix ##
echo "postfix postfix/mailname string kaixinguo.site" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt install -y postfix

# 配置Postfix

#main.cf
PC="postconf -e"
$PC myhostname=${MAIL_NAME}
$PC mydomain=${SERVER_NAME}
$PC myorigin=${SERVER_NAME}
$PC home_mailbox=Maildir/
$PC mailbox_command=''
$PC smtpd_sasl_type=dovecot
$PC smtpd_sasl_path=private/auth
$PC smtpd_sasl_auth_enable=yes
$PC mydestination="${SERVER_NAME}, \$myhostname, ${MAIL_NAME}, localhost.${SERVER_NAME}, localhost"

#master.cf
sed -i "s/#submission inet /submission inet /g" ${P_CF_MASTER}
sed -i "s/#  -o syslog_name/  -o syslog_name/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_tls_s/  -o smtpd_tls_s/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_sasl_/  -o smtpd_sasl_/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_rejec/  -o smtpd_rejec/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_clien/  -o smtpd_clien/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_helo_/  -o smtpd_helo_/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_sende/  -o smtpd_sende/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_recip/  -o smtpd_recip/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_relay/  -o smtpd_relay/g" ${P_CF_MASTER}
sed -i "s/#  -o milter_macr/  -o milter_macr/g" ${P_CF_MASTER}
sed -i "s/#smtps     inet  /smtps     inet  /g" ${P_CF_MASTER}
sed -i "s/#  -o syslog_name/  -o syslog_name/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_tls_w/  -o smtpd_tls_w/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_sasl_/  -o smtpd_sasl_/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_rejec/  -o smtpd_rejec/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_clien/  -o smtpd_clien/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_helo_/  -o smtpd_helo_/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_sende/  -o smtpd_sende/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_recip/  -o smtpd_recip/g" ${P_CF_MASTER}
sed -i "s/#  -o smtpd_relay/  -o smtpd_relay/g" ${P_CF_MASTER}
sed -i "s/#  -o milter_macr/  -o milter_macr/g" ${P_CF_MASTER}

cat >> ${P_CF_MASTER} << HERE
dovecot   unix  -       n       n       -       -       pipe
  flags=DRhu user=email:email argv=/usr/lib/dovecot/deliver -f ${sender} -d ${recipient}
HERE


## 安装Dovecot ##
sudo apt-get install dovecot-common dovecot-imapd
















