
使用Ceph RBD为Kubernetes集群提供存储卷 | Tony Bai
 http://tonybai.com/2016/11/07/integrate-kubernetes-with-ceph-rbd/

 使用Ceph RBD为Kubernetes集群提供存储卷
十一月 7, 2016 22 条评论
一旦走上使用Kubernetes的道路，你就会发现这条路并不好走，充满荆棘。即便你使用Kubernetes建立起的集群规模不大，也是需要“五脏俱全”的，否则你根本无法真正将kubernetes用起来，或者说一个半拉子Kubernetes集群很可能无法满足你要支撑的业务需求。在目前我正在从事的一个产品就是这样，光有K8s还不够，考虑到”有状态服务”的需求，我们还需要给Kubernetes配一个后端存储以支持Persistent Volume机制，使得Pod在k8s的不同节点间调度迁移时，具有持久化需求的数据不会被清除，且Pod中Container无论被调度到哪个节点，始终都能挂载到同一个Volume。

Kubernetes支持多种Volume类型，这里选择Ceph RBD（Rados Block Device）。选择Ceph大致有三个原因：

Ceph经过多年开发，已经逐渐步入成熟；
Ceph在Ubuntu 14.04.x上安装方便（仅通过apt-get即可），并且在未经任何调优（调优需要你对Ceph背后的原理十分熟悉）的情况下，性能可以基本满足我们需求；
Ceph同时支持对象存储、块存储和文件系统接口，虽然这里我们可能仅需要块存储。
即便这样，Ceph与K8s的集成过程依旧少不了“趟坑”，接下来我们就详细道来。

一、环境和准备条件

我们依然使用两个阿里云ECS Node，操作系统以及内核版本为：Ubuntu 14.04.4 LTS (GNU/Linux 3.19.0-70-generic x86_64)。

Ceph采用当前Ubuntu 14.04源中最新的Ceph LTS版本：JEWEL10.2.3。

Kubernetes版本为上次安装时的1.3.7版本。

二、Ceph安装原理

Ceph分布式存储集群由若干组件组成，包括：Ceph Monitor、Ceph OSD和Ceph MDS，其中如果你仅使用对象存储和块存储时，MDS不是必须的（本次我们也不需要安装MDS），仅当你要用到Cephfs时，MDS才是需要安装的。

Ceph的安装模型与k8s有些类似，也是通过一个deploy node远程操作其他Node以create、prepare和activate各个Node上的Ceph组件，官方手册中给出的示意图如下：

img{}

映射到我们实际的环境中，我的安装设计是这样的：

admin-node, deploy-node(ceph-deploy)：10.47.136.60  iZ25cn4xxnvZ
mon.node1，(mds.node1): 10.47.136.60  iZ25cn4xxnvZ
osd.0: 10.47.136.60   iZ25cn4xxnvZ
osd.1: 10.46.181.146 iZ25mjza4msZ
实际上就是两个Aliyun ECS节点承担以上多种角色。不过像iZ25cn4xxnvZ这样的host name太反人类，长远考虑还是换成node1、node2这样的简单名字更好。通过编辑各个ECS上的/etc/hostname, /etc/hosts，我们将iZ25cn4xxnvZ换成node1，将iZ25mjza4msZ换成node2：

10.47.136.60 （node1)：

# cat /etc/hostname
node1

# cat /etc/hosts
127.0.0.1 localhost
127.0.1.1    localhost.localdomain    localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
10.47.136.60 admin
10.47.136.60 node1
10.47.136.60 iZ25cn4xxnvZ
10.46.181.146 node2

----------------------------------
10.46.181.146 （node2)：

# cat /etc/hostname
node2

# cat /etc/hosts
127.0.0.1 localhost
127.0.1.1    localhost.localdomain    localhost

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
10.46.181.146  node2
10.46.181.146  iZ25mjza4msZ
10.47.136.60  node1
于是上面的环境设计就变成了：

admin-node, deploy-node(ceph-deploy)：node1 10.47.136.60
mon.node1, (mds.node1) : node1  10.47.136.60
osd.0:  node1 10.47.136.60
osd.1:  node2 10.46.181.146
三、Ceph安装步骤

1、安装ceph-deploy

Ceph提供了一键式安装工具ceph-deploy来协助Ceph集群的安装，在deploy node上，我们首先要来安装的就是ceph-deploy，Ubuntu 14.04官方源中的ceph-deploy是1.4.0版本，比较old，我们需要添加Ceph源，安装最新的ceph-deploy：

# wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -
OK

# echo deb https://download.ceph.com/debian-jewel/ $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/ceph.list
deb https://download.ceph.com/debian-jewel/ trusty main

#apt-get update
... ...

# apt-get install ceph-deploy
Reading package lists... Done
Building dependency tree
Reading state information... Done
.... ...
The following NEW packages will be installed:
  ceph-deploy
0 upgraded, 1 newly installed, 0 to remove and 105 not upgraded.
Need to get 96.4 kB of archives.
After this operation, 622 kB of additional disk space will be used.
Get:1 https://download.ceph.com/debian-jewel/ trusty/main ceph-deploy all 1.5.35 [96.4 kB]
Fetched 96.4 kB in 1s (53.2 kB/s)
Selecting previously unselected package ceph-deploy.
(Reading database ... 153022 files and directories currently installed.)
Preparing to unpack .../ceph-deploy_1.5.35_all.deb ...
Unpacking ceph-deploy (1.5.35) ...
Setting up ceph-deploy (1.5.35) ...
注意：ceph-deploy只需要在admin/deploy node上安装即可。

2、前置设置

和安装k8s一样，在ceph-deploy真正执行安装之前，需要确保所有Ceph node都要开启NTP，同时建议在每个node节点上为安装过程创建一个安装账号，即ceph-deploy在ssh登录到每个Node时所用的账号。这个账号有两个约束：

具有sudo权限；
执行sudo命令时，无需输入密码。
我们将这一账号命名为cephd，我们需要在每个ceph node上(包括admin node/deploy node)都建立一个cephd用户，并加入到sudo组中。

以下命令在每个Node上都要执行：

useradd -d /home/cephd -m cephd
passwd cephd

添加sudo权限：
echo "cephd ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/cephd
sudo chmod 0440 /etc/sudoers.d/cephd
在admin node(deploy node)上，登入cephd账号，创建该账号下deploy node到其他各个Node的ssh免密登录设置，密码留空：

在deploy node上执行：

$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/cephd/.ssh/id_rsa):
Created directory '/home/cephd/.ssh'.
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/cephd/.ssh/id_rsa.
Your public key has been saved in /home/cephd/.ssh/id_rsa.pub.
The key fingerprint is:
....
将deploy node的公钥copy到其他节点上去：

$ ssh-copy-id cephd@node1
The authenticity of host 'node1 (10.47.136.60)' can't be established.
ECDSA key fingerprint is d2:69:e2:3a:3e:4c:6b:80:15:30:17:8e:df:3b:62:1f.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
cephd@node1's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'cephd@node1'"
and check to make sure that only the key(s) you wanted were added.
同样，执行 ssh-copy-id cephd@node2，完成后，测试一下免密登录。

$ ssh node1
Welcome to Ubuntu 14.04.4 LTS (GNU/Linux 3.19.0-70-generic x86_64)

 * Documentation:  https://help.ubuntu.com/
New release '16.04.1 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Welcome to aliyun Elastic Compute Service!
最后，在Deploy node上创建并编辑~/.ssh/config，这是Ceph官方doc推荐的步骤，这样做的目的是可以避免每次执行ceph-deploy时都要去指定 –username {username} 参数。

//~/.ssh/config
Host node1
   Hostname node1
   User cephd
Host node2
   Hostname node2
   User cephd
3、安装ceph

这个环节参考的是Ceph官方doc手工部署一节。

如果之前安装过ceph，可以先执行如下命令以获得一个干净的环境：

ceph-deploy purgedata node1 node2
ceph-deploy forgetkeys
ceph-deploy purge node1 node2
接下来我们就可以来全新安装Ceph了。在deploy node上，建立cephinstall目录，然后进入cephinstall目录执行相关步骤。

我们首先来创建一个ceph cluster，这个环节需要通过执行ceph-deploy new {initial-monitor-node(s)}命令。按照上面的安装设计，我们的ceph monitor node就是node1，因此我们执行下面命令来创建一个名为ceph的ceph cluster：

$ ceph-deploy new node1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephd/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (1.5.35): /usr/bin/ceph-deploy new node1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  func                          : <function new at 0x7f71d2051938>
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f71d19f5710>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  ssh_copykey                   : True
[ceph_deploy.cli][INFO  ]  mon                           : ['node1']
[ceph_deploy.cli][INFO  ]  public_network                : None
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster_network               : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  fsid                          : None
[ceph_deploy.new][DEBUG ] Creating new cluster named ceph
[ceph_deploy.new][INFO  ] making sure passwordless SSH succeeds
[node1][DEBUG ] connection detected need for sudo
[node1][DEBUG ] connected to host: node1
[node1][DEBUG ] detect platform information from remote host
[node1][DEBUG ] detect machine type
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /sbin/initctl version
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /bin/ip link show
[node1][INFO  ] Running command: sudo /bin/ip addr show
[node1][DEBUG ] IP addresses found: [u'101.201.78.51', u'192.168.16.1', u'10.47.136.60', u'172.16.99.0', u'172.16.99.1']
[ceph_deploy.new][DEBUG ] Resolving host node1
[ceph_deploy.new][DEBUG ] Monitor node1 at 10.47.136.60
[ceph_deploy.new][DEBUG ] Monitor initial members are ['node1']
[ceph_deploy.new][DEBUG ] Monitor addrs are ['10.47.136.60']
[ceph_deploy.new][DEBUG ] Creating a random mon key...
[ceph_deploy.new][DEBUG ] Writing monitor keyring to ceph.mon.keyring...
[ceph_deploy.new][DEBUG ] Writing initial config to ceph.conf...
new命令执行完后，ceph-deploy会在当前目录下创建一些辅助文件：

# ls
ceph.conf  ceph-deploy-ceph.log  ceph.mon.keyring

$ cat ceph.conf
[global]
fsid = f5166c78-e3b6-4fef-b9e7-1ecf7382fd93
mon_initial_members = node1
mon_host = 10.47.136.60
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
由于我们仅有两个OSD节点，因此我们在进一步安装之前，需要先对ceph.conf文件做一些配置调整：
修改配置以进行后续安装：

在[global]标签下，添加下面一行：
osd pool default size = 2
ceph.conf保存退出。接下来，我们执行下面命令在node1和node2上安装ceph运行所需的各个binary包：

# ceph-deploy install nod1 node2
.... ...
[node2][INFO  ] Running command: sudo ceph --version
[node2][DEBUG ] ceph version 10.2.3 (ecc23778eb545d8dd55e2e4735b53cc93f92e65b)
这一过程ceph-deploy会SSH登录到各个node上去，执行apt-get update, 并install ceph的各种组件包，这个环节耗时可能会长一些（依网络情况不同而不同），请耐心等待。

4、初始化ceph monitor node

有了ceph启动的各个程序后，我们首先来初始化ceph cluster的monitor node。在deploy node的工作目录cephinstall下，执行：

# ceph-deploy mon create-initial

[ceph_deploy.conf][DEBUG ] found configuration file at: /root/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (1.5.35): /usr/bin/ceph-deploy mon create-initial
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : create-initial
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f0f7ea2fe60>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function mon at 0x7f0f7ee93de8>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  keyrings                      : None
[ceph_deploy.mon][DEBUG ] Deploying mon, cluster ceph hosts node1
[ceph_deploy.mon][DEBUG ] detecting platform for host node1...
[node1][DEBUG ] connected to host: node1
[node1][DEBUG ] detect platform information from remote host
[node1][DEBUG ] detect machine type
....

[iZ25cn4xxnvZ][INFO  ] Running command: ceph --cluster=ceph --admin-daemon /var/run/ceph/ceph-mon.iZ25cn4xxnvZ.asok mon_status
[ceph_deploy.mon][INFO  ] mon.iZ25cn4xxnvZ monitor has reached quorum!
[ceph_deploy.mon][INFO  ] all initial monitors are running and have formed quorum
[ceph_deploy.mon][INFO  ] Running gatherkeys...
[ceph_deploy.gatherkeys][INFO  ] Storing keys in temp directory /tmp/tmpP_SmXX
[iZ25cn4xxnvZ][DEBUG ] connected to host: iZ25cn4xxnvZ
[iZ25cn4xxnvZ][DEBUG ] detect platform information from remote host
[iZ25cn4xxnvZ][DEBUG ] detect machine type
[iZ25cn4xxnvZ][DEBUG ] find the location of an executable
[iZ25cn4xxnvZ][INFO  ] Running command: /sbin/initctl version
[iZ25cn4xxnvZ][DEBUG ] get remote short hostname
[iZ25cn4xxnvZ][DEBUG ] fetch remote file
[iZ25cn4xxnvZ][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --admin-daemon=/var/run/ceph/ceph-mon.iZ25cn4xxnvZ.asok mon_status
[iZ25cn4xxnvZ][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-iZ25cn4xxnvZ/keyring auth get-or-create client.admin osd allow * mds allow * mon allow *
[iZ25cn4xxnvZ][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-iZ25cn4xxnvZ/keyring auth get-or-create client.bootstrap-mds mon allow profile bootstrap-mds
[iZ25cn4xxnvZ][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-iZ25cn4xxnvZ/keyring auth get-or-create client.bootstrap-osd mon allow profile bootstrap-osd
[iZ25cn4xxnvZ][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-iZ25cn4xxnvZ/keyring auth get-or-create client.bootstrap-rgw mon allow profile bootstrap-rgw
... ...
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.client.admin.keyring
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.bootstrap-mds.keyring
[ceph_deploy.gatherkeys][INFO  ] keyring 'ceph.mon.keyring' already exists
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.bootstrap-osd.keyring
[ceph_deploy.gatherkeys][INFO  ] Storing ceph.bootstrap-rgw.keyring
[ceph_deploy.gatherkeys][INFO  ] Destroy temp directory /tmp/tmpP_SmXX
这一过程很顺利。命令执行完成后我们能看到一些变化：

在当前目录下，出现了若干*.keyring，这是Ceph组件间进行安全访问时所需要的：

# ls -l
total 216
-rw------- 1 root root     71 Nov  3 17:24 ceph.bootstrap-mds.keyring
-rw------- 1 root root     71 Nov  3 17:25 ceph.bootstrap-osd.keyring
-rw------- 1 root root     71 Nov  3 17:25 ceph.bootstrap-rgw.keyring
-rw------- 1 root root     63 Nov  3 17:24 ceph.client.admin.keyring
-rw-r--r-- 1 root root    242 Nov  3 16:40 ceph.conf
-rw-r--r-- 1 root root 192336 Nov  3 17:25 ceph-deploy-ceph.log
-rw------- 1 root root     73 Nov  3 16:28 ceph.mon.keyring
-rw-r--r-- 1 root root   1645 Oct 16  2015 release.asc
在node1(monitor node)上，我们看到ceph-mon已经运行起来了：

cephd@node1:~/cephinstall$ ps -ef|grep ceph
ceph     32326     1  0 14:19 ?        00:00:00 /usr/bin/ceph-mon --cluster=ceph -i node1 -f --setuser ceph --setgroup ceph
如果要手工停止ceph-mon，可以使用stop ceph-mon-all 命令。

5、prepare ceph OSD node

至此，ceph-mon组件程序已经成功启动了，剩下的只有OSD这一关了。启动OSD node分为两步：prepare 和 activate。OSD node是真正存储数据的节点，我们需要为ceph-osd提供独立存储空间，一般是一个独立的disk。但我们环境不具备这个条件，于是在本地盘上创建了个目录，提供给OSD。

在deploy node上执行：

ssh node1
sudo mkdir /var/local/osd0
exit

ssh node2
sudo mkdir /var/local/osd1
exit
接下来，我们就可以执行prepare操作了，prepare操作会在上述的两个osd0和osd1目录下创建一些后续activate激活以及osd运行时所需要的文件：

cephd@node1:~/cephinstall$ ceph-deploy osd prepare node1:/var/local/osd0 node2:/var/local/osd1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephd/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (1.5.35): /usr/bin/ceph-deploy osd prepare node1:/var/local/osd0 node2:/var/local/osd1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  disk                          : [('node1', '/var/local/osd0', None), ('node2', '/var/local/osd1', None)]
[ceph_deploy.cli][INFO  ]  dmcrypt                       : False
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  bluestore                     : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : prepare
[ceph_deploy.cli][INFO  ]  dmcrypt_key_dir               : /etc/ceph/dmcrypt-keys
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f072603e8c0>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  fs_type                       : xfs
[ceph_deploy.cli][INFO  ]  func                          : <function osd at 0x7f0726492d70>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  zap_disk                      : False
[ceph_deploy.osd][DEBUG ] Preparing cluster ceph disks node1:/var/local/osd0: node2:/var/local/osd1:
[node1][DEBUG ] connection detected need for sudo
[node1][DEBUG ] connected to host: node1
[node1][DEBUG ] detect platform information from remote host
[node1][DEBUG ] detect machine type
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /sbin/initctl version
[node1][DEBUG ] find the location of an executable
[ceph_deploy.osd][INFO  ] Distro info: Ubuntu 14.04 trusty
[ceph_deploy.osd][DEBUG ] Deploying osd to node1
[node1][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph_deploy.osd][DEBUG ] Preparing host node1 disk /var/local/osd0 journal None activate False
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /usr/sbin/ceph-disk -v prepare --cluster ceph --fs-type xfs -- /var/local/osd0
[node1][WARNIN] command: Running command: /usr/bin/ceph-osd --cluster=ceph --show-config-value=fsid
[node1][WARNIN] command: Running command: /usr/bin/ceph-osd --check-allows-journal -i 0 --cluster ceph
[node1][WARNIN] command: Running command: /usr/bin/ceph-osd --check-wants-journal -i 0 --cluster ceph
[node1][WARNIN] command: Running command: /usr/bin/ceph-osd --check-needs-journal -i 0 --cluster ceph
[node1][WARNIN] command: Running command: /usr/bin/ceph-osd --cluster=ceph --show-config-value=osd_journal_size
[node1][WARNIN] populate_data_path: Preparing osd data dir /var/local/osd0
[node1][WARNIN] command: Running command: /bin/chown -R ceph:ceph /var/local/osd0/ceph_fsid.782.tmp
[node1][WARNIN] command: Running command: /bin/chown -R ceph:ceph /var/local/osd0/fsid.782.tmp
[node1][WARNIN] command: Running command: /bin/chown -R ceph:ceph /var/local/osd0/magic.782.tmp
[node1][INFO  ] checking OSD status...
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /usr/bin/ceph --cluster=ceph osd stat --format=json
[
ceph_deploy.osd][DEBUG ] Host node1 is now ready for osd use.
[node2][DEBUG ] connection detected need for sudo
[node2][DEBUG ] connected to host: node2
... ...
[node2][INFO  ] Running command: sudo /usr/bin/ceph --cluster=ceph osd stat --format=json
[ceph_deploy.osd][DEBUG ] Host node2 is now ready for osd use.
prepare并不会启动ceph osd，那是activate的职责。

6、激活ceph OSD node

接下来，我们来激活各个OSD node：

$ ceph-deploy osd activate node1:/var/local/osd0 node2:/var/local/osd1

... ...
[node1][WARNIN] got monmap epoch 1
[node1][WARNIN] command: Running command: /usr/bin/timeout 300 ceph-osd --cluster ceph --mkfs --mkkey -i 0 --monmap /var/local/osd0/activate.monmap --osd-data /var/local/osd0 --osd-journal /var/local/osd0/journal --osd-uuid 6def4f7f-4f37-43a5-8699-5c6ab608c89c --keyring /var/local/osd0/keyring --setuser ceph --setgroup ceph
[node1][WARNIN] Traceback (most recent call last):
[node1][WARNIN]   File "/usr/sbin/ceph-disk", line 9, in <module>
[node1][WARNIN]     load_entry_point('ceph-disk==1.0.0', 'console_scripts', 'ceph-disk')()
[node1][WARNIN]   File "/usr/lib/python2.7/dist-packages/ceph_disk/main.py", line 5011, in run
[node1][WARNIN]     main(sys.argv[1:])
[node1][WARNIN]   File "/usr/lib/python2.7/dist-packages/ceph_disk/main.py", line 4962, in main
[node1][WARNIN]     args.func(args)
[node1][WARNIN]   File "/usr/lib/python2.7/dist-packages/ceph_disk/main.py", line 3324, in main_activate
[node1][WARNIN]     init=args.mark_init,
[node1][WARNIN]   File "/usr/lib/python2.7/dist-packages/ceph_disk/main.py", line 3144, in activate_dir
[node1][WARNIN]     (osd_id, cluster) = activate(path, activate_key_template, init)
[node1][WARNIN]   File "/usr/lib/python2.7/dist-packages/ceph_disk/main.py", line 3249, in activate
[node1][WARNIN]     keyring=keyring,
[node1][WARNIN]   File "/usr/lib/python2.7/dist-packages/ceph_disk/main.py", line 2742, in mkfs
[node1][WARNIN]     '--setgroup', get_ceph_group(),
[node1][WARNIN]   File "/usr/lib/python2.7/dist-packages/ceph_disk/main.py", line 2689, in ceph_osd_mkfs
[node1][WARNIN]     raise Error('%s failed : %s' % (str(arguments), error))
[node1][WARNIN] ceph_disk.main.Error: Error: ['ceph-osd', '--cluster', 'ceph', '--mkfs', '--mkkey', '-i', '0', '--monmap', '/var/local/osd0/activate.monmap', '--osd-data', '/var/local/osd0', '--osd-journal', '/var/local/osd0/journal', '--osd-uuid', '6def4f7f-4f37-43a5-8699-5c6ab608c89c', '--keyring', '/var/local/osd0/keyring', '--setuser', 'ceph', '--setgroup', 'ceph'] failed : 2016-11-04 14:25:40.325009 7fd1aa73f800 -1 filestore(/var/local/osd0) mkfs: write_version_stamp() failed: (13) Permission denied
[node1][WARNIN] 2016-11-04 14:25:40.325032 7fd1aa73f800 -1 OSD::mkfs: ObjectStore::mkfs failed with error -13
[node1][WARNIN] 2016-11-04 14:25:40.325075 7fd1aa73f800 -1  ** ERROR: error creating empty object store in /var/local/osd0: (13) Permission denied
[node1][WARNIN]
[node1][ERROR ] RuntimeError: command returned non-zero exit status: 1
[ceph_deploy][ERROR ] RuntimeError: Failed to execute command: /usr/sbin/ceph-disk -v activate --mark-init upstart --mount /var/local/osd0
激活没能成功，在激活第一个节点时，就输出了如上错误日志。日志的error含义很明显：权限问题。

ceph-deploy尝试在osd node1上以ceph:ceph启动ceph-osd，但/var/local/osd0目录的权限情况如下：

$ ls -l /var/local
drwxr-sr-x 2 root staff 4096 Nov  4 14:25 osd0
osd0被root拥有，以ceph用户启动的ceph-osd程序自然没有权限在/var/local/osd0目录下创建文件并写入数据了。这个问题在ceph官方issue中有很多人提出来，也给出了临时修正方法：

将osd0和osd1的权限赋予ceph:ceph：

node1：
sudo chown -R ceph:ceph /var/local/osd0

node2：
sudo chown -R ceph:ceph /var/local/osd1

修改完权限后，我们再来执行activate：

$ ceph-deploy osd activate node1:/var/local/osd0 node2:/var/local/osd1
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephd/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (1.5.35): /usr/bin/ceph-deploy osd activate node1:/var/local/osd0 node2:/var/local/osd1
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  subcommand                    : activate
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f3c90c678c0>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  func                          : <function osd at 0x7f3c910bbd70>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  disk                          : [('node1', '/var/local/osd0', None), ('node2', '/var/local/osd1', None)]
[ceph_deploy.osd][DEBUG ] Activating cluster ceph disks node1:/var/local/osd0: node2:/var/local/osd1:
[node1][DEBUG ] connection detected need for sudo
[node1][DEBUG ] connected to host: node1
[node1][DEBUG ] detect platform information from remote host
[node1][DEBUG ] detect machine type
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /sbin/initctl version
[node1][DEBUG ] find the location of an executable
[ceph_deploy.osd][INFO  ] Distro info: Ubuntu 14.04 trusty
[ceph_deploy.osd][DEBUG ] activating host node1 disk /var/local/osd0
[ceph_deploy.osd][DEBUG ] will use init type: upstart
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /usr/sbin/ceph-disk -v activate --mark-init upstart --mount /var/local/osd0
[node1][WARNIN] main_activate: path = /var/local/osd0
[node1][WARNIN] activate: Cluster uuid is f5166c78-e3b6-4fef-b9e7-1ecf7382fd93
[node1][WARNIN] command: Running command: /usr/bin/ceph-osd --cluster=ceph --show-config-value=fsid
[node1][WARNIN] activate: Cluster name is ceph
[node1][WARNIN] activate: OSD uuid is 6def4f7f-4f37-43a5-8699-5c6ab608c89c
[node1][WARNIN] activate: OSD id is 0
[node1][WARNIN] activate: Initializing OSD...
[node1][WARNIN] command_check_call: Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring mon getmap -o /var/local/osd0/activate.monmap
[node1][WARNIN] got monmap epoch 1
[node1][WARNIN] command: Running command: /usr/bin/timeout 300 ceph-osd --cluster ceph --mkfs --mkkey -i 0 --monmap /var/local/osd0/activate.monmap --osd-data /var/local/osd0 --osd-journal /var/local/osd0/journal --osd-uuid 6def4f7f-4f37-43a5-8699-5c6ab608c89c --keyring /var/local/osd0/keyring --setuser ceph --setgroup ceph
[node1][WARNIN] activate: Marking with init system upstart
[node1][WARNIN] activate: Authorizing OSD key...
[node1][WARNIN] command_check_call: Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring auth add osd.0 -i /var/local/osd0/keyring osd allow * mon allow profile osd
[node1][WARNIN] added key for osd.0
[node1][WARNIN] command: Running command: /bin/chown -R ceph:ceph /var/local/osd0/active.4616.tmp
[node1][WARNIN] activate: ceph osd.0 data dir is ready at /var/local/osd0
[node1][WARNIN] activate_dir: Creating symlink /var/lib/ceph/osd/ceph-0 -> /var/local/osd0
[node1][WARNIN] start_daemon: Starting ceph osd.0...
[node1][WARNIN] command_check_call: Running command: /sbin/initctl emit --no-wait -- ceph-osd cluster=ceph id=0
[node1][INFO  ] checking OSD status...
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /usr/bin/ceph --cluster=ceph osd stat --format=json
[node1][WARNIN] there is 1 OSD down
[node1][WARNIN] there is 1 OSD out

[node2][DEBUG ] connection detected need for sudo
[node2][DEBUG ] connected to host: node2
[node2][DEBUG ] detect platform information from remote host
[node2][DEBUG ] detect machine type
[node2][DEBUG ] find the location of an executable
[node2][INFO  ] Running command: sudo /sbin/initctl version
[node2][DEBUG ] find the location of an executable
[ceph_deploy.osd][INFO  ] Distro info: Ubuntu 14.04 trusty
[ceph_deploy.osd][DEBUG ] activating host node2 disk /var/local/osd1
[ceph_deploy.osd][DEBUG ] will use init type: upstart
[node2][DEBUG ] find the location of an executable
[node2][INFO  ] Running command: sudo /usr/sbin/ceph-disk -v activate --mark-init upstart --mount /var/local/osd1
[node2][WARNIN] main_activate: path = /var/local/osd1
[node2][WARNIN] activate: Cluster uuid is f5166c78-e3b6-4fef-b9e7-1ecf7382fd93
[node2][WARNIN] command: Running command: /usr/bin/ceph-osd --cluster=ceph --show-config-value=fsid
[node2][WARNIN] activate: Cluster name is ceph
[node2][WARNIN] activate: OSD uuid is 4733f683-0376-4708-86a6-818af987ade2
[node2][WARNIN] allocate_osd_id: Allocating OSD id...
[node2][WARNIN] command: Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring osd create --concise 4733f683-0376-4708-86a6-818af987ade2
[node2][WARNIN] command: Running command: /bin/chown -R ceph:ceph /var/local/osd1/whoami.27470.tmp
[node2][WARNIN] activate: OSD id is 1
[node2][WARNIN] activate: Initializing OSD...
[node2][WARNIN] command_check_call: Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring mon getmap -o /var/local/osd1/activate.monmap
[node2][WARNIN] got monmap epoch 1
[node2][WARNIN] command: Running command: /usr/bin/timeout 300 ceph-osd --cluster ceph --mkfs --mkkey -i 1 --monmap /var/local/osd1/activate.monmap --osd-data /var/local/osd1 --osd-journal /var/local/osd1/journal --osd-uuid 4733f683-0376-4708-86a6-818af987ade2 --keyring /var/local/osd1/keyring --setuser ceph --setgroup ceph
[node2][WARNIN] activate: Marking with init system upstart
[node2][WARNIN] activate: Authorizing OSD key...
[node2][WARNIN] command_check_call: Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring auth add osd.1 -i /var/local/osd1/keyring osd allow * mon allow profile osd
[node2][WARNIN] added key for osd.1
[node2][WARNIN] command: Running command: /bin/chown -R ceph:ceph /var/local/osd1/active.27470.tmp
[node2][WARNIN] activate: ceph osd.1 data dir is ready at /var/local/osd1
[node2][WARNIN] activate_dir: Creating symlink /var/lib/ceph/osd/ceph-1 -> /var/local/osd1
[node2][WARNIN] start_daemon: Starting ceph osd.1...
[node2][WARNIN] command_check_call: Running command: /sbin/initctl emit --no-wait -- ceph-osd cluster=ceph id=1
[node2][INFO  ] checking OSD status...
[node2][DEBUG ] find the location of an executable
[node2][INFO  ] Running command: sudo /usr/bin/ceph --cluster=ceph osd stat --format=json
没有错误报出！但OSD真的运行起来了吗？我们还需要再确认一下。

我们先通过ceph admin命令将各个.keyring同步到各个Node上，以便可以在各个Node上使用ceph命令连接到monitor：

注意：执行ceph admin前，需要在deploy-node的/etc/hosts中添加：

10.47.136.60 admin
执行ceph admin:

$ ceph-deploy admin admin node1 node2
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/cephd/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (1.5.35): /usr/bin/ceph-deploy admin admin node1 node2
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  overwrite_conf                : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf instance at 0x7f072ee3b758>
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  client                        : ['admin', 'node1', 'node2']
[ceph_deploy.cli][INFO  ]  func                          : <function admin at 0x7f072f6cf5f0>
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.admin][DEBUG ] Pushing admin keys and conf to admin
[admin][DEBUG ] connection detected need for sudo
[admin][DEBUG ] connected to host: admin
[admin][DEBUG ] detect platform information from remote host
[admin][DEBUG ] detect machine type
[admin][DEBUG ] find the location of an executable
[admin][INFO  ] Running command: sudo /sbin/initctl version
[admin][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph_deploy.admin][DEBUG ] Pushing admin keys and conf to node1
[node1][DEBUG ] connection detected need for sudo
[node1][DEBUG ] connected to host: node1
[node1][DEBUG ] detect platform information from remote host
[node1][DEBUG ] detect machine type
[node1][DEBUG ] find the location of an executable
[node1][INFO  ] Running command: sudo /sbin/initctl version
[node1][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf
[ceph_deploy.admin][DEBUG ] Pushing admin keys and conf to node2
[node2][DEBUG ] connection detected need for sudo
[node2][DEBUG ] connected to host: node2
[node2][DEBUG ] detect platform information from remote host
[node2][DEBUG ] detect machine type
[node2][DEBUG ] find the location of an executable
[node2][INFO  ] Running command: sudo /sbin/initctl version
[node2][DEBUG ] write cluster configuration to /etc/ceph/{cluster}.conf

$sudo chmod +r /etc/ceph/ceph.client.admin.keyring
接下来，查看一下ceph集群中的OSD节点状态：

$ ceph osd tree
ID WEIGHT  TYPE NAME             UP/DOWN REWEIGHT PRIMARY-AFFINITY
-1 0.07660 root default
-2 0.03830     host node1
 0 0.03830         osd.0            down        0          1.00000
-3 0.03830     host iZ25mjza4msZ
 1 0.03830         osd.1            down        0          1.00000
果不其然，两个osd节点均处于down状态，一个也没有启动起来。问题在哪？

我们来查看一下node1上的日志：/var/log/ceph/ceph-osd.0.log：

016-11-04 15:33:17.088971 7f568d6db800  0 pidfile_write: ignore empty --pid-file
2016-11-04 15:33:17.102052 7f568d6db800  0 filestore(/var/lib/ceph/osd/ceph-0) backend generic (magic 0xef53)
2016-11-04 15:33:17.102071 7f568d6db800 -1 filestore(/var/lib/ceph/osd/ceph-0) WARNING: max attr value size (1024) is smaller than osd_max_object_name_len (2048).  Your backend filesystem appears to not support attrs large enough to handle the configured max rados name size.  You may get unexpected ENAMETOOLONG errors on rados operations or buggy behavior
2016-11-04 15:33:17.102410 7f568d6db800  0 genericfilestorebackend(/var/lib/ceph/osd/ceph-0) detect_features: FIEMAP ioctl is disabled via 'filestore fiemap' config option
2016-11-04 15:33:17.102425 7f568d6db800  0 genericfilestorebackend(/var/lib/ceph/osd/ceph-0) detect_features: SEEK_DATA/SEEK_HOLE is disabled via 'filestore seek data hole' config option
2016-11-04 15:33:17.102445 7f568d6db800  0 genericfilestorebackend(/var/lib/ceph/osd/ceph-0) detect_features: splice is supported
2016-11-04 15:33:17.119261 7f568d6db800  0 genericfilestorebackend(/var/lib/ceph/osd/ceph-0) detect_features: syncfs(2) syscall fully supported (by glibc and kernel)
2016-11-04 15:33:17.127630 7f568d6db800  0 filestore(/var/lib/ceph/osd/ceph-0) limited size xattrs
2016-11-04 15:33:17.128125 7f568d6db800  1 leveldb: Recovering log #38
2016-11-04 15:33:17.136595 7f568d6db800  1 leveldb: Delete type=3 #37
2016-11-04 15:33:17.136656 7f568d6db800  1 leveldb: Delete type=0 #38
2016-11-04 15:33:17.136845 7f568d6db800  0 filestore(/var/lib/ceph/osd/ceph-0) mount: enabling WRITEAHEAD journal mode: checkpoint is not enabled
2016-11-04 15:33:17.137064 7f568d6db800 -1 journal FileJournal::_open: disabling aio for non-block journal.  Use journal_force_aio to force use of aio anyway
2016-11-04 15:33:17.137068 7f568d6db800  1 journal _open /var/lib/ceph/osd/ceph-0/journal fd 18: 5368709120 bytes, block size 4096 bytes, directio = 1, aio = 0
2016-11-04 15:33:17.137897 7f568d6db800  1 journal _open /var/lib/ceph/osd/ceph-0/journal fd 18: 5368709120 bytes, block size 4096 bytes, directio = 1, aio = 0
2016-11-04 15:33:17.138243 7f568d6db800  1 filestore(/var/lib/ceph/osd/ceph-0) upgrade
2016-11-04 15:33:17.138453 7f568d6db800 -1 osd.0 0 backend (filestore) is unable to support max object name[space] len
2016-11-04 15:33:17.138481 7f568d6db800 -1 osd.0 0    osd max object name len = 2048
2016-11-04 15:33:17.138485 7f568d6db800 -1 osd.0 0    osd max object namespace len = 256
2016-11-04 15:33:17.138488 7f568d6db800 -1 osd.0 0 (36) File name too long
2016-11-04 15:33:17.138895 7f568d6db800  1 journal close /var/lib/ceph/osd/ceph-0/journal
2016-11-04 15:33:17.140041 7f568d6db800 -1  ** ERROR: osd init failed: (36) File name too long
的确发现了错误日志：

2016-11-04 15:33:17.138481 7f568d6db800 -1 osd.0 0    osd max object name len = 2048
2016-11-04 15:33:17.138485 7f568d6db800 -1 osd.0 0    osd max object namespace len = 256
2016-11-04 15:33:17.138488 7f568d6db800 -1 osd.0 0 (36) File name too long
2016-11-04 15:33:17.138895 7f568d6db800  1 journal close /var/lib/ceph/osd/ceph-0/journal
2016-11-04 15:33:17.140041 7f568d6db800 -1  ** ERROR: osd init failed: (36) File name too long
进一步搜索ceph官方文档，发现在文件系统推荐这个doc中有提到，官方不建议采用ext4文件系统作为ceph的后端文件系统，如果采用，那么对于ext4的filesystem，应该在ceph.conf中添加如下配置：

osd max object name len = 256
osd max object namespace len = 64
由于配置已经分发到个个node上，我们需要到各个Node上同步修改：/etc/ceph/ceph.conf，添加上面两行。然后重新activate osd node，这里不赘述。重新激活后，我们来查看ceph osd状态：

$ ceph osd tree
ID WEIGHT  TYPE NAME             UP/DOWN REWEIGHT PRIMARY-AFFINITY
-1 0.07660 root default
-2 0.03830     host node1
 0 0.03830         osd.0              up  1.00000          1.00000
-3 0.03830     host iZ25mjza4msZ
 1 0.03830         osd.1              up  1.00000          1.00000

 $ceph -s
    cluster f5166c78-e3b6-4fef-b9e7-1ecf7382fd93
     health HEALTH_OK
     monmap e1: 1 mons at {node1=10.47.136.60:6789/0}
            election epoch 3, quorum 0 node1
     osdmap e11: 2 osds: 2 up, 2 in
            flags sortbitwise
      pgmap v29: 64 pgs, 1 pools, 0 bytes data, 0 objects
            37834 MB used, 38412 MB / 80374 MB avail
                  64 active+clean

$ !ps
ps -ef|grep ceph
ceph       17139       1  0 16:20 ?        00:00:00 /usr/bin/ceph-osd --cluster=ceph -i 0 -f --setuser ceph --setgroup ceph
可以看到ceph osd节点上的ceph-osd启动正常，cluster 状态为active+clean，至此，Ceph Cluster集群安装ok（我们暂不需要Ceph MDS组件）。

四、创建一个使用Ceph RBD作为后端Volume的Pod

在这一节中，我们就要将Ceph RBD与Kubenetes做集成了。Kubernetes的官方源码的examples/volumes/rbd目录下，就有一个使用cephrbd作为kubernetes pod volume的例子，我们试着将其跑起来。

例子提供了两个pod描述文件：rbd.json和rbd-with-secret.json。由于我们在ceph install时在ceph.conf中使用默认的安全验证协议cephx – The Ceph authentication protocol了：

auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
因此我们将采用rbd-with-secret.json这个pod描述文件来创建例子中的Pod，限于篇幅，这里仅节选json文件中的volumes部分：

//例子中的rbd-with-secret.json

{
    ... ...
        "volumes": [
            {
                "name": "rbdpd",
                "rbd": {
                    "monitors": [
                           "10.16.154.78:6789",
                           "10.16.154.82:6789",
                           "10.16.154.83:6789"
                                 ],
                    "pool": "kube",
                    "image": "foo",
                    "user": "admin",
                    "secretRef": {
                           "name": "ceph-secret"
                                         },
                    "fsType": "ext4",
                    "readOnly": true
                }
            }
        ]
    }
}
volumes部分是和ceph rbd紧密相关的一些信息，各个字段的大致含义如下：

name：volume名字，这个没什么可说的，顾名思义即可。
rbd.monitors：前面提到过ceph集群的monitor组件，这里填写monitor组件的通信信息，集群里有几个monitor就填几个；
rbd.pool：Ceph中的pool记号，它用来给ceph中存储的对象进行逻辑分区用的。默认的pool是”rbd”；
rbd.image：Ceph磁盘块设备映像文件；
rbd.user：ceph client访问ceph storage cluster所使用的用户名。ceph有自己的一套user管理系统，user的写法通常是TYPE.ID，比如client.admin（是不是想到对应的文件：ceph.client.admin.keyring）。client是一种type，而admin则是user。一般来说，Type基本都是client。
secret.Ref：引用的k8s secret对象名称。

上面的字段中，有两个字段值我们无法提供：rbd.image和secret.Ref，现在我们就来“填空”。我们在root用户下建立k8s-cephrbd工作目录，我们首先需要使用ceph提供的rbd工具创建Pod要用到image：

# rbd create foo -s 1024

# rbd list
foo
我们在rbd pool中(在上述命令中未指定pool name，默认image建立在rbd pool中)创建一个大小为1024Mi的ceph image foo，rbd list命令的输出告诉我们foo image创建成功。接下来，我们尝试将foo image映射到内核，并格式化该image：

root@node1:~# rbd map foo
rbd: sysfs write failed
RBD image feature set mismatch. You can disable features unsupported by the kernel with "rbd feature disable".
In some cases useful info is found in syslog - try "dmesg | tail" or so.
rbd: map failed: (6) No such device or address
map操作报错。不过从错误提示信息，我们能找到一些蛛丝马迹：“RBD image feature set mismatch”。ceph新版中在map image时，给image默认加上了许多feature，通过rbd info可以查看到：

# rbd info foo
rbd image 'foo':
    size 1024 MB in 256 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.10612ae8944a
    format: 2
    features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
    flags:
可以看到foo image拥有： layering, exclusive-lock, object-map, fast-diff, deep-flatten。不过遗憾的是我的Ubuntu 14.04的3.19内核仅支持其中的layering feature，其他feature概不支持。我们需要手动disable这些features：

# rbd feature disable foo exclusive-lock, object-map, fast-diff, deep-flatten
root@node1:/var/log/ceph# rbd info foo
rbd image 'foo':
    size 1024 MB in 256 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.10612ae8944a
    format: 2
    features: layering
    flags:
不过每次这么来disable可是十分麻烦的，一劳永逸的方法是在各个cluster node的/etc/ceph/ceph.conf中加上这样一行配置：

rbd_default_features = 1 #仅是layering对应的bit码所对应的整数值
设置完后，通过下面命令查看配置变化：

# ceph --show-config|grep rbd|grep features
rbd_default_features = 1
关于image features的这个问题，zphj1987的这篇文章中有较为详细的讲解。

我们再来map一下foo这个image：

# rbd map foo
/dev/rbd0

# ls -l /dev/rbd0
brw-rw---- 1 root disk 251, 0 Nov  5 10:33 /dev/rbd0
map后，我们就可以像格式化一个空image那样对其进行格式化了，这里格成ext4文件系统（格式化这一步大可不必，在后续小节中你会看到）：

# mkfs.ext4 /dev/rbd0
mke2fs 1.42.9 (4-Feb-2014)
Discarding device blocks: done
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=1024 blocks, Stripe width=1024 blocks
65536 inodes, 262144 blocks
13107 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=268435456
8 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
    32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
接下来我们来创建ceph-secret这个k8s secret对象，这个secret对象用于k8s volume插件访问ceph集群：

获取client.admin的keyring值，并用base64编码：

# ceph auth get-key client.admin
AQBiKBxYuPXiJRAAsupnTBsURoWzb0k00oM3iQ==

# echo "AQBiKBxYuPXiJRAAsupnTBsURoWzb0k00oM3iQ=="|base64
QVFCaUtCeFl1UFhpSlJBQXN1cG5UQnNVUm9XemIwazAwb00zaVE9PQo=
在k8s-cephrbd下建立ceph-secret.yaml文件，data下的key字段值即为上面得到的编码值：

//ceph-secret.yaml

apiVersion: v1
kind: Secret
metadata:
  name: ceph-secret
data:
  key: QVFCaUtCeFl1UFhpSlJBQXN1cG5UQnNVUm9XemIwazAwb00zaVE9PQo=
创建ceph-secret：

# kubectl create -f ceph-secret.yaml
secret "ceph-secret" created

# kubectl get secret
NAME                  TYPE                                  DATA      AGE
ceph-secret           Opaque                                1         16s
至此，我们的rbd-with-secret.json全貌如下：

{
    "apiVersion": "v1",
    "kind": "Pod",
    "metadata": {
        "name": "rbd2"
    },
    "spec": {
        "containers": [
            {
                "name": "rbd-rw",
                "image": "kubernetes/pause",
                "volumeMounts": [
                    {
                        "mountPath": "/mnt/rbd",
                        "name": "rbdpd"
                    }
                ]
            }
        ],
        "volumes": [
            {
                "name": "rbdpd",
                "rbd": {
                    "monitors": [
                        "10.47.136.60:6789"
                                 ],
                    "pool": "rbd",
                    "image": "foo",
                    "user": "admin",
                    "secretRef": {
                        "name": "ceph-secret"
                        },
                    "fsType": "ext4",
                    "readOnly": true
                }
            }
        ]
    }
}
基于该Pod描述文件，创建使用cephrbd作为后端存储的pod：

# kubectl create -f rbd-with-secret.json
pod "rbd2" created

# kubectl get pod
NAME                        READY     STATUS    RESTARTS   AGE
rbd2                        1/1       Running   0          16s

# rbd showmapped
id pool image snap device
0  rbd  foo   -    /dev/rbd0

# mount
... ...
/dev/rbd0 on /var/lib/kubelet/plugins/kubernetes.io/rbd/rbd/rbd-image-foo type ext4 (rw)
在我的环境中，pod实际被调度到了另外一个k8s node上运行了：

pod被调度到另外一个 node2 上：

# docker ps
CONTAINER ID        IMAGE                                          COMMAND                  CREATED             STATUS              PORTS                    NAMES
32f92243f911        kubernetes/pause                               "/pause"                 2 minutes ago       Up 2 minutes                                 k8s_rbd-rw.c1dc309e_rbd2_default_6b6541b9-a306-11e6-ba01-00163e1625a9_a6bb1b20

#docker inspect 32f92243f911
... ...
"Mounts": [
            {
                "Source": "/var/lib/kubelet/pods/6b6541b9-a306-11e6-ba01-00163e1625a9/volumes/kubernetes.io~secret/default-token-40z0x",
                "Destination": "/var/run/secrets/kubernetes.io/serviceaccount",
                "Mode": "ro",
                "RW": false,
                "Propagation": "rprivate"
            },
            {
                "Source": "/var/lib/kubelet/pods/6b6541b9-a306-11e6-ba01-00163e1625a9/etc-hosts",
                "Destination": "/etc/hosts",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Source": "/var/lib/kubelet/pods/6b6541b9-a306-11e6-ba01-00163e1625a9/containers/rbd-rw/a6bb1b20",
                "Destination": "/dev/termination-log",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Source": "/var/lib/kubelet/pods/6b6541b9-a306-11e6-ba01-00163e1625a9/volumes/kubernetes.io~rbd/rbdpd",
                "Destination": "/mnt/rbd",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
... ...
五、Kubernetes Persistent Volume和Persistent Volume Claim

上面一小节讲解了Kubernetes volume与Ceph RBD的结合，但是k8s volume还不能完全满足实际生产过程对持久化存储的需求，因为k8s volume的lifetime和pod的生命周期相同，一旦pod被delete，那么volume中的数据就不复存在了。于是k8s又推出了Persistent Volume(PV)和Persistent Volume Claim(PVC)组合，故名思意：即便挂载其的pod被delete了，PV依旧存在，PV上的数据依旧存在。

由于有了之前的“铺垫”，这里仅仅给出使用PV和PVC的步骤：

1、创建disk image

$ rbd create ceph-image -s 128 #考虑后续format快捷，这里只用了128M，仅适用于Demo哦。

# rbd create ceph-image -s 128
# rbd info rbd/ceph-image
rbd image 'ceph-image':
    size 128 MB in 32 objects
    order 22 (4096 kB objects)
    block_name_prefix: rbd_data.37202ae8944a
    format: 2
    features: layering
    flags:
如果这里不先创建一个ceph-image，后续Pod启动时，会出现如下的一些错误，比如pod始终处于ContainerCreating状态：

# kubectl get pod
NAME                        READY     STATUS              RESTARTS   AGE
ceph-pod1                   0/1       ContainerCreating   0          13s

如果出现这种错误情况，可以查看/var/log/upstart/kubelet.log，你也许能看到如下错误信息：

I1107 06:02:27.500247   22037 operation_executor.go:768] MountVolume.SetUp succeeded for volume "kubernetes.io/secret/01d049c6-9430-11e6-ba01-00163e1625a9-default-token-40z0x" (spec.Name: "default-token-40z0x") pod "01d049c6-9430-11e6-ba01-00163e1625a9" (UID: "01d049c6-9430-11e6-ba01-00163e1625a9").
I1107 06:03:08.499628   22037 reconciler.go:294] MountVolume operation started for volume "kubernetes.io/rbd/ea848a49-a46b-11e6-ba01-00163e1625a9-ceph-pv" (spec.Name: "ceph-pv") to pod "ea848a49-a46b-11e6-ba01-00163e1625a9" (UID: "ea848a49-a46b-11e6-ba01-00163e1625a9").
E1107 06:03:09.532348   22037 disk_manager.go:56] failed to attach disk
E1107 06:03:09.532402   22037 rbd.go:228] rbd: failed to setup mount /var/lib/kubelet/pods/ea848a49-a46b-11e6-ba01-00163e1625a9/volumes/kubernetes.io~rbd/ceph-pv rbd: map failed exit status 2 rbd: sysfs write failed
In some cases useful info is found in syslog - try "dmesg | tail" or so.
rbd: map failed: (2) No such file or directory
2、创建PV

我们直接复用之前创建的ceph-secret对象，PV的描述文件ceph-pv.yaml如下：

apiVersion: v1
kind: PersistentVolume
metadata:
  name: ceph-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  rbd:
    monitors:
      - 10.47.136.60:6789
    pool: rbd
    image: ceph-image
    user: admin
    secretRef:
      name: ceph-secret
    fsType: ext4
    readOnly: false
  persistentVolumeReclaimPolicy: Recycle
执行创建操作：

# kubectl create -f ceph-pv.yaml
persistentvolume "ceph-pv" created

# kubectl get pv
NAME      CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM     REASON    AGE
ceph-pv   1Gi        RWO           Recycle         Available                       7s
3、创建PVC

pvc是Pod对Pv的请求，将请求做成一种资源，便于管理以及pod复用。我们用到的pvc描述文件ceph-pvc.yaml如下：

kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: ceph-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

执行创建操作：

# kubectl create -f ceph-pvc.yaml
persistentvolumeclaim "ceph-claim" created

# kubectl get pvc
NAME         STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
ceph-claim   Bound     ceph-pv   1Gi        RWO           12s

4、创建挂载ceph RBD的pod

pod描述文件ceph-pod1.yaml如下：

apiVersion: v1
kind: Pod
metadata:
  name: ceph-pod1
spec:
  containers:
  - name: ceph-busybox1
    image: busybox
    command: ["sleep", "600000"]
    volumeMounts:
    - name: ceph-vol1
      mountPath: /usr/share/busybox
      readOnly: false
  volumes:
  - name: ceph-vol1
    persistentVolumeClaim:
      claimName: ceph-claim
创建pod操作：

# kubectl create -f ceph-pod1.yaml
pod "ceph-pod1" created

# kubectl get pod
NAME                        READY     STATUS              RESTARTS   AGE
ceph-pod1                   0/1       ContainerCreating   0          13s
Pod还处于ContainerCreating状态。pod的创建，尤其是挂载pv的Pod的创建需要一小段时间，耐心等待一下，我们可以查看一下/var/log/upstart/kubelet.log：

I1107 11:44:38.768541   22037 mount_linux.go:272] `fsck` error fsck from util-linux 2.20.1

fsck.ext2: Bad magic number in super-block while trying to open /dev/rbd1
/dev/rbd1:
The superblock could not be read or does not describe a valid ext2/ext3/ext4
filesystem.  If the device is valid and it really contains an ext2/ext3/ext4
filesystem (and not swap or ufs or something else), then the superblock
is corrupt, and you might try running e2fsck with an alternate superblock:
    e2fsck -b 8193 <device>
 or
    e2fsck -b 32768 <device>

E1107 11:44:38.774080   22037 mount_linux.go:110] Mount failed: exit status 32
Mounting arguments: /dev/rbd1 /var/lib/kubelet/plugins/kubernetes.io/rbd/rbd/rbd-image-ceph-image ext4 [defaults]
Output: mount: wrong fs type, bad option, bad superblock on /dev/rbd1,
       missing codepage or helper program, or other error
       In some cases useful info is found in syslog - try
       dmesg | tail  or so

I1107 11:44:38.839148   22037 mount_linux.go:292] Disk "/dev/rbd1" appears to be unformatted, attempting to format as type: "ext4" with options: [-E lazy_itable_init=0,lazy_journal_init=0 -F /dev/rbd1]
I1107 11:44:39.152689   22037 mount_linux.go:297] Disk successfully formatted (mkfs): ext4 - /dev/rbd1 /var/lib/kubelet/plugins/kubernetes.io/rbd/rbd/rbd-image-ceph-image
I1107 11:44:39.220223   22037 operation_executor.go:768] MountVolume.SetUp succeeded for volume "kubernetes.io/rbd/811a57ee-a49c-11e6-ba01-00163e1625a9-ceph-pv" (spec.Name: "ceph-pv") pod "811a57ee-a49c-11e6-ba01-00163e1625a9" (UID: "811a57ee-a49c-11e6-ba01-00163e1625a9").
可以看到，k8s通过fsck发现这个image是一个空image，没有fs在里面，于是默认采用ext4为其格式化，成功后，再行挂载。等待一会后，我们看到ceph-pod1成功run起来了：

# kubectl get pod
NAME                        READY     STATUS    RESTARTS   AGE
ceph-pod1                   1/1       Running   0          4m

# docker ps
CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS              PORTS               NAMES
f50bb8c31b0f        busybox                                               "sleep 600000"           4 hours ago         Up 4 hours                              k8s_ceph-busybox1.c0c0379f_ceph-pod1_default_811a57ee-a49c-11e6-ba01-00163e1625a9_9d910a29

# docker exec 574b8069e548 df -h
Filesystem                Size      Used Available Use% Mounted on
none                     39.2G     20.9G     16.3G  56% /
tmpfs                     1.9G         0      1.9G   0% /dev
tmpfs                     1.9G         0      1.9G   0% /sys/fs/cgroup
/dev/vda1                39.2G     20.9G     16.3G  56% /dev/termination-log
/dev/vda1                39.2G     20.9G     16.3G  56% /etc/resolv.conf
/dev/vda1                39.2G     20.9G     16.3G  56% /etc/hostname
/dev/vda1                39.2G     20.9G     16.3G  56% /etc/hosts
shm                      64.0M         0     64.0M   0% /dev/shm
/dev/rbd1               120.0M      1.5M    109.5M   1% /usr/share/busybox
tmpfs                     1.9G     12.0K      1.9G   0% /var/run/secrets/kubernetes.io/serviceaccount
tmpfs                     1.9G         0      1.9G   0% /proc/kcore
tmpfs                     1.9G         0      1.9G   0% /proc/timer_list
tmpfs                     1.9G         0      1.9G   0% /proc/timer_stats
tmpfs                     1.9G         0      1.9G   0% /proc/sched_debug
六、简单测试

这一节我们要对cephrbd作为k8s PV的效用做一个简单测试。测试步骤：

1) 在container中，向挂载的cephrbd写入数据；
2) 删除ceph-pod1
3) 重新创建ceph-pod1，查看数据是否还存在。

我们首先通过touch 、vi等命令向ceph-pod1挂载的cephrbd volume写入数据：我们通过容器f50bb8c31b0f 创建/usr/share/busybox/hello-ceph.txt，并向文件写入”hello ceph”一行字符串并保存。

# docker exec -it f50bb8c31b0f touch /usr/share/busybox/hello-ceph.txt
# docker exec -it f50bb8c31b0f vi /usr/share/busybox/hello-ceph.txt
# docker exec -it f50bb8c31b0f cat /usr/share/busybox/hello-ceph.txt
hello ceph
接下来删除ceph-pod1：

# kubectl get pod
NAME                        READY     STATUS    RESTARTS   AGE
ceph-pod1                   1/1       Running   0          4h

# kubectl delete pod/ceph-pod1
pod "ceph-pod1" deleted

# kubectl get pod
NAME                        READY     STATUS        RESTARTS   AGE
ceph-pod1                   1/1       Terminating   0          4h

# kubectl get pv,pvc
NAME         CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS    CLAIM                REASON    AGE
pv/ceph-pv   1Gi        RWO           Recycle         Bound     default/ceph-claim             4h
NAME             STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
pvc/ceph-claim   Bound     ceph-pv   1Gi        RWO           4h

可以看到ceph-pod1的删除需要一段时间，这段时间pod一直处于“ Terminating”状态。同时，我们看到pod的删除并没有影响到pv和pvc object，它们依旧存在。

最后，我们再次来创建一下一个使用同一个pvc的pod，为了避免“不必要”的麻烦，我们建立一个名为ceph-pod2.yaml的描述文件：

apiVersion: v1
kind: Pod
metadata:
  name: ceph-pod2
spec:
  containers:
  - name: ceph-busybox2
    image: busybox
    command: ["sleep", "600000"]
    volumeMounts:
    - name: ceph-vol2
      mountPath: /usr/share/busybox
      readOnly: false
  volumes:
  - name: ceph-vol2
    persistentVolumeClaim:
      claimName: ceph-claim
创建ceph-pod2：

# kubectl create -f ceph-pod2.yaml
pod "ceph-pod2" created

root@node1:~/k8stest/k8s-cephrbd# kubectl get pod
NAME                        READY     STATUS    RESTARTS   AGE
ceph-pod2                   1/1       Running   0          14s

root@node1:~/k8stest/k8s-cephrbd# docker ps
CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS              PORTS               NAMES
574b8069e548        busybox                                               "sleep 600000"           11 seconds ago      Up 10 seconds                           k8s_ceph-busybox2.c5e637a1_ceph-pod2_default_f4aeebd6-a4c3-11e6-ba01-00163e1625a9_fc94c0fe
查看数据是否依旧存在：

# docker exec -it 574b8069e548 cat /usr/share/busybox/hello-ceph.txt
hello ceph
数据完好无损的被ceph-pod2读取到了！

七、小结

至此，对k8s与ceph的集成仅仅才是一个开端，更多的feature和坑等待挖掘。近期发现文章越写越长，原因么？自己赶脚是因为目标系统越来越大，越来越复杂。深入K8s的过程，就是继续给自己挖坑的过程^_^。

我，不是在填坑的路上，就是在坑里:)。

BTW，列一下参考资料：
1、Ceph官方文档；
2、OpenShift中的K8s与Ceph RBD集成的文档;
3、Kubernetes官方文档Persistent volumes部分；
4、zphj1987博主的这篇文章。