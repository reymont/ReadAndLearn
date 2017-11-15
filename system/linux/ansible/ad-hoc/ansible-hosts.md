

/etc/ansible/hosts - CSDN博客 
http://blog.csdn.net/yinzhipeng123/article/details/53054969

例如
[test]
web.yinzhipeng.com
dhcp ansible_ssh_host=172.16.18.195
1.中括号中的名字代表组名
2.主机(hosts)部分可以使用域名、主机名、IP地址表示；当然使用前两者时，也需要主机能反解析到相应的IP地址，一般此类配置中多使用IP地址；
3.别名，例如dhcp那行
  如果某些主机的SSH运行在自定义的端口上，清单上可以这么写
192.168.1.1:3091
  假如你想要为某些静态IP设置一些别名，可以这样做：
server1 ansible_ssh_port = 1055 ansible_ssh_host = 172.16.3.2 
上面的server1别名就指代了IP为172.16.3.2，ssh连接端口为1055的主机。

```sh
指定主机范围 
[webservers]
www[01:50].jintian.com
[databases]
db-[a:f].jintian.com
上面指定了从web1到web50，webservers组共计50台主机；databases组有db-a到db-f共6台主机。

下面是hosts中能用到的参数
ansible_ssh_host   
#用于指定被管理的主机的真实IP
ansible_ssh_port     
#用于指定连接到被管理主机的ssh端口号，默认是22 
ansible_ssh_user     
#ssh连接时默认使用的用户名 
ansible_ssh_pass     
#ssh连接时的密码 
ansible_sudo_pass     
#使用sudo连接用户时的密码 
ansible_sudo_exec     
#如果sudo命令不在默认路径，需要指定sudo命令路径 ansible_ssh_private_key_file     
#秘钥文件路径，秘钥文件如果不想使用ssh-agent管理时可以使用此选项 ansible_shell_type     
#目标系统的shell的类型，默认sh 
ansible_connection     
#SSH 连接的类型： local , ssh , paramiko，在 ansible 1.2 之前默认是 paramiko ，后来智能选择，优先使用基于 ControlPersist 的 ssh （支持的前提） 
ansible_python_interpreter     
#用来指定python解释器的路径，默认为/usr/bin/python 同样可以指定ruby 、perl 的路径 
ansible_*_interpreter    
#其他解释器路径，用法和ansible_python_interpreter类似，这里"*"可以是ruby或才perl等其他语言

[test]
192.168.1.1 ansible_ssh_user=root ansible_ssh_pass='P@ssw0rd' 192.168.1.2 ansible_ssh_user=breeze ansible_ssh_pass='123456' 192.168.1.3 ansible_ssh_user=bernie ansible_ssh_port=3055 ansible_ssh_pass='456789' 
上面的示例中指定了三台主机，三台主机的用密码分别是P@ssw0rd、123456、45789，指定的ssh连接的用户名分别为root、breeze、bernie，ssh 端口分别为22、22、3055 ，这样在ansible命令执行的时候就不用再指令用户和密码等了。

表示所有的主机可以使用all或者*
在ansible和ansible-playbook中，还可以通过一个参数”--limit”来明确指定排除某些主机或组：
ansible-playbook site.yml --limit datacenter2
从Ansible1.2开始，如果想排除一个文件中的主机可以使用"@"：
ansible-playbook site.yml --limit @retry_hosts.txt

查看ansible版本可以用
ansible --version查看
```