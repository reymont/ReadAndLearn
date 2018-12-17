

Kolla安装Ocata 单节点 – 陈沙克日志 http://www.chenshake.com/kolla-installation/

大家看我的blog，其实一直都没写过Kolla的安装过程，其实并不是我不想写，而是对于用户来说，参考我的文章，因为网络带宽的原因，他其实是很难照做的。

经过很多的尝试，在OpenStack的Ocata版本发布的时候，我想我应该已经有办法解决安装的各种问题。

我还是使用大家最常用的vmware workstation 12.0, CentOS 7.3 虚拟机来完成整个的验证过程。

Contents [hide]
1 准备工作
2 基础包
3 安装Docker
4 Ansible
5 Registry 服务器
6 kolla-ansible
7 验证部署
8 参考文档
准备工作
我习惯最小化安装CentOS 7.3，装完后，对他进行初始化的工作。

http://www.chenshake.com/centos-7-x-class/ 大家照做就可以，放到一个文档，显得太长。selinux，防火墙端口无法访问，主机名问题，都是安装的常见错误，大家一定要细心确认。

kolla的安装，要求目标机器是两块网卡，所以我虚拟机也是分配两块网卡，

ens33，NAT网络里，设置的IP是：192.168.27.10，日后Horizon访问就是通过这个IP地址
ens34，桥接模式，ip其实是dhcp分配，这个其实是让neutron的br-ex 绑定使用，虚拟机是通过这块网卡访问外网。
在机器上连接虚拟机，是通过ens33的IP进行访问，如果你通过ens34 ssh，安装过程，会导致ssh中断。

默认设置，其实两块网卡都是可以访问到互联网。也可以是其中一块网卡访问外网，对于测试来说，基本问题不大。

如果在服务器直接安装，两块网卡的IP，就算是同一个网段，也是没啥问题的。

以前安装kolla，必须自己build镜像，这样由于网络的原因，经常会导致在build 镜像的时候失败。这次我们直接采用kolla官方提供的镜像文件，这样就不需要自己build镜像的环节。

 

基础包
一定要启用EPEL的repo源

yum install epel-release
yum install python-devel libffi-devel gcc openssl-devel git python-pip
安装Docker
目前最新版本的Docker是1.13.1，Kolla目前支持的Docker是1.12.x，所以我们要指定Docker的版本来安装，并且一定要采用Docker官方的源，不能使用红帽的源，红帽的源的Docker是有bug。

设置repo

tee /etc/yum.repos.d/docker.repo << 'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
安装Docker 1.12.5

yum install docker-engine-1.12.5 docker-engine-selinux-1.12.5
设置docker

mkdir /etc/systemd/system/docker.service.d
tee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'
[Service]
MountFlags=shared
EOF
重启相关服务

systemctl daemon-reload
systemctl enable docker
systemctl restart docker
访问私有的Docker仓库

编辑  /usr/lib/systemd/system/docker.service

#ExecStart=/usr/bin/dockerd
ExecStart=/usr/bin/dockerd --insecure-registry 192.168.27.10:4000
重启服务

systemctl daemon-reload
systemctl restart docker
Ansible
Kolla项目的Mitaka版本要求ansible版本低于2.0，Newton版本以后的就只支持2.x以上的版本。

yum install ansible
Registry 服务器
默认docker的registry是使用5000端口，对于OpenStack来说，有端口冲突，所以改成4000

docker run -d -v /opt/registry:/var/lib/registry -p 4000:5000 \
--restart=always --name registry registry:2
下载kolla官方提供的镜像

http://tarballs.openstack.org/kolla/images/

这是kolla官方提供的镜像给CI使用，只保留最新版本和最新的stable版本。大家可以下载Ocata版本

wget http://tarballs.openstack.org/kolla/images/centos-source-registry-ocata.tar.gz
tar zxvf centos-source-registry-ocata.tar.gz -C /opt/registry/
这样就把kolla的docker镜像文件放到Regisitry服务器上。

kolla-ansible
下载kolla-ansible的代码

cd /home
git clone http://git.trystack.cn/openstack/kolla-ansible –b stable/ocata
安装kolla-ansible

cd kolla-ansible
pip install .
一个小技巧，如果pip速度很慢，后面可以加上参数，指定国内的pip源

pip install . -i https://pypi.tuna.tsinghua.edu.cn/simple
复制相关文件

cp -r etc/kolla /etc/kolla/
cp ansible/inventory/* /home/
如果是在虚拟机里装kolla，希望可以启动再启动虚拟机，那么你需要把virt_type=qemu，默认是kvm

mkdir -p /etc/kolla/config/nova
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type=qemu
cpu_mode = none
EOF
生成密码文件

kolla-genpwd
编辑 /etc/kolla/passwords.yml

keystone_admin_password: chenshake
这是登录Dashboard，admin使用的密码，你可以根据自己需要进行修改。

编辑 /etc/kolla/globals.yml  文件

kolla_internal_vip_address: "192.168.27.11"

kolla_install_type: "source"
openstack_release: "4.0.0"
docker_registry: "192.168.27.10:4000"
docker_namespace: "lokolla"
network_interface: "ens33"
neutron_external_interface: "ens34"
192.168.27.11，这个ip是一个没有使用的的ip地址，他是给haproxy使用，单节点其实压根没有意义。

安装OpenStack

kolla-ansible deploy -i /home/all-in-one 
验证部署
 

kolla-ansible post-deploy
这样就创建 /etc/kolla/admin-openrc.sh 文件

安装OpenStack client端

pip install python-openstackclient
编辑 /usr/share/kolla-ansible/init-runonce，

网络需要根据实际情况修改

EXT_NET_CIDR='192.168.12.0/24'
EXT_NET_RANGE='start=192.168.12.30,end=192.168.12.40'
EXT_NET_GATEWAY='192.168.12.1'
这里解析一下，192.168.12.0的网络，就是我上面ens34接的网络，这个网络是通过路由器访问互联网。这个地方需要好好理解。配置好这个，装完虚拟机就可以直接ping通。

 

运行

source /etc/kolla/admin-openrc.sh
cd /usr/share/kolla-ansible
./init-runonce
最后你可以创建一个虚拟机来玩玩，根据最后的命令提示

openstack server create \
    --image cirros \
    --flavor m1.tiny \
    --key-name mykey \
    --nic net-id=2ba93782-71e2-44d6-ad64-796c5853dcce \
    demo1
这个时候，你可以登录Dashboard，给虚拟机分配一个floating ip，如果顺利，你应该就可以直接ping 通 floating ip的地址。

 

参考文档
http://docs.openstack.org/developer/kolla-ansible/quickstart.html

http://www.cnblogs.com/lienhua34/p/4922130.html

https://gist.github.com/jeffrey4l/c69688180b056d08a0c1733e24193143

http://www.cnblogs.com/microman/p/6107879.html

http://xcodest.me/