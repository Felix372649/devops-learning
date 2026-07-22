#!/bin/bash
# ==========================================================
#           【LNMP + WordPress 一键部署脚本】
# ==========================================================

# ======【全局变量配置区】======
mysql_install="mysql-5.7.37-linux-glibc2.12-x86_64.tar.gz"
mysql_install_dir="mysql-5.7.37-linux-glibc2.12-x86_64"
wp_install="wordpress-4.9.28-zh_CN.tar.gz"
mysql_ip="127.0.0.1" # 这里统一用本地环回地址，彻底杜绝防火墙和网络拦截问题
mysql_server_id=1

echo "======[安装前置检查]======"
if [[ "$EUID" -ne 0 ]]; then
    echo "致命错误：请用root账号操作！"
    exit 1
fi

if [ ! -f "$mysql_install" ]; then
    echo "致命错误：没找到 $mysql_install 安装包！"
    exit 1
fi

if [ ! -f "$wp_install" ]; then
    echo "致命错误：没找到 $wp_install 安装包！"
    exit 1
fi
echo "安装包检查通过，准备发车！"
sleep 2

# ======【第一步：清理历史遗留环境】======
echo "======[清理旧环境]======"
setenforce 0 &>/dev/null || true
systemctl stop mysqld nginx php-fpm &>/dev/null || true
killall -9 mysqld nginx php-fpm &>/dev/null || true

# 物理超度所有残留目录（绝不留半点隐患）
rm -rf /usr/local/mysql
rm -rf /data/mysql
rm -rf /etc/my.cnf
rm -rf /etc/init.d/mysqld
rm -rf ${mysql_install_dir}
rm -rf wordpress

# 卸载旧的rpm包
yum remove -y mysql mysql-server mariadb mariadb-server &>/dev/null || true
id -u mysql &>/dev/null && userdel -r mysql &>/dev/null || true

echo "推土机清理完毕，场地干干净净！"


# ======【第二步：安装 Nginx 与 PHP 环境】======
echo "======[安装 Nginx & PHP 桥梁]======"
# 放行防火墙 (80和3306)
firewall-cmd --zone=public --add-port=80/tcp --permanent &>/dev/null || true
firewall-cmd --zone=public --add-port=3306/tcp --permanent &>/dev/null || true
firewall-cmd --reload &>/dev/null || true

# 使用最稳健的循环安装依赖
for i in epel-release nginx psmisc php-fpm php-mysql php-gd
do
    echo "正在安装 $i ..."
    yum install -y "$i" &>/dev/null
done

systemctl enable php-fpm &>/dev/null
systemctl start php-fpm


# ======【第三步：安装与初始化 MySQL (自闭症患者)】======
echo "======[安装 MySQL]======"
mkdir -p /usr/local/mysql
mkdir -p /data/mysql
useradd -M -s /sbin/nologin mysql

tar -xf "$mysql_install"
mv ${mysql_install_dir}/* /usr/local/mysql/
chown -R mysql:mysql /usr/local/mysql
chown -R mysql:mysql /data/mysql

# 写入配置文件
cat <<EOF > /etc/my.cnf
[mysqld]
user=mysql
datadir=/data/mysql
basedir=/usr/local/mysql
socket=/data/mysql/mysql.sock
port=3306
server_id=${mysql_server_id}
log_bin=mysql-bin
binlog_format=row
gtid_mode=on
enforce_gtid_consistency=on
[client]
socket=/data/mysql/mysql.sock
EOF

echo "正在初始化数据库，请稍等..."
/usr/local/mysql/bin/mysqld --initialize --user=mysql --datadir=/data/mysql --basedir=/usr/local/mysql &>2.txt
aa=$(grep 'temporary password' 2.txt | awk '{print $NF}')

cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld

# 环境变量与软连接
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
ln -sf /usr/local/mysql/bin/mysql /usr/bin/mysql

systemctl daemon-reload
systemctl start mysqld

if [ $? -ne 0 ]; then
    echo "MySQL 启动失败！请检查日志 /data/mysql/ 目录下的 .err 文件"
    exit 1
fi

echo "MySQL启动成功！准备修改密码和授权..."
# 先用初始密码修改 localhost 的 root 密码
mysql -uroot -p"$aa" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';"
# 开放远程 root 登录
mysql -uroot -p"123456" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;"
# 创建 bbs 数据库并分配专门的桥梁账号 phptest
mysql -uroot -p"123456" -e "create database bbs;"
mysql -uroot -p"123456" -e "grant all on bbs.* to phptest@'%' identified by '123456';"
mysql -uroot -p"123456" -e "flush privileges;"


# ======【第四步：部署 WordPress】======
echo "======[部署 WordPress 网站]======"
tar -zxf "$wp_install"
rm -rf /usr/share/nginx/html/*
cp -rf wordpress/* /usr/share/nginx/html/
chown -R nginx:nginx /usr/share/nginx/html/
chmod -R 755 /usr/share/nginx/html/

# 生成 wp-config.php 配置文件
cp /usr/share/nginx/html/wp-config-sample.php /usr/share/nginx/html/wp-config.php

# 替换数据库连接信息 (妖怪贴符替换法)
sed -i "s/database_name_here/bbs/"             /usr/share/nginx/html/wp-config.php
sed -i "s/username_here/phptest/"               /usr/share/nginx/html/wp-config.php
sed -i "s/password_here/123456/"                /usr/share/nginx/html/wp-config.php
sed -i "s/localhost/$mysql_ip/"                 /usr/share/nginx/html/wp-config.php


# ======【第五步：打通 Nginx 与 PHP】======
echo "======[架设 Nginx 与 PHP 桥梁]======"
MY_CONF="/etc/nginx/default.d/bbs_php_bridge.conf"
mkdir -p /etc/nginx/default.d/

cat > "$MY_CONF" << 'EOF'
index index.php index.html index.htm;

location ~ \.php$ {
    root           /usr/share/nginx/html;
    fastcgi_pass   127.0.0.1:9000;
    fastcgi_index  index.php;
    fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
    include        fastcgi_params;
}
EOF

# 启动 Nginx
systemctl enable nginx &>/dev/null
systemctl restart nginx

# ======【第六步：验收工作】======
if [ $? -eq 0 ]; then
cat <<EOM

=======================================================
[恭喜！LNMP + WordPress 终极部署完毕！]

1. Nginx (文盲) 已经在 80 端口就绪！
2. MySQL (自闭症) 已经在 3306 端口就绪！
3. PHP (桥梁) 已经在 9000 端口通车！

👉 现在，请打开你的浏览器，输入这台虚拟机的 IP 地址：
     http://你的虚拟机IP/

你将直接看到 WordPress 的五分钟著名安装页面！

=======================================================
EOM
else
    echo "Nginx 启动失败，请检查配置！"
fi

# 手动加载一次环境变量供当前终端使用
source /etc/profile





#======================================[启动失败如何排错！]=================================================

#第一步：看服务到底活没活着
#脚本跑完了，你以为它们都在上班，其实可能某个家伙早就偷偷猝死了。

#你该敲的命令：
#systemctl status nginx php-fpm mysqld

#怎么看： 重点找绿色的 active (running)。如果看到红色的 failed，说明这个软件根本就没启动成功。谁红了，就死磕谁。

#第二步：看端口有没有被占或者没开
#如果三个服务都是绿的，说明它们活着，但可能没在对的地方干活。

#你该敲的命令：
#netstat -tulnp | grep -E '80|9000|3306'

#怎么看：

#有没有 0.0.0.0:80 (Nginx 前台在接客)
#有没有 127.0.0.1:9000 (PHP 桥梁搭好了)
#有没有 :::3306 或 0.0.0.0:3306 (MySQL 仓库大爷就位了)
#如果哪个端口没出现，说明那个环节断了。

#第三步：查报错日志！
#如果服务活着，端口也在，但网页就是报错（比如 502 Bad Gateway 或者数据库连不上），绝对不要猜，直接去看它们的“日记”里在抱怨什么。

#Nginx 报错了查这里：
#tail -n 20 /var/log/nginx/error.log

#PHP 报错了查这里：
#tail -n 20 /var/log/php-fpm/error.log

#MySQL 报错了查这里（根据你脚本的路径）：
#tail -n 20 /data/mysql/*.err

#排错就像破案，案发现场全在上面这三个地方，把它们当成三个独立的嫌疑人，一个个审问。


#=========================================================
