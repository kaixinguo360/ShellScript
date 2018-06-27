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
    echo -e "      -m --move         先移动归档文件到/tmp/backup目录, 避免被-r选项删除"
    echo -e "      -p --passwd       MYSQL的ROOT密码, 用于导入整个数据库"
    echo -e "      -v --verbose      输出详细信息"
    echo -e "      -i --install      只安装缺少的包"
    echo -e "      -l --list         列出归档文件的内容"
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
    -o f:u:rmp:vil \
--long file:,url:,remove,move,passwd:,install,list \
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
        -m|--move)
            ENABLE_COPY='y'
            shift 1
            ;;
        -p|--passwd)
            MYSQL_PASSWORD=$2
            shift 2
            ;;
        -v|--verbose)
            VERBOSE='v'
            shift 1
            ;;
        -i|--install)
            ONLY_INSTALL='y'
            shift 1
            ;;
        -l|--list)
            ONLY_LIST='y'
            shift 1
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
    mkdir -p /tmp/backup/
    mv $FILE "/tmp/backup/backup.tar.gz"
    if [[ -f "/tmp/backup/backup.tar.gz" ]]; then
        FILE="/tmp/backup/backup.tar.gz"
    else
        echo "移动文件出错!"
        exit 1
    fi
fi
    

############
# 还原备份 #
############

# 清空变量
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

# 读取配置文件
LIST_PATH="tmp/backup/list"
tar -zxpf $FILE -C / $LIST_PATH
eval $(cat /$LIST_PATH | awk '{printf("%s_PATH=%s;",$1,$2);}')

# 列出归档文件清单
echo "归档内的内容:"
echo "WWW_PATH: $WWW_PATH"
echo "MYSQL_PATH: $MYSQL_PATH"
echo "CLOUD_PATH: $CLOUD_PATH"
echo "MYHOME_PATH: $MYHOME_PATH"
echo "ACME_PATH: $ACME_PATH"
echo "MYCA_PATH: $MYCA_PATH"
echo "NGINX_PATH: $NGINX_PATH"
echo "PHP_PATH: $PHP_PATH"
echo "POST_PATH: $POST_PATH"
echo "DOVE_PATH: $DOVE_PATH"
echo "可能还会有用户添加的其他文件..."

# 若设定了-l参数则在此处退出
if [[ -n "$ONLY_LIST" ]]; then
    exit 0
fi

# 若设定了-r参数则删除列出的文件
if [[ -n "$ENABLE_REMOVE" && -z "$ONLY_INSTALL" ]]; then
    if read -t 5 -p "将在5秒后删除以上列出的文件, 按任意键取消..." INPUT 
    then 
        echo "恢复已被取消!" 
        exit 0
    fi
    echo ""
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

# 安装缺失的软件
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

# 若设定了-i参数则在此处退出
if [[ -n "$ONLY_INSTALL" ]]; then
    exit 0
fi

# 解压归档文件
echo "正在解压归档文件..."
tar -zxp${VERBOSE}f $FILE -C /

# 导入MySQL数据库
if [[ -n "$MYSQL_PATH" ]]; then
    mysql -uroot -p${MYSQL_PASSWORD} < $MYSQL_PATH
fi

exit 0
