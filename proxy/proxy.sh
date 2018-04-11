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
DEFAULT_CLIENT_CERT="${HOME}/.ca/cacert.pem"

# 读取用户输入
read -p '您的网站域名: ' SERVER_NAME
read -p '您的目标网站域名: ' TARGET_NAME

SITE_NAME="${TARGET_NAME}"
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

while true :
do
	read -r -p "使用 acme.sh/自签名/系统自带snakeoil 证书? [Y/s/n] " input
	case $input in
	    [yY][eE][sS]|[yY])
	                SSL_TYPE="y"
			break
            		;;

	    [sS][eE][lL][fF]|[sS])
	                SSL_TYPE="s"
            		break
            		;;

	    [nN][oO]|[nN])
	                SSL_TYPE="n"
            		break
            		;;

	    *)
		echo "Invalid input..."
		;;
	esac
done

while true :
do
	read -r -p "使用客户端验证? [Y/n] " input
	case $input in
	    [yY][eE][sS]|[yY])
	                SSL_CLIENT="y"
			break
            		;;

	    [nN][oO]|[nN])
	                SSL_CLIENT="n"
            		break
            		;;

	    *)
		echo "Invalid input..."
		;;
	esac
done

while true :
do
	read -r -p "开启Cookies? [Y/n] " input

	case $input in
	    [yY][eE][sS]|[yY])
	    		ENABLE_COOKIES="y"
			break
            		;;

	    [nN][oO]|[nN])
	    		ENABLE_COOKIES="n"
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
HAS_PROXY=$(sed -n "/include my\/proxy\/\*;/p" ${NGINX_CONF}include)
fi
if [ "${HAS_PROXY}" = "" ]; then
mkdir -p ${MY_CONF}proxy
cat >> ${NGINX_CONF}include << HERE
include my/proxy/*;
HERE
fi

# 运行new_site.sh
wget -O new_site.sh ${NEW_SITE_URL}
chmod +x new_site.sh
./new_site.sh -n ${SERVER_NAME} -c ${SITE_NAME} -r ./tmp_proxy -s ${SSL_TYPE}

# 删除无用临时文件
rm -rf new_site.sh
rm -rf /etc/nginx/sites-enabled/${SITE_NAME}
rm -rf /etc/nginx/my/${SITE_NAME}
rm -rf tmp_proxy

# 下载配置文件
wget -O ${MY_CONF}proxy/${SITE_NAME} ${PROXY_CONF_URL}

# 修改配置文件
sed -i "s/TMP_SERVER_NAME/${SERVER_NAME}/g" ${MY_CONF}proxy/${SITE_NAME}
sed -i "s/TMP_TARGET_NAME/${TARGET_NAME}/g" ${MY_CONF}proxy/${SITE_NAME}

# 添加subs_filter设置
mkdir -p ${MY_CONF}proxy_ext/subs_filter
cat > ${MY_CONF}proxy_ext/subs_filter/${SITE_NAME} << HERE
subs_filter ${TARGET_NAME} ${SERVER_NAME};
HERE

# 如果使用系统自带snakeoil证书
if [ "${SSL_TYPE}" = "n" ]; then
sed -i "s/\/etc\/nginx\/ssl\/${SERVER_NAME}.crt/\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/g" ${MY_CONF}proxy/${SITE_NAME}
sed -i "s/\/etc\/nginx\/ssl\/${SERVER_NAME}.key/\/etc\/ssl\/private\/ssl-cert-snakeoil.key/g" ${MY_CONF}proxy/${SITE_NAME}
fi

# 如果使用客户端证书
if [ "${SSL_CLIENT}" = "y" ]; then
sed -i "s#TMP_CLIENT_CERT_PATH#${DEFAULT_CLIENT_CERT}#g" ${MY_CONF}proxy/${SITE_NAME}
sed -i "s/#ssl_client_certificate/ssl_client_certificate/g" ${MY_CONF}proxy/${SITE_NAME}
sed -i "s/#ssl_verify_client/ssl_verify_client/g" ${MY_CONF}proxy/${SITE_NAME}
fi

# 如果开启Cooikes
if [ "${ENABLE_COOKIES}" = "y" ]; then
sed -i "s/proxy_set_header Cookie/#proxy_set_header Cookie/g" ${MY_CONF}proxy/${SITE_NAME}
fi

# 重启Nginx服务器
service nginx restart

# 完成设置
echo -e "\n  ## 对 ${TARGET_NAME} 的反向代理设置完成 ##"
echo -e "   您可以通过 http://${SERVER_NAME}/ 查看设置结果\n"
