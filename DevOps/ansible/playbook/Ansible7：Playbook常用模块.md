* [Ansible7：Playbook常用模块【转】 - paul_hch - 博客园 ](http://www.cnblogs.com/paul8339/p/6159228.html)


# 1、template
    在实际应用中，我们的配置文件有些地方可能会根据远程主机的配置的不同而有稍许的不同，template可以使用变量来接收远程主机上setup收集到的facts信息，针对不同配置的主机，定制配置文件。用法大致与copy模块相同。
常用参数：
backup：如果原目标文件存在，则先备份目标文件
dest：目标文件路径
force：是否强制覆盖，默认为yes
group：目标文件属组
mode：目标文件的权限
owner：目标文件属主
src：源模板文件路径
validate：在复制之前通过命令验证目标文件，如果验证通过则复制
官方简单示例：
- template: src=/mytemplates/foo.j2 dest=/etc/file.conf owner=bin group=wheel mode=0644
- template: src=/mytemplates/foo.j2 dest=/etc/file.conf owner=bin group=wheel mode="u=rw,g=r,o=r"
- template: src=/mine/sudoers dest=/etc/sudoers validate='visudo -cf %s'
named.conf配置文件的jinja2模板示例：
options {
listen-on port 53 {
127.0.0.1;
{% for ip in ansible_all_ipv4_addresses %}
{{ ip }};
{% endfor %}
};
listen-on-v6 port 53 { ::1; };
directory "/var/named";
dump-file "/var/named/data/cache_dump.db";
statistics-file "/var/named/data/named_stats.txt";
memstatistics-file "/var/named/data/named_mem_stats.txt";
};
zone "." IN {
type hint;
file "named.ca";
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
{# Variables for zone config #}
{% if 'authorativenames' in group_names %}
{% set zone_type = 'master' %}
{% set zone_dir = 'data' %}
{% else %}
{% set zone_type = 'slave' %}
{% set zone_dir = 'slaves' %}
{% endif %}
zone "internal.example.com" IN {
type {{ zone_type }};
file "{{ zone_dir }}/internal.example.com";
{% if 'authorativenames' not in group_names %}
masters { 192.168.2.2; };
{% endif %}
};
playbook的引用该模板配置文件的方法示例：
- name: Setup BIND
  host: allnames
  tasks:
    - name: configure BIND
      template: src=templates/named.conf.j2 dest=/etc/named.conf owner=root group=named mode=0640
2、set_fact
    set_fact模块可以自定义facts，这些自定义的facts可以通过template或者变量的方式在playbook中使用。如果你想要获取一个进程使用的内存的百分比，则必须通过set_fact来进行计算之后得出其值，并将其值在playbook中引用。
下面是一个配置mysql innodb buffer size的示例：
```yaml
- name: Configure MySQL
  hosts: mysqlservers
  tasks: 
    - name: install MySql
      yum: name=mysql-server state=installed
    - name: Calculate InnoDB buffer pool size
      set_fact: innodb_buffer_pool_size_mb="{{ ansible_memtotal_mb / 2 }}"
    - name: Configure MySQL 
      template: src=templates/my.cnf dest=/etc/my.cnf owner=root group=root mode=0644 
      notify: restart mysql 
    - name: Start MySQL 
      service: name=mysqld state=started enabled=yes 
  handlers: 
    - name: restart mysql 
      service: name=mysqld state=restarted
```
my.cnf的配置示例：
```conf
# {{ ansible_managed }}
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted
security risks
symbolic-links=0
# Configure the buffer pool
innodb_buffer_pool_size = {{ innodb_buffer_pool_size_mb|int }}M
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```
#3、pause
在playbook执行的过程中暂停一定时间或者提示用户进行某些操作
常用参数：
minutes：暂停多少分钟
seconds：暂停多少秒
prompt：打印一串信息提示用户操作
示例：
 - name: wait on user input
   pause: prompt="Warning! Detected slight issue. ENTER to continue CTRL-C a to quit" 
- name: timed wait
  pause: seconds=30
4、wait_for
在playbook的执行过程中，等待某些操作完成以后再进行后续操作
常用参数：
connect_timeout：在下一个任务执行之前等待连接的超时时间
delay：等待一个端口或者文件或者连接到指定的状态时，默认超时时间为300秒，在这等待的300s的时间里，wait_for模块会一直轮询指定的对象是否到达指定的状态，delay即为多长时间轮询一次状态。
host：wait_for模块等待的主机的地址，默认为127.0.0.1
port：wait_for模块待待的主机的端口
path：文件路径，只有当这个文件存在时，下一任务才开始执行，即等待该文件创建完成
state：等待的状态，即等待的文件或端口或者连接状态达到指定的状态时，下一个任务开始执行。当等的对象为端口时，状态有started，stoped，即端口已经监听或者端口已经关闭；当等待的对象为文件时，状态有present或者started，absent，即文件已创建或者删除；当等待的对象为一个连接时，状态有drained，即连接已建立。默认为started
timeout：wait_for的等待的超时时间,默认为300秒
示例：
- wait_for: port=8080 state=started     #等待8080端口已正常监听，才开始下一个任务，直到超时
- wait_for: port=8000 delay=10    #等待8000端口正常监听，每隔10s检查一次，直至等待超时
- wait_for: host=0.0.0.0 port=8000 delay=10 state=drained    #等待8000端口直至有连接建立
- wait_for: host=0.0.0.0 port=8000 state=drained exclude_hosts=10.2.1.2,10.2.1.3    #等待8000端口有连接建立，如果连接来自10.2.1.2或者10.2.1.3，则忽略。
- wait_for: path=/tmp/foo    #等待/tmp/foo文件已创建
- wait_for: path=/tmp/foo search_regex=completed    #等待/tmp/foo文件已创建，而且该文件中需要包含completed字符串
- wait_for: path=/var/lock/file.lock state=absent    #等待/var/lock/file.lock被删除
- wait_for: path=/proc/3466/status state=absent        #等待指定的进程被销毁
- local_action: wait_for port=22 host="{{ ansible_ssh_host | default(inventory_hostname) }}" search_regex=OpenSSH delay=10    #等待openssh启动，10s检查一次
5、assemble
用于组装文件，即将多个零散的文件，合并一个大文件
常用参数：
src：原文件(即零散文件)的路径
dest：合并后的大文件路径
group：合并后的大文件的属组
owner：合并后的大文件的属主
mode：合并后的大文件的权限
validate：与template的validate相同，指定命令验证文件
ignore_hidden：组装时，是否忽略隐藏文件，默认为no，该参数在2.0版本中新增
示例：
- hosts: all 
  tasks: 
    - name: Make a Directory in /opt
      file: path=/opt/sshkeys state=directory owner=root group=root mode=0700 
    - name: Copy SSH keys over 
      copy: src=keys/{{ item }}.pub dest=/opt/sshkeys/{{ item }}.pub owner=root group=root mode=0600 
      with_items: 
        - dan 
        - kate 
        - mal 
    - name: Make the root users SSH config directory 
      file: path=/root/.ssh state=directory owner=root group=root mode=0700 
    - name: Build the authorized_keys file 
      assemble: src=/opt/sshkeys/ dest=/root/.ssh/authorized_keys owner=root group=root mode=0700   #将/opt/sshkeys目录里所有的文件合并到/root/.ssh/authorized_keys一个文件中
6、add_host
在playbook执行的过程中，动态的添加主机到指定的主机组中
常用参数：
groups：添加主机至指定的组
name：要添加的主机名或IP地址
示例：
- name: add a host to group webservers
  hosts: webservers
  tasks:
    - add_host name={{ ip_from_ec2 }} group=webservers foo=42    #添加主机到webservers组中，主机的变量foo的值为42
7、group_by
在playbook执行的过程中，动态的创建主机组
示例：
- name: Create operating system group
  hosts: all
  tasks:
    - group_by: key=os_{{ ansible_distribution }}           #在playbook中设置一个新的主机组
- name: Run on CentOS hosts only
  hosts: os_CentOS
  tasks:
    - name: Install Apache
      yum: name=httpd state=latest
- name: Run on Ubuntu hosts only
  hosts: os_Ubuntu
  tasks:
    - name: Install Apache
      apt: pkg=apache2 state=latest
8、debug
调试模块，用于在调试中输出信息
常用参数：
msg：调试输出的消息
var：将某个任务执行的输出作为变量传递给debug模块，debug会直接将其打印输出
verbosity：debug的级别
示例：
```sh
# Example that prints the loopback address and gateway for each host- debug: msg="System {{ inventory_hostname }} has uuid {{ ansible_product_uuid }}"
- debug: msg="System {{ inventory_hostname }} has gateway {{ ansible_default_ipv4.gateway }}"
  when: ansible_default_ipv4.gateway is defined
- shell: /usr/bin/uptime
  register: result
- debug: var=result verbosity=2    #直接将上一条指令的结果作为变量传递给var，由debug打印出result的值
- name: Display all variables/facts known for a host
  debug: var=hostvars[inventory_hostname] verbosity=4
```
# 9、fail
用于终止当前playbook的执行，通常与条件语句组合使用，当满足条件时，终止当前play的运行。可以直接由failed_when取代。
选项只有一个：
msg：终止前打印出信息
示例：
- fail: msg="The system may not be provisioned according to the CMDB status."
  when: cmdb_status != "to-be-staged"
本文出自 “无名小卒” 博客，请务必保留此出处http://breezey.blog.51cto.com/2400275/1757589