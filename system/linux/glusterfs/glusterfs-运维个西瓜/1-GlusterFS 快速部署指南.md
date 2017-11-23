

【一】GlusterFS 快速部署指南 - CSDN博客 
http://blog.csdn.net/watermelonbig/article/details/49160681


# 一、GlusterFS 快速部署指南

本章节将指导你在最短时间内，成功地快速部署完成一套GlusterFS管理系统。然后基于我们刚刚部署完成的GlusterFS系统，再深入说明系统架构原理和管理员需要具备的相关技能要求。对于测试环境可以使用/etc/hosts来定义主机名与IP的映射关系，对于生产环境建议部署DNS服务提供解析服务。此外，生产环境中使用GlusterFS，应该部署和使用NTP服务器。

# 1．准备两台主机

CentOS7 操作系统（xfs文件系统）；
主机名分别命名为server1和server2；
一块网卡；
每台主机至少两块磁盘，一块用于安装OS，其它的用于GlusterFS storage；
GlusterFS 默认地把动态生成的`配置数据存放于/var/lib/glusterd`目录下，`日志数据放于/var/log`下，请确保它们所在的分区空间足够多，避免因磁盘满而导致GlusterFS 运行故障或服务当机；

# 2．格式化并挂接存储块（bricks）

我们假定每个主机的/dev/sdb1分区，是用于GlusterFS 使用的存储块brick。

```sh
mkfs.xfs -i size=512 /dev/sdb1    
mkdir -p /data/brick1    
echo '/dev/sdb1 /data/brick1 xfs defaults 1 2' >> /etc/fstab    
mount -a && mount  
```

# 3．安装GlusterFS 软件包

```sh
    #yum install glusterfs-server
启动GlusterFS 的后台管理进程：
    #service glusterd start    
#service glusterd status    
glusterd.service - LSB: glusterfs server           Loaded: loaded (/etc/rc.d/init.d/glusterd)       Active: active (running) since Mon, 13 Aug 2012 13:02:11 -0700; 2s ago      Process: 19254 ExecStart=/etc/rc.d/init.d/glusterd start (code=exited, status=0/SUCCESS)       CGroup: name=systemd:/system/glusterd.service           ├ 19260 /usr/sbin/glusterd -p /run/glusterd.pid           ├ 19304 /usr/sbin/glusterfsd --xlator-option georep-server.listen-port=24009 -s localhost...           └ 19309 /usr/sbin/glusterfs -f /var/lib/glusterd/nfs/nfs-server.vol -p /var/lib/glusterd/...
``` 

# 4．设置可信任的存储池

```sh
# 在主机server1上：
gluster peer probe server2
# 在主机server2上：
gluster peer probe server1
# 注：请为两台主机基于/etc/hosts做好相互之间的主机名和IP的解析映射。
一旦设置了可信的存储池，就会仅允许存储池中的被信任的节点主动发现其它的新节点，并将其加入到池中。而一个独立的新节点，是不被允许自行加入可信存储池中的。
# 查看存储池状态：
gluster peer status
# 从存储池中移除指定服务器：
gluster peer detach server2
```

# 5．建立一个GlusterFS 卷

* GlusterFS 卷共有三基本类型
  * Distributed（分布存储）
  * Striped（将一个文件分成多个固定长度的数据，分布存放在所有存储块，相当于RAID0）
  * Replicated（镜像存储，相当于RAID1）。
  
基于striped和replicated，结合使用distributed后，又可以扩展出分布式分片存储卷和分布式镜像存储卷两种新的类型。而后两种扩展类型并没有新的命令格式，仅是通过设置数据冗余份数和添加进逻辑卷的bricks数量来动态定义的。详情可参见第二章关于GlusterFS体系结构的相关内容。

## 5.1 创建一个GlusterFS Replicated卷

```sh
#在两台主机上：
mkdir -p /data/brick1/gv0
#在两台主机中的任一个上面执行以下命令：
gluster volume create gv0 replica 2 server1:/data/brick1/gv0 server2:/data/brick1/gv0 #gluster volume start gv0
#查看存储卷的状态：
gluster volume info
#如果以上操作遇到报错，请查看/var/log/glusterfs下的日志，以定位和排错。
```

## 5.2 创建Distributed逻辑卷

```sh
# gluster volume create gv1 server1:/data server2:/data
# gluster volume info
# gluster volume start gv1
```

## 5.3 创建Striped逻辑卷

```sh
# 创建一个名字为gv2，包含两个存储块，使用TCP协议的Striped逻辑卷:
gluster volume create gv2 stripe 2 transport tcp server1:/data server2:/data
gluster volume info
gluster volume start gv2
```
## 5.4 停止GlusterFS逻辑卷或删除GlusterFS逻辑卷
```sh
gluster volume stop gv0
gluster volume delete gv0
```

## 5.5 与存储块brick相关的逻辑卷管理
```sh
在gv0卷中增加一个存储块server3:/data：
# gluster volume add-brick gv0 server3:/data
# gluster volume rebalance gv0 start
删除Brick:
# gluster volume remove-brick gv0 server3:/data
# gluster volume rebalance gv0 start
```

# 6．测试GlusterFS 卷

```sh
到这里，我们已经可以把GlusterFS 卷挂接到一个客户端主机上去了。在此之前，可以先使用以上两台server主机进行下简单的测试。任选一台然后执行以下命令。
#mount -t glusterfs server1:/gv0 /mnt#for i in `seq -w 1 100`; do cp -rp /var/log/messages /mnt/copy-test-$i; done
先检查一下挂接点：
    #ls -lA /mnt | wc -l
你应该可以看到已经拷贝进去的100个文件。而且你应该是可以在server1和server2的/mnt目录下各看到100个文件。
```