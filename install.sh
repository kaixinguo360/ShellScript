#!/usr/bin/expect 

# 设置静态参数
set timeout -1

set lnmp_url "https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/lnmp/lnmp.sh"
set wp_url "https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/wp/wp.sh"
set rewrite_url "https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/other/rewrite.sh"
set ssl_url "https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/other/ssl.sh"
set v2ray_url "https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/v2ray/v2ray.sh"
set v2ray_ssl_url "https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/v2ray/v2ray_ssl.sh"
set bbr_url "https://raw.githubusercontent.com/kaixinguo360/ShellScript/master/bbr/bbr.sh"

# 读取命令行参数
if { [lindex $argv 0] == "--help" || [lindex $argv 0] == "-h"  } {
    send_user "用法: $argv0 网站域名\n"
    send_user "                   MySQL根密码\n"
    send_user "                   WP数据库用户名\n"
    send_user "                   WP数据库密码\n"
    send_user "                   V2Ray端口\n"
    send_user "                   V2RayWS路径\n"
    exit
}

set host [lindex $argv 0]
set sql_root_pw [lindex $argv 1]
set sql_wp_user [lindex $argv 2]
set sql_wp_pw [lindex $argv 3]
set v_port [lindex $argv 4]
set ws_path [lindex $argv 5]

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

proc readstr {text} {
    while {true} {
        puts $text
        gets stdin input
        switch -regexp $input {
            ^$ {
                puts "输入不能为空!\n"
            }
            default {
                break;
            }
        }
    }
    return $input
}

proc checkvalue {value text} {
    if {$value == ""} {
        return [readstr $text]
    } else {
        return $value
    }
}


# 读取用户输入
set is_lnmp [readin "安装LNMP? \[Y/n\]: "]
if {$is_lnmp} {
    set host [checkvalue $host "请输入网站域名"]
    set sql_root_pw [checkvalue $sql_root_pw "MySQL根密码"]
}

if {$is_lnmp} {
    set is_wp [readin "安装WordPress? \[Y/n\]: "]
    if {$is_wp} {
        set host [checkvalue $host "请输入网站域名"]
        set sql_root_pw [checkvalue $sql_root_pw "MySQL根密码"]
        set sql_wp_user [checkvalue $sql_wp_user "WP数据库用户名"]
        set sql_wp_pw [checkvalue $sql_wp_pw "WP数据库密码"]
    }
} else {
    set is_wp false
}

if {$is_lnmp} {
    set is_rewrite [expr ! [readin "允许未绑定的域名访问(不重定向)? \[Y/n\]: "]]
    if {$is_rewrite} {
        set host [checkvalue $host "请输入网站域名"]
    }
} else {
    set is_rewrite false
}

if {$is_lnmp} {
    set is_ssl [readin "开启SSL? \[Y/n\]: "]
    if {$is_ssl} {
        set host [checkvalue $host "请输入网站域名"]
    }
} else {
    set is_ssl false
}

set is_v2ray [readin "安装V2Ray.fun? \[Y/n\]: "]

if {$is_v2ray} {
    set is_v2ray_ssl [readin "开启V2Ray的WS+TLS+Web? \[Y/n\]: "]
    if {$is_v2ray_ssl} {
        set host [checkvalue $host "请输入网站域名"]
        set v_port [checkvalue $v_port "请输入V2Ray端口号"]
        set ws_path [checkvalue $ws_path "请输入WS路径"]
    }
} else {
    set is_v2ray_ssl false
}

set is_bbr [readin "安装BBR? \[Y/n\]: "]

if {$is_bbr} {
    set is_reboot [readin "自动重启? \[Y/n\]: "]
} else {
    set is_reboot false
}


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
    # 下载.sh
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

if {$is_ssl} {
    # 下载.sh
    spawn wget -O ssl.sh $ssl_url
    expect eof
    spawn chmod +x ssl.sh
    expect eof
    # 运行.sh
    spawn ./ssl.sh
    expect "*网站域名*"
    send "$host\r"
    expect "*本地配置文件*"
    send "default\r"
    expect eof
    # 删除脚本
    spawn rm -f ssl.sh
    expect eof
}

if {$is_v2ray} {
    # 下载.sh
    spawn wget -O v2ray.sh $v2ray_url
    expect eof
    spawn chmod +x v2ray.sh
    expect eof
    # 运行.sh
    spawn ./v2ray.sh
    expect eof
    # 配置v2ray
    #先不配置了
    # 删除脚本
    spawn rm -f v2ray.sh
    expect eof
}

if {$is_v2ray_ssl} {
    # 下载.sh
    spawn wget -O v2ray_ssl.sh $v2ray_ssl_url
    expect eof
    spawn chmod +x v2ray_ssl.sh
    expect eof
    # 运行.sh
    spawn ./v2ray_ssl.sh
    expect "*网站域名*"
    send "$host\r"
    expect "*端口号*"
    send "$v_port\r"
    expect "*WS路径*"
    send "$ws_path\r"
    expect eof
    # 删除脚本
    spawn rm -f v2ray_ssl.sh
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
    expect "*any key to start*"
    send "\r"
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
    if {$is_reboot} {
        spawn reboot
        expect eof
    } else {
        puts "稍后请手动重启"
    }
}
