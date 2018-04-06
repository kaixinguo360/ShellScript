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
NEW_SITE_URL="https://raw.githubusercontent.com/kaixinguo360/BashScript/master/other/new_site.sh"


# 交互式读取参数
read -p '您的根域名: ' SERVER_NAME
MAIL_NAME="mail.${SERVER_NAME}"
while true :
do
	read -r -p "使用默认邮件域名(${MAIL_NAME})? [Y/n] " input
	case $input in
	    [yY][eE][sS]|[yY])
			break
            		;;

	    [nN][oO]|[nN])
			read -p '设置自定义邮件域名: ' MAIL_NAME
			echo -e "已设置自定义邮件域名(${MAIL_NAME})"
            		break
            		;;

	    *)
		echo "Invalid input..."
		;;
	esac
done

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


#################
## 安装Postfix ##
#################

if [ -n "${IS_P}" ];then

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

# 重启Postfix
service postfix restart

echo -e "\n  ## Postfix安装完成! ##\n"

fi

#################
## 安装Dovecot ##
#################

if [ -n "${IS_D}" ];then

sudo apt-get install dovecot-common dovecot-imapd -y

# 配置Dovecot

#10-ssl.conf
D_SSL_CF="/etc/dovecot/conf.d/10-ssl.conf"
#sed -i "s/ssl = on/ssl = required/" ${D_SSL_CF}
sed -i "s/#ssl_cert = <\/etc\/dovecot\/dovecot.pem/ssl_cert = <\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/" ${D_SSL_CF}
sed -i "s/#ssl_key = <\/etc\/dovecot\/private\/dovecot.pem/ssl_key = <\/etc\/ssl\/private\/ssl-cert-snakeoil.key/" ${D_SSL_CF}

#10-auth.conf
D_AUTH_CF="/etc/dovecot/conf.d/10-auth.conf"
sed -i "s/#disable_plaintext_auth = yes/disable_plaintext_auth = no/g" ${D_AUTH_CF}

#10-mail.conf
D_MAIL_CF="/etc/dovecot/conf.d/10-mail.conf"
sed -i "s/mail_location = mbox:~\/mail:INBOX=\/var\/mail\/%u/mail_location = maildir:~\/Maildir/g" ${D_MAIL_CF}


#10-master.conf
D_MASTER_CF="/etc/dovecot/conf.d/10-master.conf"
cat > ${D_MASTER_CF} << HERE
#default_process_limit = 100
#default_client_limit = 1000

# Default VSZ (virtual memory size) limit for service processes. This is mainly
# intended to catch and kill processes that leak memory before they eat up
# everything.
#default_vsz_limit = 256M

# Login user is internally used by login processes. This is the most untrusted
# user in Dovecot system. It shouldn't have access to anything at all.
#default_login_user = dovenull

# Internal user is used by unprivileged processes. It should be separate from
# login user, so that login processes can't disturb other processes.
#default_internal_user = dovecot

service imap-login {
  inet_listener imap {
    #port = 143
  }
  inet_listener imaps {
    #port = 993
    #ssl = yes
  }

  # Number of connections to handle before starting a new process. Typically
  # the only useful values are 0 (unlimited) or 1. 1 is more secure, but 0
  # is faster. <doc/wiki/LoginProcess.txt>
  #service_count = 1

  # Number of processes to always keep waiting for more connections.
  #process_min_avail = 0

  # If you set service_count=0, you probably need to grow this.
  #vsz_limit = \$default_vsz_limit
}

service pop3-login {
  inet_listener pop3 {
    #port = 110
  }
  inet_listener pop3s {
    #port = 995
    #ssl = yes
  }
}

service lmtp {
  unix_listener lmtp {
    #mode = 0666
  }

  # Create inet listener only if you can't use the above UNIX socket
  #inet_listener lmtp {
    # Avoid making LMTP visible for the entire internet
    #address =
    #port = 
  #}
}

service imap {
  # Most of the memory goes to mmap()ing files. You may need to increase this
  # limit if you have huge mailboxes.
  #vsz_limit = \$default_vsz_limit

  # Max. number of IMAP processes (connections)
  #process_limit = 1024
}

service pop3 {
  # Max. number of POP3 processes (connections)
  #process_limit = 1024
}

service auth {
  # auth_socket_path points to this userdb socket by default. It's typically
  # used by dovecot-lda, doveadm, possibly imap process, etc. Users that have
  # full permissions to this socket are able to get a list of all usernames and
  # get the results of everyone's userdb lookups.
  #
  # The default 0666 mode allows anyone to connect to the socket, but the
  # userdb lookups will succeed only if the userdb returns an "uid" field that
  # matches the caller process's UID. Also if caller's uid or gid matches the
  # socket's uid or gid the lookup succeeds. Anything else causes a failure.
  #
  # To give the caller full permissions to lookup all users, set the mode to
  # something else than 0666 and Dovecot lets the kernel enforce the
  # permissions (e.g. 0777 allows everyone full permissions).
  #unix_listener auth-userdb {
    #mode = 0666
    #user = 
    #group = 
  #}

  # Postfix smtp-auth
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }

  # Auth process is run as this user.
  #user = \$default_internal_user
}

service auth-worker {
  # Auth worker process is run as root by default, so that it can access
  # /etc/shadow. If this isn't necessary, the user should be changed to
  # \$default_internal_user.
  #user = root
}

service dict {
  # If dict proxy is used, mail processes should have access to its socket.
  # For example: mode=0660, group=vmail and global mail_access_groups=vmail
  unix_listener dict {
    #mode = 0600
    #user = 
    #group = 
  }
}
HERE

# 重启Dovecot
service dovecot restart

echo -e "\n  ## Dovecot安装完成! ##\n"

fi


##################
## 安装RainLoop ##
##################

if [ -n "${IS_RL}" ];then

echo -e "\n RainLoop功能并不稳定...\n"

wget -O new_site.sh ${NEW_SITE_URL}
chmod +x new_site.sh

expect << HERE
  spawn ./new_site.sh
  
  expect "*本地配置文件名*"
  send "rainloop\r"
  
  expect "*默认根目录*"
  send "y\r"
  
  expect "*监听端口*"
  send "801\r"
  
  expect "*域名*"
  send "${MAIL_NAME}\r"
  
  expect "*启用SSL*"
  send "n\r"
  
  expect eof
HERE

rm -rf new_site.sh

wget -O tmp_rainloop.zip https://www.rainloop.net/repository/webmail/rainloop-community-latest.zip
mkdir tmp_rainloop
unzip -d tmp_rainloop tmp_rainloop.zip
cp -a tmp_rainloop/. /var/www/rainloop/
chown -R www-data:www-data /var/www/rainloop/
rm -rf tmp_rainloop tmp_rainloop.zip

echo -e "\n  ## RainLoop安装完成 ##"
echo -e "   您可以通过 http://${MAIL_NAME}/ 访问RainLoop\n"

fi








