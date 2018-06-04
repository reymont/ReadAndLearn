
* [ansible的使用 - ansible/Chef - 运维网 - iyunv.com ](https://www.iyunv.com/thread-87529-1-1.html)

# 一、ansible 模块名                              说明

file                                                用于配置文件属性
yum                                             用于管理软件包
cron                                            配置计划任务
copy                                            复制文件到远程主机
command                                  在远程主机上执行命令
shell/raw                                     类似于command模块，支持管道与通配符
user/group                                 配置用户/用户组
service                                         用于管理服务
ping                                            检测远程主机是否存活
setup                                           远程主机基本信息
mount                                         配置挂载点


# 二、file 模块
参数                                     说明
group                               定义文件/目录的所属组                            
owner                               定义文件/目录的所属人
mode                                定义文件/目录的权限
path                                  定义文件/目录的路径
recurse                             递归设置目录的属性  类似于-R的设置
                                         定义文件的状态
                                          directory:如果目录不存在，创建目录
state                                  touch:如果文件不存在，创建文件
                                          link：创建软连接
                                           hard：创建硬链接
                                           absent:删除文件或目录
eg：
1、创建目录
ansible  all -m file -a "path=/root/20150701 state=directory"
2、创建文件
ansible all -m file -a "path=/root/20150701/test.txt  state=touch"    
3、删除文件
ansible all -m file -a "path=/root/20150701/test.txt state=absent"                          
4、创建软链接
ansible all -m file -a "src=/etc/passwd desk=/root/ansible/passwd state=link"


# 三、copy 模块
参数                                    说明
src                                   源文件/目录路径
desk                                目标路径
backup                           覆盖之前，是否备份文件
owner                             设定文件/目录的所属人
group                             设定文件/目录的所属组
mode                              设定文件/目录的权限
1、拷贝文件至远程主机o
ansible  all -m copy -a "src=/root/20150701/test.txt desk=/root/ansible owner=root group=root mode=0755"
2、拷贝新文件至远程主机，且备份
ansible all -m copy -a "src=/root/20150701/test.txt desk=/root/ansible backup=yes" 远程文件覆盖，且备份


# 四、command 模块
参数                            说明
creates                    跟文件名，当该文件存在，则命令不执行
chdir                       在执行命令之前，切换到相关目录
removes                 跟文件名，当该文件不存在，则该命令不执行
1、常规用法
ansible all -m command -a "uptime"
2、特定参数 chdir
ansible all -m command -a "chdir=/root/ansible ls"
3、特定参数 creates
ansible all -m command -a "creates=/root/ansible/2015.txt uptime" uptime 命令会被跳过，因为2015.txt 文件存在
4、特定参数 removes
ansible all -m command -a "removes=/root/ansible/2015.txt uptime" 与creates相反，文件存在，则命令执行

# 五、cron 模块
参数                            说明

bachup                    对远程主机上的原任务计划内容修改之前做备份
mimute                    分钟(0-59，*，*/2，……)
hour                         小时(0-23，*，*/2，……)
day                           日(1-31，*，*/2,……)
month                      月(1-12，*，*/2，……)
weekday                   周(0-7，*，……)
name                        该任务的描述
job                            要执行的任务，依赖于state=present
special_time            指定什么时候执行，参数:\reboot,yearly,annually,monthly,weekly,daily,hourly
state                         确认该任务计划是创建(present)还是删除(absent)
user                          以哪个用户的身份执行
eg1:每天5 点30 分执行ls 命令(默认state=present)
ansible all -m cron -a "name='list files in ansible_dir' minute=30 hour=5 job='ls -l
/root/ansible'"
eg2:执行备份操作
ansible all -m cron -a "name='list files in ansible_dir' backup=yes minute=10
hour=2 job='uptime' "
eg3：//删除指定计划任务
ansible all -m cron -a "name='list files in ansible_dir' state=absent"

# 六、yum 模块
参数名                                          说明
enablerepo                               启用指定yum 源
name                                    要进行操作的软件包的名字，也可以传递一个url 或者一个本地的rpm 包的路径， 安装软件                        组也是由@开头。 
state                                      定义软件包状态
                                                present:安装
                                                absent：删除
                                                latest：安装最新的
                           创建repo 文件
//传输repo 文件到远程主机
ansible all -m copy -a "src=/root/bruce/centos.repo dest=/etc/yum.repos.d/"
//启用repo，安装httpd 包
ansible all -m yum -a "enablerepo=centos6u5 name=httpd state=present"
http 包
http 包安装完毕
//直接安装网络rpm 包,安装nginx 源repo 包
ansible all -m yum -a \"name=http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6
.ngx.noarch.rpm state=present"
nginx 的repo 包安装完毕
//安装nginx 软件包
ansible all -m yum -a "name=nginx state=present"

# 七、service 模块
通过yum 安装完软件包后，需要做的就是配置文件以及启动服务了，那么service提供的就是启动服务的功能。 
参数名                                   说明
arguments                        给命令行提供一些选项
enabled                             是否开机启动:yes|no,类似于chkconfig
name                                 服务名称
runlevel                             运行级别
sleep                               如果执行restarted，stop 跟start 的间隔
state                               对当前服务执行启动，停止、重启、重新加载等操作(started,stopped,restarted,reloaded) 
// 启动上面安装的httpd 服务
ansible all -m service -a "name=httpd state=started enabled=yes"
httpd 启动成功
// 启动指定路径的服务
ansible all -m service -a "name=foo pattern=/usr/bin/foo state=started"
//指定重启eth0 操作
ansible all -m service -a "name=network state=restarted args=eth0"

# 八、user 模块
参数名                     说明
home                  指定家目录，需要createhome 为yes
group                 指定主用户组
groups                指定从用户组
uid                      用户UID
password            设置用户密码(需要为hash 密码值)
name                    用户名
createhome          是否创建家目录
system                 是否创建为系统用户
remove               当state=absent 时，删除家目录
state                  创建或删除用户
shell                  指定用户shell 环境
注意：password 这个功能有些问题，通过测试发现其存在字符限制，hash 密码
不能全部被获取，仅能获取部分字符插入至远程主机的/etc/shadow 文件中。
// 创建组-bruce
ansible all -m group -a "name=bruce state=present"
// 创建用户jason,属于bruce 组，家目录为：/home/memcached
ansible all -m user -a \
"name=jason group=bruce createhome=yes home=/home/memcached shell=/bin/bash
"
查看用户相关属性
//删除用户及其家目录
ansible all -m user -a "name=jason state=absent remove=yes"

## ansible-doc

//列出所有的ansible 模块
ansible-doc -l
//模块参数查询
ansible-doc -s 模块名
以上相关模块介绍是平时使用较多的模块，当然ansible 拥有大量的其他模块供
用户使用，可以在后期的实际应用场景中探索并补充。

# 九、进阶用法

    如果ansible 只能通过上面的方式完成任务，那也不算什么自动化了，它的强大
之处在于ansible 可以将所有的操作放置与playbooks 这边的功能里面，playbook
被翻译为剧本，在这里听起来感觉蛮奇怪的，其实想想也是没有问题，剧本就是
定义了主人公，情节等流程化的东西，playbooks 就是将不同的任务整理在一起，
然后通过ansible 调用后自动执行。类似于将传统的linux 命令整合在一起，形成
shell 脚本。
1. playbook 介绍
    playbook 是由一个或多个“play”组成的列表。play 的主要功能在于将事先归并为
一组的主机装扮成事先通过ansible 中的task 定义好的角色。从根本上来讲，所
谓task 无非是调用ansible 的一个module。将多个play 组织在一个playbook 中，
即可以让它们联合起来按事先编排的机制完成某一任务。
2. playbook 简单示例
- hosts: mfs_node
user: root
19
vars:
- motd_warning: 'WARNING: Use by ACME Employees ONLY'
tasks:
- name: setup a MOTD
copy: dest=/etc/motd content="{{ motd_warning }}"
notify: say someting
handlers:
- name: say someting
command: echo "copy OK"
以上示例主要分为四个部分
Target section
定义将要执行playbook 的远程主机组
Variable section
定义playbook 运行时需要使用的变量
Task section
定义将要在远程主机上执行的任务列表
Handler section
定义task 执行完成以后需要调用的任务
步骤参数说明：
Target section
参数名 说明
hosts 定义远程的主机组
user/remote_user 执行该任务组的用户
sudo 如果设置为yes，执行该任务组的用户在执行任务的时候，获
取root 权限
sudo_user 如果你设置user 为tom，sudo 为yes，sudo_user 为jerry，则tom
用户则会获取jerry 用户的权限
connection 通过什么方式连接到远程主机，默认为ssh
gather_facts 除非你明确说明不需要在远程主机上执行setup 模块，否则默
认会自动执行。如果你确实不需要setup 模块所传递过来的变
量，你可以启用该选项
Variable section
vars 直接定义参数值
vars_files 调用定义了参数变量的文件
vars_prompt
Task section
方式1 - name: install apache
action: yum name=httpd state=installed
方式2 - name: configure apache
copy: src=files/httpd.conf dest=/etc/httpd/conf/httpd.conf
方式3 - name: restart apache
service:
name: httpd
state: restarted
20
Handler section
tasks:
- name: template configuration file
template: src=template.j2 dest=/etc/foo.conf
notify:
- restart memcached
- restart apache
handlers:
- name: restart memcached
service: name= memcached state=restarted
- name: restart apache
service: name=httpd state=restarted
3. 简单案例
- hosts: all
user: root
vars:
tasks:
- name: install memcached
yum: name=memcached state=installed
- name: set memcached size
set_fact: memcached_size="{{ ansible_memtotal_mb / 4}}"
- name: copy configurations
template: src=files/memcached.j2 dest=/etc/sysconfig/memcached
notify:
- start memcached
handlers:
- name: start memcached
service: name=memcached state=started enabled=yes
调用set_fact 定义的参数
ansible-playbook memcached_install.yml //执行改yml 作业