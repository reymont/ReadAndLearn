

CentOS7系统常用命令
 http://www.centoscn.com/CentOS/help/2015/0618/5687.html

个人工作总结出来供自行参考使用，如有不对之处还请大神们指出，感谢。
 
查看所有网卡IP地址——ip addr
 
启动防火墙——systemctl start firewalld.service
 
停止防火墙——systemctl stop firewalld.service
 
禁止防火墙开机启动——systemctl disable firewalld.service
 
列出正在运行的服务状态——systemctl
 
启动一个服务——systemctl start postfix.service
 
关闭一个服务——systemctl stop postfix.service
 
重启一个服务：——systemctl restart postfix.service
 
显示一个服务的状态——systemctl status postfix.service
 
在开机时启用一个服务——systemctl enable postfix.service
 
在开机时禁用一个服务——systemctl disable postfix.service
 
查看服务是否开机启动——systemctl is-enabled postfix.service;echo $?
 
查看已启动的服务列表——systemctl list-unit-files|grep enabled
 
设置系统默认启动运行级别3——ln -sf /lib/systemd/system/multi-user.target /etc/systemd/system/default.target