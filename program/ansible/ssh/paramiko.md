
Ansible ：一个配置管理和IT自动化工具 - CSDN博客 
    http://blog.csdn.net/huangkunyhx/article/details/50252195

我在刚开始的设置中遇到过几次问题，因此这里强烈推荐为 ansible 设置 SSH 公钥认证。不过在刚刚的测试中我们使用了 --ask-pass，在一些机器上你会需要安装 sshpass 或者像这样指定 -c paramiko：

$ ansible all -m ping --ask-pass -c paramiko
当然你也可以安装 sshpass，然而 sshpass 并不总是在标准的仓库中提供，因此 paramiko 可能更为简单。