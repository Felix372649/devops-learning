#!/bin/bash

#=======[   ansible - Role-角色扮演   ]======
# roles则是在ansible中，playbooks的目录组织结构。
# 将代码或文件进行模块化，成为roles的文件目录组织结构，易读，代码可重用，层次清晰。

# 目标:通过role远程部署nginx并配置


# 1.目录结构
# roles/
#   ┣-nginx
#   |   ┣-files              # 放静态文件，原样拷贝到目标机（如 index.html）
#   |   |   ┗-index.html     # 静态网页文件，会被原样拷贝到目标机器上，作为 nginx 的默认首页。
#   |   ┣-handlers           # 放处理器，被 notify 触发（如重启服务）
#   |   |   ┗-main.yaml      # 定义处理器，比如“重启 nginx”这种操作。它不会主动运行，得靠任务里的 notify 来触发。
#   |   ┣-tasks              # 放任务列表，角色实际要执行的操作
#   |   |   ┗-main.yaml      # 角色的核心任务清单，写着具体要干的事：装软件、拷文件、开服务…… 所有动作都列在这里。
#   |   ┣-templates          # 放 Jinja2 模板，通过变量渲染后生成配置文件
#   |   |   ┗-nginx.conf.j2  # nginx 配置的 Jinja2 模板文件。里面可以写变量 {{ }}，在任务执行时会渲染成最终配置再上传。
#   |   ┗-vars               # 放变量，供角色内部使用，优先级较高
#   |       ┗-main.yaml      # 角色变量文件，定义模板和任务里要用到的值，比如端口、路径，优先级较高，不容易被覆盖。
#   ┗-site.yaml              # 主 playbook 文件，负责编排整个流程，引用 nginx 角色去执行任务。它是入口。


# 一共6个目录，6个文件
# nginx                      # 角色名
# files                      # 普通文件
# handlers                   # 触发器程序
# tasks                      # 主任务
# templates                  # 金甲模板（有变量的文件）
# vars                       # 自定义变量


#-----------------[准备目录结构]-----------------
# 备份原有所有 yum 源配置文件（出错可回滚）
# 1. 探针函数：多维度 YUM 环境健康检查

check_yum_health() {
    echo "====================================="
    echo "|----开始 YUM 环境与网络健康检查----|"
    echo "====================================="

    # 找一个必然存在的元数据文件作为靶标
    TARGET_URL="https://mirrors.ustc.edu.cn/epel-archive/7/x86_64/repodata/repomd.xml"


    # 1. 探测网络与拦截状态
    echo -n " 探测镜像站连通性与 IP 状态... "
    HTTP_CODE=$(curl -s -m 5 -o /dev/null -w "%{http_code}" "$TARGET_URL")

    if [[ "$HTTP_CODE" == "200" ]]; then
        echo "通过! (状态码 200)"
    elif [[ "$HTTP_CODE" == "403" ]]; then
        echo "失败! 你的公网 IP 被拦截了 (403 Forbidden)"
        return 1
    elif [[ "$HTTP_CODE" == "404" ]]; then
        echo "失败! 目标源路径不存在或已下线 (404 Not Found)"
        return 2
    elif [[ "$HTTP_CODE" == "000" ]]; then
        echo "失败! 无法连接外网或 DNS 解析失败"
        return 3
    else
        echo "异常! 未知状态码: $HTTP_CODE"
        return 4
    fi


    # 2. 探测 YUM 本地配置是否纯净
    echo -n " 探测 YUM 配置文件完整性... "
    if yum clean all -q >/dev/null 2>&1 && yum makecache -q >/dev/null 2>&1; then
        echo "通过!"
    else
        echo "失败!"
        echo "====================================="
        echo "结论：YUM 本地 .repo 文件有语法错误或脏数据干扰！"
        return 5
    fi

    # 3. 探测目标包(Nginx)是否就绪 (防私有源漏包)
    echo -n " 探测目标软件包(Nginx)可用性... "
    if yum info nginx -q >/dev/null 2>&1; then
        echo "通过!"
        echo "====================================="
        echo "结论：YUM 环境非常健康，可以直接执行安装任务。"
        return 0
    else
        echo "失败!"
        echo "====================================="
        echo "结论：当前环境缺失 EPEL 扩展或 Nginx 包，需要接管重置！"
        return 6
    fi
}



# 2. 环境重置函数 (保留所有原始注释)
yum_ali(){
    echo "警告：环境检查未达标，启动强制接管修复..."
    
    mkdir -p /etc/yum.repos.d/backup
    rm -rf /etc/yum.repos.d/*.repo

cat << 'EOF' > /etc/yum.repos.d/CentOS-Base.repo
[base]
name=CentOS-7.9.2009 - Base
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-vault/7.9.2009/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-7.9.2009 - Updates
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-vault/7.9.2009/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-7.9.2009 - Extras
baseurl=https://mirrors.tuna.tsinghua.edu.cn/centos-vault/7.9.2009/extras/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

EOF


    # 3. 写入中科大 EPEL 归档源 (解决 Nginx 找不到的问题)
cat << 'EOF' > /etc/yum.repos.d/epel.repo
[epel]
name=EPEL Archive for CentOS 7 - USTC
baseurl=https://mirrors.ustc.edu.cn/epel-archive/7/$basearch/
enabled=1
gpgcheck=0

EOF



#    #下载阿里云 CentOS-7 base 基础源
#    if ! curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo; then
#      echo "阿里云 CentOS-7 base 基础源下载失败！"
#      return 1
#    fi

#    #下载阿里云 epel 扩展源
#    if ! curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo ; then
#      echo "阿里云 epel 扩展源下载失败！"
#    return 2
#    fi

    #清空所有本地缓存，强制后续命令联网
#    if ! yum clean all; then
#      echo "清空所有本地缓存失败！"
#      return 3
#    fi

    #从所有启用的源重新下载元数据并生成缓存
    if ! yum makecache; then
      echo "新源缓存生成失败，请检查源配置或网络"
      return 4
    fi
}


# 3. 业务安装逻辑 (保留所有原始注释)
cj(){
mkdir -p /root/roles/nginx/{files,handlers,tasks,templates,vars}
touch /root/roles/site.yaml /root/roles/nginx/{handlers,tasks,vars}/main.yaml
}

install_nginx(){
echo "123" > /root/roles/nginx/files/index.html

if ! rpm -q nginx &> /dev/null; then
  if yum install -y nginx && cp /etc/nginx/nginx.conf /root/roles/nginx/templates/nginx.conf.j2; then
    echo "安装nginx    复制nginx.conf.j2成功！"
  else
    echo "nginx安装失败！"
    return 6
  fi
fi
}


#-----------------[2.编写任务]-----------------
# vim roles/nginx/tasks/main.yaml
vim_main(){
cat > /root/roles/nginx/tasks/main.yaml <<EOM
---
# 第一步:安装epel
- name: install epel-release packge                            # 安装epel-release  软件包英文：packge   #个人理解 告诉程序我要按个软件包 名字叫epel-release
  yum: name=epel-release state=latest

# 第二步:安装nginx
- name: install nginx packge                                   # - name: 安装、nginx、软件包
  yum: name=nginx state=latest                                 # 想用啥工具？yum 软件叫啥名字？nginx  要干嘛？latest安装啊！

# 第三步:拷贝一个主页文件
- name: copy index.html                                        # - name: 找copy帮我复制index.html
  copy: src=index.html dest=/usr/share/nginx/html/index.html   # copy：复制模板  src源地址里的文件 拷贝到 dest目标地址里

# 第四步:拷贝配置文件
- name: copy nginx.conf template                               # template模板
  template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf
  notify: restart nginx                                        # 当模板发生变化时通知名为restart nginx的 handler 去重启 nginx”。

# 第五步:启动服务
- name: make sure nginx service running                        # make sure确保、保证、务必做到!  service 是服务，running 就是它要维持的状态。
  service: name=nginx state=started enabled=yes

EOM
#   解释下第四步为何不用copy而是用template
#   [copy]         直接把源文件原封不动地搬过去，什么都不会改。
#   [template]     先让 Jinja2 模板引擎处理文件，把里面的变量、循环、条件等动态部分渲染成最终内容，然后再把渲染结果拷贝到目标位置。
#   nginx.conf.j2  里很有 {{ ansible_processor_cores }} 和 {{ worker_connections }} 的变量，需要根据实际环境动态生成配置，所以必须用template
}



#----------[3.准备配置文件]----------
nginx_conf_j2(){
if ! [[ -f /root/roles/nginx/templates/nginx.conf.j2 ]]; then
    echo "没有找到nginx.conf.j2的金甲文件"
    return 10
else
    sed -ri 's/^worker_processes .*;$/worker_processes {{ ansible_processor_cores }};/' /root/roles/nginx/templates/nginx.conf.j2
    sed -ri 's/worker_connections 1024;/worker_connections {{ worker_connections }};/' /root/roles/nginx/templates/nginx.conf.j2
fi

# ============【 解 释 两 个 变 量 】============
# ------{{ ansible_processor_cores }}------
# 作用：让 nginx 的工作进程数自动等于 CPU 核心数。4 核机器就起 4 个工作进程，8 核就起 8 个。不会因为写死数字而浪费多核性能，也不会在低配机器上开太多进程。

# 为什么这样写？
#     一台服务器一个样，手写配置很容易写死，用变量就能自适应硬件，一份模板走天下。

# ------{{ worker_connections }}------
# 作用：决定每个工作进程能同时处理的最大连接数。
# 如果 worker_processes 是 4，worker_connections 是 1024，那最大并发连接数就是 4 × 1024 = 4096。控制并发能力的关键参数。

# 为什么这样写？
#     调整方便：需要提高并发时，只需要修改变量值再跑一遍 playbook，不用改模板。环境区分：开发环境可能设 512，生产环境设 2048，同一模板不同变量搞定。

}


#----------[4.编写变量]----------
main_yaml_worker_connections(){
# vim /root/roles/nginx/vars/main.yaml
cat > /root/roles/nginx/vars/main.yaml <<EOM
worker_connections: 10240
# xulei_var1: abc
# zhang_var2: /abc/def

EOM
}


#----------[5.编写处理程序]----------
main_yaml_handlers(){
# vim /root/roles/nginx/handlers/main.yaml
cat > /root/roles/nginx/handlers/main.yaml <<EOM
---
- name: restart nginx
  service: name=nginx state=restarted 

EOM
}


#----------[6.编写剧本]----------
roles_site_yaml(){
# vim /root/roles/site.yaml
cat > /root/roles/site.yaml <<EOM
---
- hosts: host4
  roles:
    - nginx

EOM

}


#----------[7.实施]----------
beta_ansible_playbook(){
if ! cd /root/roles; then
    echo "警告：没有roles目录！"
    exit 1
fi
ansible-playbook site.yaml --syntax-check   # 测试
ansible-playbook site.yaml                  # 实施剧本

}



#==========【 主 程 序 执 行 顺 序 】==========
if ! check_yum_health; then    # 先探测，失败了才执行yum源重置方案
    yum_ali                    # 环境重置函数
fi

cj                               # 0.检测yum源
install_nginx                    # 1.安装nginx
# vim_main                       # 2.编写任务      roles/nginx/tasks/main.yaml
# nginx_conf_j2                  # 3.修改配置文件  nginx.conf.j2
# main_yaml_worker_connections   # 4.编写变量
# main_yaml_handlers             # 5.编写处理程序
# roles_site_yaml                # 6.编写剧本
# beta_ansible_playbook          # 7.实施






