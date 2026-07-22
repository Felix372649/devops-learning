开源数据库MySQL DBA运维实战


数据库能做什么？
不论是淘宝，吃鸡，爱奇艺，抖音，快手，知乎，百度贴吧等，总所周知的服务程序。存储的数据，包含用户的账号，密码，级别，存款，余额，等级，购物记录，头像本地路径，视频文件路径。只要是信息，就一定在数据库里。

数据库-系统结构

1. 数据库系统 DBS：

A.数据库管理系统（DataBase Management System， DBMS）: （面试题）
SQL(RDS关系型数据库)
ORACLE
Oracle MySQL
DB2（IBM）
SQL-server（MS）
Mysql
MariaDB
Percona server（taobao）

B.DBA:工程师

2. SQL语言（结构化查询语言）：
A. DDL语句 数据库定义语言： 数据库、表、视图、索引、存储过程、函数， CREATE DROP ALTER //开发人员
B. DML语句 数据库操纵语言： 插入数据INSERT、删除数据DELETE、更新数据UPDATE //开发人员
C. DQL语句 数据库查询语言： 查询数据 SELECT 
D. DCL语句 数据库控制语言： 例如控制用户的访问权限GRANT、REVOKE

3. 数据访问技术：
ODBC PHP <.php>    JDBC JAVA <.jsp>    ASP.NET<c#>

版本：Mysql5.7

【部署】
官网地址：
www.mysql.com     www.oracle.com

RPM：
设置内存：还原快照、调整2G内存、

关闭防火墙和selinux：
立刻停止防火墙：systemctl stop  firewalld
开机禁用防火墙：systemctl disable  firewalld
立刻停止selinux：setenforce 0
开机禁用selinux：vim    /etc/selinux/config  修改：SELINUX=disabled

安装Mysql服务器：

1.访问国内mysql镜像站 
http://mirrors.ustc.edu.cn/

2.下载软件包 
wget http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-server-5.7.29-1.el7.x86_64.rpm
wget http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-client-5.7.29-1.el7.x86_64.rpm
wget http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-common-5.7.29-1.el7.x86_64.rpm
wget http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7/mysql-community-libs-5.7.29-1.el7.x86_64.rpm

3.安装相关软件
yum  install  -y   net-tools.x86_64    libaio.x86_64    perl.x86_64

4.安装Mysql服务器
 yum install -y mysql-community*
报错信息：

解决方法：卸载冲突的软件包，再安装
yum remove -y mariadb-libs.x86_64
yum install -y mysql-community*

5.启动Mysql服务器
systemctl start mysqld
systemctl enable mysqld
systemctl status mysqld

6.查询Mysql服务器默认密码（没有查到密码的原因，是因为没有启动成功。）
grep 'password' /var/log/mysqld.log 

冒号和空格的后面，全都是密码

7.修改Mysql服务器密码
 mysqladmin   -uroot    -p'es,W;ya(K1Th'    password    'QianFeng@123'

8.登录Mysql系统
mysql      -uroot         -p'QianFeng@123'

9.查到默认数据库

实验完成

10.关机快照

源码包
特点：
源码安装
与二进制(RPM)发行版本相比，如果我们选择了通过源代码进行安装，那么在安装过程中我们能够对MySQL
所做的调整将会更多更灵活一些。因为通过源代码编译我们可以：
a) 针对自己的硬件平台选用合适的编译器来优化编译后的二进制代码；
b) 根据不同的软件平台环境调整相关的编译参数；
c) 针对我们特定应用场景选择需要什么组件不需要什么组件；
d) 根据我们的所需要存储的数据内容选择只安装我们需要的字符集；
e) 同一台主机上面可以安装多个MySQL；
f) 等等其他一些可以根据特定应用场景所作的各种调整。

在源码安装给我们带来更大灵活性的同时，同样也给我们带来了可能引入的隐患：
a) 对编译参数的不够了解造成编译参数使用不当可能使编译出来的二进制代码不够稳定；
b) 对自己的应用环境把握失误而使用的优化参数可能反而使系统性能更差；
c) 还有一个并不能称之为隐患的小问题就是源码编译安装将使安装部署过程更为复杂，所花费的时间更长；

准备编译环境：
yum -y install ncurses ncurses-devel openssl-devel bison gcc gcc-c++ make cmake
wget http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
内存硬盘空间

安装mysql
准备源码包：
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
tar xvf mysql-5.7.19.tar.gz
cd mysql-5.7.19     pwd
/root/mysql-5.7.19
mv ../boost_1_59_0.tar.gz  .
tar xf  boost_1_59_0.tar.gz

配置
[root@mysql-5.7.17 ~]# cmake . \
-DWITH_BOOST=boost_1_59_0/ \
-DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
-DSYSCONFDIR=/etc \
-DMYSQL_DATADIR=/usr/local/mysql/data \
-DINSTALL_MANDIR=/usr/share/man \
-DMYSQL_TCP_PORT=3306 \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_READLINE=1 \
-DWITH_SSL=system \
-DWITH_EMBEDDED_SERVER=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1

常见错误：
-DWITH_BOOST=boost_1_59_0  
（如果没有提前准备，可以使用下面的参数自己装）
-DDOWNLOAD_BOOST=1

-DWITH_READLINE=1 \  5.6被移除

如果cmake失败，请将CMakeCache.txt缓存移除

编译：
make （等待1个小时左右）

安装： 
make install

初始化：
cd /usr/local/mysql 安装位置
mkdir mysql-files
chown -R mysql.mysql  /usr/local/mysql  注意目录名称
/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
（会生产临时密码，在屏幕上。保存临时密码。eGyLEeRr67-/      ）

/usr/local/mysql/bin/mysql_ssl_rsa_setup --datadir=/usr/local/mysql/data

【建立MySQL配置文件my.cnf   】    
备份原有配置文件 
mv /etc/my.cnf  ~

vim /etc/my.cnf
[mysqld]
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data

开机启动MySQL：

cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
chkconfig --add mysqld 
添加mysql服务：systemctl   enable  mysqld
chkconfig mysqld on  开机自动启动mysql服务
service mysqld start
ps aux |grep mysqld

mysql -u root -p '密码'  登陆有问题吗？
/usr/local/mysql/bin/mysql -u root -p'x/dwiQ2<l:hb'

不要忘了配置新密码。
/usr/local/mysql/bin/mysqladmin -u root -p 'x/dwiQ2<l:hb' password 'QinFeng@123'
show databases; 看到库即可。



