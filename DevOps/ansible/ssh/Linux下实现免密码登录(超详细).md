

* [Linux下实现免密码登录(超详细)_Linux_脚本之家 ](http://www.jb51.net/article/94599.htm)

* ssh-keygen
  * man ssh-keygen
  * ssh-keygen -t rsa
  * 文件
    * authorized_keys:存放远程免密登录的公钥
    * id_rsa : 生成的私钥文件
    * id_rsa.pub ： 生成的公钥文件
    * know_hosts : 已知的主机公钥清单
* ssh公钥生效需满足至少下面两个条件：
  * .ssh目录的权限必须是700 
  * .ssh/authorized_keys文件权限必须是600
* 常用方法
  * ssh-copy-id -i ~/.ssh/id_rsa.pub 192.168.91.135
  * scp -p ~/.ssh/id_rsa.pub root@<remote_ip>:/root/.ssh/authorized_keys
  * scp ~/.ssh/id_rsa.pub root@<remote_ip>:pub_key
    cat ~/pub_key >>~/.ssh/authorized_keys 
  * vi /etc/ansible/hosts
    ansible <groupname> -m authorized_key -a "user=root key='{{ lookup('file','/root/.ssh/id_rsa.pub') }}'" -k
    ansible test -m authorized_key -a "user=root key='{{ lookup('file','/root/.ssh/id_rsa.pub') }}'" -k
　　