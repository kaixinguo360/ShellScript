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
    echo -e "介绍: 自动备份脚本, 适用于用于:"
    echo -e "      WWW, MYSQL, CLOUD, MYHOME, ACME, MYCA, NGINX, PHP, MAIL, POST, DOVE"
    echo -e "用法: $0 [选项] [自定义的文件]"
    echo -e "选项:"
    echo -e "      -w --web          自动链接归档文件到默认WEB服务器根目录下"
    echo -e "      -a --all          备份适用的全部数据与配置"
    echo -e "      -p --passwd       MYSQL的ROOT密码, 用于导出整个数据库"
    echo -e "      -f --input-file   输入文件路径"
    echo -e "      -v --verbose      输出详细信息"
    echo -e "      -l --list         只检查并列出要被备份的文件"
    exit 0
fi

############
# 路径设置 #
############

# 备份文件夹路径
BACK_PATH="/tmp/backup/"
INPUT_FILE_PATH=${BACK_PATH}input

# 清空变量
WWW=""
MYSQL=""
CLOUD=""
MYHOME=""
ACME=""
MYCA=""
NGINX=""
PHP=""
MAIL=""
POST=""
DOVE=""


# 数据路径
WWW_PATH="/var/www/"
MYSQL_PATH="${BACK_PATH}mysql.sql"
CLOUD_PATH="/var/cloud/"
MYHOME_PATH="/home/"
ACME_PATH=`cd ~/.acme.sh/; pwd`
MYCA_PATH=`cd ~/.ca/; pwd`

# 配置路径
NGINX_PATH="/etc/nginx/"
PHP_PATH="/etc/php/"
POST_PATH="/etc/postfix/"
DOVE_PATH="/etc/dovecot/"


############
# 工具函数 #
############

section() {
    echo -e "\n$1\n---------------"
}

getBool() {
if [[ -z "$ALL" ]]; then
    eval BOOL=\$$1
    if [ -z "$BOOL" ];then
        if [ -z "$2" ];then
            TEXT="请输入"
        else
            TEXT="$2"
        fi
        while true :
        do
    	    read -r -p "$2 [Y/n] " input
    	    case $input in
    	        [yY][eE][sS]|[yY])
    	            BOOL='y'
    			    break
                    ;;
    
    	        [nN][oO]|[nN])
    	            BOOL='n'
                    break
                    ;;
        
    	        *)
    		    echo "Invalid input..."
    		    ;;
    	    esac
        done
        eval "$1=$BOOL"
        echo ""
    fi
else
    eval "$1='y'"
fi
}

log() {
    echo -e "$1" >> "${BACK_PATH}list"
    echo "$1"
}

addPath() {
    NAME=$1
    eval VALUE=\$${1}
    eval VALUE_PATH=\$${1}_PATH
    if [[ "$VALUE" == "y" ]]; then
        section "正在检查 $2"
        if [[ -d $VALUE_PATH || -f $VALUE_PATH ]];then
            log "$NAME $VALUE_PATH"
            BACKUP_PATH="$BACKUP_PATH $VALUE_PATH"
        else
            echo "指定目录($VALUE_PATH)不存在!"
        fi
        echo ""
    fi
}

addInputPath() {
    INPUT_PATH_TMP=$(readlink -f "$1")
    if [[ -d "$INPUT_PATH_TMP" || -f "$INPUT_PATH_TMP" ]]; then
        INPUT_PATH="$INPUT_PATH $INPUT_PATH_TMP"
        echo "读取自定义目录 $INPUT_PATH_TMP 成功!"
    else
        echo "自定义目录 $INPUT_PATH_TMP 不存在!"
        exit 1
    fi
}


############
# 读取输入 #
############

# 命令行读取输入参数
TEMP=`getopt \
    -o wap:vlf: \
--long web,all,passwd:,verbose,list,input-file: \
    -n "$0" -- "$@"`
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -w|--web)
            ENABLE_WEB='y'
            shift 1
            ;;
        -a|--all)
            ALL='y'
            shift 1
            ;;
        -p|--passwd)
            MYSQL_PASSWORD=$2
            shift 2
            ;;
        -f|--input-file)
            INPUT_FILE_PATH=$2
            shift 2
            ;;
        -v|--verbose)
            VERBOSE='v'
            shift 1
            ;;
        -l|--list)
            ONLY_LIST='y'
            ALL='y'
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
    addInputPath "$arg"
done

INPUT_FILE_PATH=$(readlink -f "$INPUT_FILE_PATH")
if [[ -f "$INPUT_FILE_PATH" ]]; then
    eval $(cat $INPUT_FILE_PATH | awk '{printf("addInputPath %s;",$0);}')
fi

if [[ -z "$ALL" ]]; then
    section "数据备份设置"
fi
getBool "WWW" "备份网站数据($WWW_PATH)?"
getBool "MYSQL" "备份MySQL数据库"
getBool "CLOUD" "备份NextCloud文件数据($CLOUD_PATH)"
getBool "MYHOME" "备份所有Home数据($MYHOME_PATH)"
if [[ "$MYHOME" == "n" ]]; then
    getBool "ACME" "备份acme.sh数据($ACME_PATH)?"
    getBool "MYCA" "备份MyCA数据($MYCA_PATH)?"
fi


if [[ -z "$ALL" ]]; then
    section "配置备份设置"
fi
getBool "NGINX" "备份Nginx配置($NGINX_PATH)?"
getBool "PHP" "备份PHP配置($PHP_PATH)?"
getBool "MAIL" "备份Mail(Postfix+Dovecot)配置(${POST_PATH}:${DOVE_PATH})?"


############
# 检查路径 #
############

echo -e "\n\n"
echo "############"
echo "# 检查路径 #"
echo "############"
echo -e "\n"

if [ ! -d "$BACK_PATH" ]; then
    echo "创建备份文件夹$BACK_PATH"
    mkdir -p "$BACK_PATH"
fi

addPath "WWW" "网站数据"
if [[ -n "$MYSQL" ]]; then
    mysqldump -uroot -p${MYSQL_PASSWORD} -xA > $MYSQL_PATH
    addPath "MYSQL" "Mysql数据库数据"
fi
addPath "CLOUD" "NextCloud云盘数据"
addPath "MYHOME" "Home目录数据"
addPath "ACME" "acme.sh数据"
addPath "MYCA" "MyCA数据"
addPath "NGINX" "Nginx配置"
addPath "PHP" "PHP配置"

# 备份MAIL
if [[ "$MAIL" == "y" || -n "$ALL" ]]; then
    POST_PATH="y"
    DOVE_PATH="y"
    addPath "POST" "Postfix配置"
    addPath "DOVE" "Dovecot配置"
fi

# 自定义路径
if [[ -n "$INPUT_PATH" ]]; then
    section "正在检查 自定义路径"
    echo "INPUT $INPUT_PATH"
fi

section "路径检查完毕"

# 若设定了-l参数则在此处退出
if [[ -n "$ONLY_LIST" ]]; then
    exit 0
fi

############
# 开始备份 #
############

if read -t 5 -p "备份将在5秒后开始, 按任意键取消..." INPUT 
then 
    echo "备份已被取消!" 
    exit 0
fi

echo -e "\n\n"
echo "############"
echo "# 开始备份 #"
echo "############"
echo -e "\n"

echo ""

CMD="tar -cz${VERBOSE}pf ${BACK_PATH}backup.tar.gz $BACKUP_PATH ${BACK_PATH}list"
if [ -n "$INPUT_PATH" ]; then
    echo -e "$INPUT_PATH" >> "${BACK_PATH}list_extra"
    CMD="$CMD  $INPUT_PATH ${BACK_PATH}list_extra"
fi

echo "正在运行如下命令:"
echo $CMD
echo ""

$CMD

echo "备份已完成! 归档文件保存在 ${BACK_PATH}backup.tar.gz"


############
# 创建链接 #
############

if [[ -n "$ENABLE_WEB" ]]; then
    ln -s ${BACK_PATH}backup.tar.gz ${WWW_PATH}html/backup.tar.gz
    echo "你现在可以通过默认的网页服务器访问 http://your_address/backup.tar.gz 来获取您的备份"
fi
