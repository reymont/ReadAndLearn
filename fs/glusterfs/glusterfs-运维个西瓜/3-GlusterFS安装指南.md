

【三】GlusterFS安装指南 - CSDN博客 
http://blog.csdn.net/watermelonbig/article/details/49227533

三、GlusterFS安装指南

如果你需要了解和掌握更多的GlusterFS安装过程中的详细信息，可以参考本章内容。如果只是需要快速安装并使用，则请参考第一章的快速部署指南。在参照本章内容部署了GlusterFS系统后，我们建议你可以继续读一读后续的Gluster管理员手册内容，来了解怎样管理Gluster和怎样选取自己需要使用的逻辑卷类型。
1. 什么是GlusterFS

GlusterFS是一个分布式的可横向扩展的文件系统，支持快速扩充更多的存储空间。自动地失效转移是它的一项基础功能。GlusterFS没有一个集中式的元数据管理服务。
你可以尽可能多得向GlusterFS中添加存储，即使在使用中发现存储不足了，也可以通过简单的几个步骤完成添加新存储空间的工作。
你可以设置为自动处理失效转移，这样即可在一个主机节点当机后，你仍然可以访问你的数据，不需要手工干预。当你修复了故障主机并重新上线后，你也不需要做任何手工干预。
可以使用传统的NFS,SMB/CIFS协议访问GlusterFS的数据，也可以直接使用一个本地化的GlusterFS文件系统。
GlusterFS不适合于存储结构化数据，建议不要直接作为数据库的数据存储空间使用，存储数据库的备份数据并没有问题。一般地，我们建议使用GlusterFS存储的数据应该是大小大于16KB的文件。当然如果能大于128KB，效果会更好。
建议存储主机使用XFS的文件系统，当然EXT4也还不错。
在生产环境中使用GlusterFS，建议部署DNS和NTP服务。
在安装主机的操作系统时，不需要对用于GlusterFS的分区进行格式化，因为在创建GlusterFS集群时会对加入到逻辑卷的brick进行特殊的格式化处理。
建议关闭系统防火墙。
2. GlusterFS部署

需要准备两个运行64位系统且可以通过网络互连的主机。当用于生产环境时，建议内存大于8GB。
2.1 在每个节点上安装Gluster软件包
[plain] view plain copy
#wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/LATEST/RHEL/glusterfs-epel.repo  
#yum install glusterfs-server  

注：以上为RedHat/CentOS上的例子。
2.2 配置
1) 系统防火墙
[plain] view plain copy
#iptables -I INPUT -p all -s `<ip-address>` -j ACCEPT  
需要在可信主机池中的各节点间均打开相互之间的访问策略。
2) 配置可信主机池
可信主机池定义了可以作为Gluster节点使用的主机列表。你需要从中选出一个主要的（primary）节点。当然，这只是为了管理方便。实际上，你可以在Gluster集群中的任一个节点上执行管理命令，而能得到的效果是相同的。
[plain] view plain copy
#gluster peer probe (hostname of the other server in the cluster, or IP address if you don’t have DNS or /etc/hosts entries)  

注意：第一个节点是不能probe自己的，可以从已经被加入可信池的其它节点上probe第一个节点。
3) 分区、格式化和挂接bricks
[plain] view plain copy
fdisk /dev/sdb and create a single partition  
mkfs.xfs -i size=512 /dev/sdb1  
mkdir -p /export/sdb1 && mount /dev/sdb1 /export/sdb1 && mkdir -p /export/sdb1/brick  
echo "/dev/sdb1 /export/sdb1 xfs defaults 0 0"  >> /etc/fstab  


4) 创建逻辑存储卷
[plain] view plain copy
#gluster volume create gv0 replica 2 node01.mydomain.net:/export/sdb1/brick node02.mydomain.net:/export/sdb1/brick  
#gluster volume info  
Volume Name: gv0   
Type: Replicate   
Volume ID: 8bc3e96b-a1b6-457d-8f7a-a91d1d4dc019   
Status: Created   
Number of Bricks: 1 x 2 = 2   
Transport-type: tcp   
Bricks: Brick1: node01.yourdomain.net:/export/sdb1/brick Brick2: node02.yourdomain.net:/export/sdb1/brick  


5) 启动逻辑卷
[plain] view plain copy
#gluster volume start gv0  
注：在上一步中的”Status”参数中，显示卷的状态是Created，所以该卷只是完成了创建，还没有启动。