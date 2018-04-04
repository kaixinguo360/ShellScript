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
SITE_CONF='/etc/nginx/sites-enabled/default'
MY_CONF='/etc/nginx/my/default/'

# 读取参数

read -p '您的网站域名: ' SERVER_NAME

while true :
do
	read -p 'V2Ray端口号: ' V_PORT
	case ${V_PORT} in
	    [0-9]*)
			break
            ;;
	    *)
		    echo -e "请输入数字...\n"
		    ;;
	esac
done

while true :
do
    read -p 'WS路径: /' WS_PATH
    if [ -n "${WS_PATH}" ]; then
        break
    fi
    echo -e "不能为空!\n"
done


# 正式安装开始

# 初始化Nginx-MY配置环境
if [ ! -e ${MY_CONF} ]; then
    mkdir -p ${MY_CONF}
    sed "s/#include snippets\/snakeoil.conf;/include my\/default\/\*;/g" ${SITE_CONF} -i
fi

# 增加Nginx-MY配置文件 - v2ray.conf
cat > ${MY_CONF}v2ray.conf << HERE
location /${WS_PATH} {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$V_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
}
HERE

# 重启Nginx
service nginx restart

# 配置V2Ray
#...



