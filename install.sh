#!/usr/bin/expect 

# 读取参数
if { $argc < 4 } {
    send_user "用法: $argv0 网站域名\n"
    send_user "                   MySQL根密码\n"
    send_user "                   WP数据库用户名\n"
    send_user "                   WP数据库密码\n"
    exit
}

set timeout -1

set lnmp_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/lnmp/lnmp.sh"
set wp_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/wp/wp.sh"

set host [lindex $argv 0]
set sql_root_pw [lindex $argv 1]
set sql_wp_user [lindex $argv 2]
set sql_wp_pw [lindex $argv 3]

# 下载lnmp.sh
spawn wget -O lnmp.sh $lnmp_url
expect eof

# 下载wp.sh
spawn wget -O wp.sh $wp_url
expect eof

# 增加执行权限
spawn chmod +x wp.sh lnmp.sh
expect eof

# 运行lnmp.sh
spawn ./lnmp.sh
expect "*网站域名*"
send "$host\r"
expect "*MySQL根密码*"
send "$sql_root_pw\r"
expect "*再输*"
send "$sql_root_pw\r"
expect "*跳过MySQL*"
send "y\r"
expect eof

# 运行wp.sh
spawn ./wp.sh
expect "*网站域名*"
send "$host\r"
expect "*MySQL根密码*"
send "$sql_root_pw\r"
expect "*WP数据库用户名*"
send "$sql_wp_user\r"
expect "*WP数据库密码*"
send "$sql_wp_pw\r"
expect "*再输*"
send "$sql_wp_pw\r"
expect eof

