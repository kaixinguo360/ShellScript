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

############
# 帮助信息 #
############

# 读取参数
if [[ $1 = "-h" || $1 = "--help" ]];then
    echo -e "介绍: 自动恢复脚本, 适用于用于:"
    echo -e "      WWW, MYSQL, CLOUD, MYHOME, ACME, MYCA, NGINX, PHP, MAIL, POST, DOVE"
    echo -e "用法: $0 [选项]"
    echo -e "选项:"
    echo -e "      -f --file         备份归档文件路径"
    echo -e "      -u --url          备份归档文件URl"
    echo -e "      -r --remove       直接删除冲突的文件"
    echo -e "      -c --copy         先复制归档文件到/tmp目录, 避免被-r选项删除"
    echo -e "      -p --passwd       MYSQL的ROOT密码, 用于导入整个数据库"
    exit 0
fi

############
# 工具函数 #
############

rmPath() {
if [[ -n "$1" && "$1" != "/" && -d "$1" ]]; then
    echo "删除目录 $1"
    rm -rf $1
fi
}


############
# 路径设置 #
############

# 命令行读取输入参数
TEMP=`getopt \
    -o f:u:rcp: \
--long file:,url:,remove,copy,passwd: \
    -n "$0" -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -f|--file)
            FILE=$2
            shift 2
            ;;
        -u|--url)
            URL=$2
            shift 2
            ;;
        -r|--remove)
            ENABLE_REMOVE='y'
            shift 1
            ;;
        -c|--copy)
            ENABLE_COPY='y'
            shift 1
            ;;
        -p|--passwd)
            MYSQL_PASSWORD=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

for arg do
   echo "非法参数'$arg'" ;
   exit 1
done

if [[ -z "$URL" && -z "$FILE" ]];then
    echo "请指定文件或URL!";
    exit 1
fi


############
# 下载备份 #
############

if [ -n "$URL" ];then
    if [ -z "$FILE" ];then
        FILE="/tmp/backup/backup.tar.gz"
    fi
    wget -O "$FILE" "$URL" || echo "下载失败!"; exit 1
fi

if [[ $FILE != "/tmp/backup/backup.tar.gz" && -n "$ENABLE_COPY" ]]; then
    cp $FILE "/tmp/backup/backup.tar.gz"
    FILE="/tmp/backup/backup.tar.gz"
fi
    

############
# 还原备份 #
############

# 读取配置文件

WWW_PATH=""
MYSQL_PATH=""
CLOUD_PATH=""
MYHOME_PATH=""
ACME_PATH=""
MYCA_PATH=""
NGINX_PATH=""
PHP_PATH=""
POST_PATH=""
DOVE_PATH=""

LIST_PATH="tmp/backup/list"
tar -zxpf $FILE $LIST_PATH -C /
eval $(cat /$LIST_PATH | awk '{printf("%s_PATH=%s;",$1,$2);}')

if [[ -n "$ENABLE_REMOVE" ]]; then
    echo "正在删除将被覆盖的文件..."
    rmPath "$WWW_PATH"
    rmPath "$MYSQL_PATH"
    rmPath "$CLOUD_PATH"
    rmPath "$MYHOME_PATH"
    rmPath "$ACME_PATH"
    rmPath "$MYCA_PATH"
    rmPath "$NGINX_PATH"
    rmPath "$PHP_PATH"
    rmPath "$POST_PATH"
    rmPath "$DOVE_PATH"
fi

if [[ -n "$WWW_PATH" ]]; then
    echo "找到 WWW 备份"
fi
if [[ -n "$MYSQL_PATH" ]]; then
    echo "找到 MYSQL 备份"
    # 安装MySQL
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASSWORD"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
    apt-get install mysql-server -y
fi
if [[ -n "$CLOUD_PATH" ]]; then
    echo "找到 CLOUD 备份"
fi
if [[ -n "$MYHOME_PATH" ]]; then
    echo "找到 MYHOME 备份"
fi
if [[ -n "$ACME_PATH" ]]; then
    echo "找到 ACME 备份"
fi
if [[ -n "$MYCA_PATH" ]]; then
    echo "找到 MYCA 备份"
fi
if [[ -n "$NGINX_PATH" ]]; then
    echo "找到 NGINX 备份"
    if [[ -z `dpkg -l|grep nginx-full` ]]; then
        echo "nginx-full 未安装!"
        if [[ -z `dpkg -l|grep nginx-core` ]]; then
            echo "nginx-core 未安装!"
            apt install -y nginx
        fi
        apt remove -y nginx-core
    fi
fi
if [[ -n "$PHP_PATH" ]]; then
    echo "找到 PHP 备份"
    if [[ -z `dpkg -l|grep php-fpm` ]]; then
        apt-get install php-fpm php-mysql -y
    fi
fi
if [[ -n "$POST_PATH" ]]; then
    echo "找到 POST 备份"
fi
if [[ -n "$DOVE_PATH" ]]; then
    echo "找到 DOVE 备份"
fi

echo "正在解压归档文件..."
tar -zxpvf $FILE -C /

if [[ -n "$WWW_PATH" ]]; then
fi
if [[ -n "$MYSQL_PATH" ]]; then
    mysql -uroot -p${MYSQL_PASSWORD} < $MYSQL_PATH
fi
if [[ -n "$CLOUD_PATH" ]]; then
fi
if [[ -n "$MYHOME_PATH" ]]; then
fi
if [[ -n "$ACME_PATH" ]]; then
fi
if [[ -n "$MYCA_PATH" ]]; then
fi
if [[ -n "$NGINX_PATH" ]]; then
fi
if [[ -n "$PHP_PATH" ]]; then
fi
if [[ -n "$POST_PATH" ]]; then
fi
if [[ -n "$DOVE_PATH" ]]; then
fi

exit 0
