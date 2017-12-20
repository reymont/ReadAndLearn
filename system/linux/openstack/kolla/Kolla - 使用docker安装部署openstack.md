

Kolla - 使用docker安装部署openstack-the-way-to-cloud-51CTO博客 http://blog.51cto.com/iceyao/1741285

Kolla简介
kolla项目就是使用docker和ansible来部署安装openstack，docker的好处就是轻量，管理起来方便。

Kolla Bare Metal Deploy
让kolla跑起来的方式有三种：
1、裸机部署
2、结合heat
3、结合vagrant

这里只介绍CentOS7 kolla裸机部署：
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
yum install epel-release  # 安装epel源
yum install python-pip  # 安装pip
git clone https://git.openstack.org/openstack/kolla  # 下载kolla源码 
pip install kolla/   # 安装kolla
 
yum install -y python-devel libffi-devel openssl-devel gcc # 安装相关依赖包
yum install ansible  # 安装ansible，版本不要超过2.0.0，高版本有问题
curl -sSL https://get.docker.io | bash  # 安装docker
 
pip install -U tox   # 安装tox
pip install -U python-openstackclient  # 安装openstackclient，方便使用cli
 
tox -egenconfig  # 生成kolla-build.conf
cp -r kolla/etc/kolla /etc/   # 拷贝配置文件到/etc目录下
 
# 到此kolla安装完了
# 下面是构建docker image和ansible执行playbook
 
kolla-build --base centos --type source  # 构建docker images
 
vim /etc/kolla/globals.yml # 修改全局配置文件
    kolla_install_type: "source"
    kolla_internal_address: "172.16.20.215"
    network_interface: "eth0"
    neutron_external_interface: "eth1"
 
kolla-ansible deploy   # 一键安装
kolla-ansible post-deploy # 产生/etc/kolla/admin-openrc.sh文件

如果是multinode，还需要docker-registry。如何构建docker私有仓库见以下链接：
http://docs.openstack.org/developer/kolla/quickstart.html
http://dockerpool.com/static/books/docker_practice/repository/local_repo.html


参考链接
http://docs.openstack.org/developer/kolla/quickstart.html