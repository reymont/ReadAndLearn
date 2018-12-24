

Linux下实现免密码登录(超详细)_Linux_脚本之家 http://www.jb51.net/article/94599.htm

ansible <groupname> -m authorized_key -a "user=root key='{{ lookup('file','/root/.ssh/id_rsa.pub') }}'" -k
示例：

[root@test sshpass-1.05]# ansible test -m authorized_key -a "user=root key='{{ lookup('file','/root/.ssh/id_rsa.pub') }}'" -k
　　SSH password: ----->输入密码
　　192.168.91.135 | success >> {
　　"changed": true, 
　　"key": "ssh-rsa 　　 AAAAB3NzaC1yc2EAAAABIwAAAQEArZI4kxlYuw7j1nt5ueIpTPWfGBJoZ8Mb02OJHR8yGW7A3izwT3/uhkK7RkaGavBbAlprp5bxp3i0TyNxa/apBQG5NiqhYO8YCuiGYGsQAGwZCBlNLF3gq1/18B6FV5moE/8yTbFA4dBQahdtVP PejLlSAbb5ZoGK8AtLlcRq49IENoXB99tnFVn3gMM0aX24ido1ZF9RfRWzfYF7bVsLsrIiMPmVNe5KaGL9kZ0svzoZ708yjWQQCEYWp0m+sODbtGPC34HMGAHjFlsC/SJffLuT/ug/hhCJUYeExHIkJF8OyvfC6DeF7ArI6zdKER7D8M0SM　　WQmpKUltj2nltuv3w== root@localhost.localdomain", 
　　"key_options": null, 
　　"keyfile": "/root/.ssh/authorized_keys", 
　　"manage_dir": true, 
　　"path": null, 
　　"state": "present", 
　　"unique": false, 
　　"user": "root"
　　}
　　[root@test sshpass-1.05]#