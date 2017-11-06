

http://mengix.blog.51cto.com/7194660/1894614

有些服务器会更改SSH端口，更改方法如下：
/etc/ssh/sshd_config
```conf
sshd_config
#Port 22
Port 65535
```

更改后使用新方式进行修改配置文件
ssh-copy-id "-p port user@host"
1
ssh-copy-id "-p 65535 user@192.168.3.102"

配置ansible的hosts配置文件
```conf
[port]
192.168.3.102
[port:vars]
ansible_ssh_user="user"
ansible_ssh_port=65535
```
$ ansible port -m ping -u root
192.168.3.102 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}