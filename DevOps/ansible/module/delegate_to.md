

ansible 的任务委派功能（delegate_to）-liheng_2006-51CTO博客 http://blog.51cto.com/simpledevops/1653191

今天遇到这样一个需求：在对A服务器执行一个操作任务的时候，同时也要把该操作任务在B服务器执行，如在A服务器添加一条hosts 记录: 1.1.1.1 abc.com 。这个必须是要在一个 playbook 完成，而且B服务器只需要执行这一个操作任务，其它操作任务不需要执行。也就是A服务器这一个操作任务与B服务器有依赖关系。
一开始这个需求可能通过ansible 是完成不了，但是在查阅了 ansible 文档后，发现ansible的任务委派（delegate_to）功能可以很好的完成这一要求。先看看ansible 官网文档对任务委派功能的描述：
Delegation
New in version 0.7.
This isn’t actually rolling update specific but comes up frequently in those cases.
If you want to perform a task on one host with reference to other hosts, use the ‘delegate_to’ keyword on a task. This is ideal for placing nodes in a load balanced pool, or removing them. It is also very useful for controlling outage windows. Using this with the ‘serial’ keyword to control the number of hosts executing at one time is also a good idea:

Ansible默认在配置的机器上执行任务，当你有一大票机器需要配置或则每个设备都可达的情况下很有用。但是，当你需要在另外一个Ansible控制机器上运行任务的时候，就需要用到任务委派了。
使用delegate_to关键字就可以委派任务到其他机器上运行，同时可用的fact也会使用委派机器上的值。下面的例子使用get_url到所有web服务器上下载配置：
---
- name: Fetch configuration from all webservers
hosts: webservers

tasks:
- name: Get config
get_url: dest=configs/` ansible_hostname ` force=yes url=http://` ansible_hostname `/diagnostic/config
delegate_to: localhost
当你委派给本机的时候，还可以使用更快捷的方法local_action，代码如下：
---
- name: Fetch configuration from all webservers
hosts: webservers

tasks:
- name: Get config
local_action: get_url dest=configs/` ansible_hostname`.cfg url=http://` ansible_hostname`/diagnostic/config
你可以委派任务给设备清单上的任意机器，下面是使用任务委派的一些场景：
在部署之前将一个主机从一个负载均衡集群中删除
当你要对一个主机做改变之前去掉相应dns的记录
当在一个存储设备上创建iscsi卷的时候
当使用外部的主机来检测网络出口是否正常的时候



下面描述下我的场景，如我要在192.168.1.1 服务器添加一个hosts 记录 "1.1.1.1 www.abc.com" ,同时也要把这个hosts 记录写到192.168.1.2
ansible hosts 192.168.1.1 文件内容
[all]
192.168.1.1

ansible task 文件内容(192.168.1.1.yml)：
---
- name: add host record
shell: "echo "1.1.1.1 www.abc.com" >> /etc/hosts"

- name: add host record
shell: "echo "1.1.1.1 www.abc.com" >> /etc/hosts"
delegate_to: 192.168.1.2
# 添加上面这一行，就可以了

执行playbook
ansible-playbook -i 192.168.1.1.host 192.168.1.1.yml