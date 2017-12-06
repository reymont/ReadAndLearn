
# http://blog.csdn.net/Myron_007/article/details/70154384
yum install epel-release -y
# 安装
yum install ansible -y
# 版本
ansible --version
# ssh
cd ~/.ssh
ssh-keygen
ssh-copy-id root@192.168.150.136
# 测试免密操作 
ansible all -m ping -u myron