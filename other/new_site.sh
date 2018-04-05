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
NGINX_CONF='/etc/nginx/sites-enabled/'
MY_CONF='/etc/nginx/my/'

# 读取参数
read -p '新网站的本地配置文件名: ' SITE_NAME
read -p '新网站的根目录: ' SITE_ROOT
read -p '新网站的本地监听端口: ' SITE_PORT
read -p '新网站的域名: ' HOST_NAME

# 新建配置文件
cat > ${NGINX_CONF}${SITE_NAME} << HERE
server {
	listen 80;
	listen [::]:80;

	# MY config dir
	include my/${SITE_NAME}/*;

	root ${SITE_ROOT};

	# Add index.php to the list if you are using PHP
	index index.php index.html index.htm index.nginx-debian.html;

	server_name ${HOST_NAME};

	client_max_body_size 20m;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		#try_files $uri $uri/ =404;
        try_files $uri $uri/ /index.php$is_args$args;
	}

	# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
	#
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
	
		# With php7.0-cgi alone:
		#fastcgi_pass 127.0.0.1:9000;
		# With php7.0-fpm:
		fastcgi_pass unix:/run/php/php7.0-fpm.sock;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	location ~ /\.ht {
		deny all;
	}
	
	# for wordpress
	location = /favicon.ico { log_not_found off; access_log off; }
	location = /robots.txt { log_not_found off; access_log off; allow all; }
	location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
		expires max;
		log_not_found off;
    }
}
HERE

# 新建MY配置文件夹
mkdir -p ${MY_CONF}${SITE_NAME}

# 重启Server
service nginx restart

