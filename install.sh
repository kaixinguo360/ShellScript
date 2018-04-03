#!/usr/bin/expect 

# 设置静态参数
set timeout -1

set lnmp_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/lnmp/lnmp.sh"
set wp_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/wp/wp.sh"
set rewrite_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/rewrite/rewrite.sh"
set v2ray_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/v2ray/v2ray.sh"
set bbr_url "https://raw.githubusercontent.com/kaixinguo360/BashScript/master/brr/bbr.sh"

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

# 工具函数
proc readin {text} {
    while {true} {
        puts $text
        gets stdin input
        switch -regexp $input {
            [yY][eE][sS]|[yY] {
                set read_in true
                break;
            }
            [nN][oO]|[nN] {
                set read_in false
                break;
            }
            default {}
        }
    }
    return $read_in
}

# 读取用户输入
set is_lnmp [readin "安装LNMP? \[Y/n\]: "]

if {$is_lnmp} {
    set is_wp [readin "安装WordPress? \[Y/n\]: "]
} else {
    set is_wp false
}

if {$is_lnmp} {
    set is_rewrite [readin "重定向未绑定的域名访问? \[Y/n\]: "]
} else {
    set is_rewrite false
}

set is_v2ray [readin "安装V2Ray.fun? \[Y/n\]: "]

set is_bbr [readin "安装BBR? \[Y/n\]: "]


# 安装程序正式开始

if {$is_lnmp} {
    # 下载.sh
    spawn wget -O lnmp.sh $lnmp_url
    expect eof
    spawn chmod +x lnmp.sh
    expect eof
    # 运行.sh
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
    # 下载.sh
    spawn wget -O wp.sh $wp_url
    expect eof
    spawn chmod +x wp.sh
    expect eof
    # 运行.sh
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
    # 运行.sh
    spawn ./rewrite.sh
    expect "*网站域名*"
    send "$host\r"
    expect eof
    # 删除脚本
    spawn rm -f rewrite.sh
    expect eof
}

if {$is_v2ray} {
    # 下载.sh
    spawn wget -O v2ray.sh $v2ray_url
    expect eof
    spawn chmod +x v2ray.sh
    expect eof
    # 运行v2ray.sh
    spawn ./v2ray.sh
    expect eof
    # 配置v2ray
    #先不配置了
    # 删除脚本
    spawn rm -f v2ray.sh
    expect eof
}

if {$is_bbr} {
    # 下载.sh
    spawn wget -O bbr.sh $bbr_url
    expect eof
    spawn chmod +x bbr.sh
    expect eof
    # 运行.sh
    spawn ./bbr.sh
    expect "*restart system*"
    send "n\r"
    expect eof
    # 删除脚本
    spawn rm -f bbr.sh
    expect eof
}

# 删除wget-log
spawn rm -f wget-log*
expect eof

# 安装完成
puts "\n所有安装已完成!"
if {$is_bbr} {
    puts "因为安装了BBR,需要重启系统."
    set is_reboot [readin "立即重启? [y/n]: "]
    if {$is_reboot} {
        reboot
    } else {
        puts "重启已取消..."
    }
}
