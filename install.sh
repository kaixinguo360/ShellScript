#!/usr/bin/expect 

# 设置静态参数
set timeout -1

set lnmp_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/lnmp/lnmp.sh"
set wp_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/wp/wp.sh"
set rewrite_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/rewrite/rewrite.sh"

set host [lindex $argv 0]
set sql_root_pw [lindex $argv 1]
set sql_wp_user [lindex $argv 2]
set sql_wp_pw [lindex $argv 3]

# 读取命令行参数
if { $argc < 4 } {
    send_user "用法: $argv0 网站域名\n"
    send_user "                   MySQL根密码\n"
    send_user "                   WP数据库用户名\n"
    send_user "                   WP数据库密码\n"
    exit
}

# 读取用户输入

while {true} {
    puts "安装LNMP? \[Y/n\]: "
    gets stdin input
    switch -regexp $input {
        [yY][eE][sS]|[yY] {
            set is_lnmp true
            break;
        }
        [nN][oO]|[nN] {
            set is_lnmp false
            break;
        }
        default {}
    }
}

if {$is_lnmp} {
    while {true} {
        puts "安装WordPress? \[Y/n\]: "
        gets stdin input
        switch -regexp $input {
            [yY][eE][sS]|[yY] {
                set is_wp true
                break;
            }
            [nN][oO]|[nN] {
                set is_wp false
                break;
            }
            default {}
        }
    }
} else {
    set is_wp false
}

if {$is_lnmp} {
    while {true} {
        puts "重定向未绑定的域名访问? \[Y/n\]: "
        gets stdin input
        switch -regexp $input {
            [yY][eE][sS]|[yY] {
                set is_rewrite true
                break;
            }
            [nN][oO]|[nN] {
                set is_rewrite false
                break;
            }
            default {}
        }
    }
} else {
    set is_rewrite false
}

if {$is_lnmp} {
    # 下载lnmp.sh
    spawn wget -O lnmp.sh $lnmp_url
    expect eof
    spawn chmod +x lnmp.sh
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
    # 删除脚本
    spawn rm -f lnmp.sh
    expect eof
}

if {$is_wp} {
    # 下载wp.sh
    spawn wget -O wp.sh $wp_url
    expect eof
    spawn chmod +x wp.sh
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
    # 删除脚本
    spawn rm -f wp.sh
    expect eof
}

if {$is_rewrite} {
    # 下载rewrite.sh
    spawn wget -O rewrite.sh $rewrite_url
    expect eof
    spawn chmod +x rewrite.sh
    expect eof
    # 运行wp.sh
    spawn ./rewrite.sh
    expect "*网站域名*"
    send "$host\r"
    expect eof
    # 删除脚本
    spawn rm -f rewrite.sh
    expect eof
}
