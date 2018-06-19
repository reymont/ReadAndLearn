
基于 GlusterFS 实现 Docker 集群的分布式存储 
https://www.ibm.com/developerworks/cn/opensource/os-cn-glusterfs-docker-volume/index.html

* 开源的分布式文件系统
  * GFS
  * Ceph
  * HDFS
  * FastDFS
  * GlusterFS

# GlusterFS 分布式文件系统简介

* GlusterFS 概述
  * `横向扩展`，支持PB集存储容量
  * GlusterFS借助`TCP/IP或InfiniBand RDMA网络`将物理分布的存储资源聚集在一起
  * 使用`单一全局命名空间`来管理数据
  * GlusterFS基于`可堆叠`的用户空间设计，为各种不同的数据负载提供优异的性能
* GlusterFS总体架构与组成部分
  * 存储服务器Brick Server
  * 客户端
  * NFS/Samba存储网关
* GlusterFS架构中没有元数据服务器组件
* GlusterFS架构特点
  * 支持TCP/IP和InfiniBand RDMA高速网络互联
  * 原生GlusterFS协议或NFS/CIFS标准协议通过存储网关访问数据
  * 存储网关提供弹性卷管理和访问代理功能
  * 存储服务器主要提供基本的数据存储功能
  * 客户端弥补没有元数据服务器的问题
    * 数据卷管理
    * I/O调度
    * 文件定位
    * 数据缓存
    * 利用FUSE(File system in User Space)模块将GlusterFS挂载到本地文件系统之上
    * 兼容POSIX访问数据
* GlusterFS常见术语
  * Brick：最基本的存储单元，表示为trusted storage pool中输出的目录，供客户端挂载用
  * Volume：一个卷。在逻辑上由N个bricks组成
  * FUSE：Unix-like OS上的可动态加载的模块，允许用户`不用修改内核即可创建自己的文件系统`
  * Glusterd：Gluster management daemon，要在trusted storage pool中所有的服务器上运行
  * POSIX：一个标准，Gluster兼容
* GlusterFS卷类型
  * 支持7种卷
  * 3种基本卷和4种复合卷
  * 基本卷
    * distribute volume分布式卷
      * 基于hash算法将文件分布到所有brick server
      * 扩大了磁盘空间，不具备容错能力
      * 使用本地文件系统，存取效率并没有提高
      * 本地存储设备的容量限制，支持超大型文件会有一定难度
    * stripe volume条带卷
      * 类似RAID0，文件分成数据块以`Round Robin`方式分布到brick server上
      * `并发粒度是数据块`，支持超大文件，大文件的读写性能高
    * replica volume复制卷
      * 类似RAID1，文件同步复制到多个brick上
      * 具有容错能力，写性能下降，读性能提升
      * 每个replicated子节点有着相同的目录结构和文件
    * distributed strip volume分布式条带卷
      * 兼顾分布式和条带式的功能
    * distributed replica volume
    * stripe replica volume
    * distribute stripe replica volume
* GlusterFS常用命令
  * gluster peer probe	添加节点
  * gluster peer detach	移除节点
  * gluster volume create	创建卷
  * gluster volume start	启动卷
  * gluster volume stop	停止卷
  * gluster volume delete	删除卷
  * gluster volume quota enable	开启卷配额
  * gluster volume quota enable	关闭卷配额
  * gluster volume quota limit-usage	设定卷配额

# GlusterFS 分布式文件系统安装与配置

```sh
# (1). 格式化磁盘
fdisk /dev/sdb
命令行提示下输入【m】
输入命令【n】添加新分区
输入命令【p】创建主分区
输入【回车】，选择默认大小，这样不浪费空间
输入【回车】，选择默认的start cylinder
输入【w】，保持修改
 
# (2). 添加gluster源
cat >>/etc/apt/sources.list <<EOF
deb http://ppa.launchpad.net/gluster/glusterfs-3.7/ubuntu trusty main
deb-src http://ppa.launchpad.net/gluster/glusterfs-3.7/ubuntu trusty main
EOF
 
# (3). 安装glusterfs
apt-get install xfsprogs glusterfs-server -y
mkfs.xfs -i size=512 /dev/sdb1
mkdir -p /glusterfs/brick  #挂载点
echo '/dev/sdb1 /glusterfs/brick xfs defaults 1 2' >> /etc/fstab #设置自动挂载
mount -a && mount
gluster volume set all cluster.op-version 30710
 
# (4). 配置peer
gluster peer probe <IP|HOSTNAME>
gluster peer status
 
# (5). 当出现下列信息时表示集群搭建成功
gluster peer status
Number of Peers: 1
 
Hostname: 192.168.1.101
Uuid: 8d836e09-f217-488b-971c-be9206a197f6
State: Peer in Cluster (Connected)
 
# (6). 创建Volume
gluster volume create <VOLUME_NAME> replica 2 \
node1: /glusterfs/brick/<VOLUME_NAME> \
node2: /glusterfs/brick/<VOLUME_NAME>
 
# (7). 启动Volume
gluster volume start <VOLUME_NAME>
```


GlusterFS 客户端配置
清单2. GlusterFS 客户端配置

```sh
# (1). 添加gluster源
cat >>/etc/apt/sources.list <<EOF
deb http://ppa.launchpad.net/gluster/glusterfs-3.7/ubuntu trusty main
deb-src http://ppa.launchpad.net/gluster/glusterfs-3.7/ubuntu trusty main
EOF
 
# (2). 安装glusterfs client
apt-get install glusterfs-client -y
 
# (3). 挂载gluster卷
glusterfs node1:<VOLUME_NAME> /mnt/local-volume
至此，我们就挂载好了GlusterFS集群中的一个Replica类型的卷，所有写入该卷中的数据都会在集群中有两份拷贝。
```

# Docker GlusterFS Volume 插件
接下来，我们再来看GlusterFS如何作为Docker的存储。Docker Volume是一种可以将容器以及容器生产的数据分享开来的数据格式，我们可以使用宿主机的本地存储作为Volume的提供方，也可以使用Volume Plugin接入许多第三方的存储。 GitHub就有一个Docker GlusterFS Volume Plugin，方便我们将GlusterFS挂载到容器中。具体步骤如下：

https://github.com/calavera/docker-volume-glusterfs.git
https://github.com/sapk/docker-volume-gluster.git

清单3. 安装 Docker GlusterFS Volume 插件

```sh
# (1). 获取docker-volume-glusterfs
go get github.com/calavera/docker-volume-glusterfs
考虑到搭建golang环境有一定的复杂性，我们也可以采用golang容器来获取该应用
 
# (2). 拷贝docker-volume-glusterfs至/usr/bin
cp ./docker-volume-glusterfs /usr/bin
chmod 777 /usr/bin/docker-volume-glusterfs
 
# (3). 声明gluster服务集群
docker-volume-glusterfs -servers node1:node2
 
# (4). 指定volume
docker run --volume-driver glusterfs --volume datastore:/data alpine touch /data/hello
这里的datastore即我们在glusterfs集群中创建的volume，但需要事先手动创建
```


# GlusterFS REST API 服务搭建
上述步骤虽然实现了 GlusterFS 作为 Docker 存储方案，但 GlusterFS 卷仍需要手动创建。为了自动化地管理 GlusterFS 卷，我们将卷操作封装成 REST API。 GitHub上的 glusterfs-rest 将 GlusterFS 基础操作使用 Python 封装成了 REST API，但是它没有将 Volume 容量限制等功能封装起来，而我们项目中这个功能又是必须的，不过稍加修改后就可以实现容量限制的功能。
清单4. 添加 Volume 容量限制功能

```sh
# (1). 克隆代码
git clone <a href="https://github.com/aravindavk/glusterfs-rest.git"><code>https://github.com/aravindavk/glusterfs-rest.git</code></a>
 
# (2). 修改glusterfs-rest/glusterfsrest/cli/ volume.py create方法
def create(name, bricks, replica=0, stripe=0, transport='tcp', force=False,
           start_volume=False,limit=False,quota=1):
    cmd = VOLUME_CMD + ["create", name]
    if stripe > 0:
        cmd += ["stripe", str(stripe)]
 
    if replica > 0:
        cmd += ["replica", str(replica)]
 
    cmd += ["transport", transport]
 
    cmd += bricks
 
    if force:
        cmd += ["force"]
 
    # If volume needs to be started, then run create command without
    # decorator else return create command and status zero true
    # decorator will take care of running cmd
    if start_volume:
        utils.checkstatuszero(cmd)
        if limit:
            enable_cmd = VOLUME_CMD + ["quota",name,"enable"]
            quota_cmd = VOLUME_CMD +["quota",name,"limit-usage","/",str(quota)+"GB"]
            start(name, force=True)
            utils.checkstatuszero(enable_cmd)
            return utils.checkstatuszero(quota_cmd)
        else:
            return start(name, force=True)
    else:
        return utils.checkstatuszero(cmd)
# (3). 修改glusterfs-rest/glusterfsrest/doc/api-1.0.yml Create内容
# -----------------------------------------------------------------------------
# Create Gluster Volume
# -----------------------------------------------------------------------------
    - title: Create Gluster Volume
      auth: true
      url: volume/:name
      category: volume
      method: POST
      params:
        - name: bricks
          type: string
          required: true
          example: "bricksserver1:/exports/bricks/b1"
          desc: Comma seperated Brick paths
 
        - name: replica
          type: int
          required: false
          example: 1
          desc: Replica Count
          default: 0
 
        - name: stripe
          type: int
          required: false
          example: 1
          desc: Stripe Count
          default: 0
 
        - name: transport
          type: int
          required: false
          example: tcp
          desc: Transport Type, available types "tcp", "rdma", "tcp,rdma"
          default: tcp
 
        - name: force
          type: int
          required: false
          example: 1
          desc: Volume create force
          default: 0
 
        - name: start
          type: int
          required: false
          example: 1
          desc: Start volume after create
          default: 0
 
        - name: limit
          type: int
          required: false
          example: 1
          desc: Limit volume after start
          default: 0
 
        - name: quota
          type: int
          required: false
          example: 1
          desc: Set Quota if limit
          default: 1
      example: |
 
        curl -X POST http://admin:secret123@localhost:9000/api/1.0/volume/gv1 -d \
        "bricks=bricksserver1:/exports/bricks/b1,bricksserver2:/exports/bricks/b2&start=1&replica=2&limit=1&quota=2"
 
      response: |
 
        Success example:
        {
            "data": true,
            "ok": true
        }
 
        Failure example:
 
        {
            "error": "volume create: gv1: failed: Volume gv1 already exists",
            "ok": false
        }
 
# (4). 安装依赖
apt-get install python-setuptools
 
# (5). 启动服务
cd glusterfs-rest
python setup.py install
glusterrest install # (Reinstall also available, sudo glusterrest reinstall)
 
# (6). 拷贝gunicorn
cp /usr/local/bin/gunicorn /usr/bin/
chmod 777 /usr/bin/gunicorn
 
# (7). 启动服务
glusterrest port 80
sudo glusterrest useradd root -g glusterroot -p root
glusterrestd
```

服务启动后，我们可以通过 http://<node_ip>/ api/1.0/doc 访问 API 的具体使用方法，主要封装的 API 见表 3。
* 表3. Gluster-rest 封装 API
  * 功能描述	HTTP请求方法	URL
  * 查看卷列表	GET	/api/1.0/volumes
  * 查看单独卷信息	GET	/api/1.0/volume/:name
  * 创建卷	POST	/api/1.0/volume/:name
  * 删除卷	DELETE	/api/1.0/volume/:name
  * 启动卷	PUT	/api/1.0/volume/:name/start
  * 停止卷	PUT	/api/1.0/volume/:name/stop
  * 重启卷	PUT	/api/1.0/volume/:name/restart
  * 获取集群节点信息	GET	/api/1.0/peers
  * 添加节点	POST	/api/1.0/peer/:hostname
  * 删除节点	DELETE	/api/1.0/peer/:hostname
基于 GlusterFS 实现数据持久化案例
接下来，用 MYSQL 数据库容器来展示 GlusterFS 如何实现数据持久化。
非持久化MYSQL数据库容器
清单5. 创建非持久化MYSQL 数据库容器
```sh
# (1). 创建mysql_1
docker run --name mysql_1 -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 mysql
 
# (2). 登录mysql_1
docker exec -it mysql_1 /bin/bash
root@4320a6f596fe:/# mysql -uroot
 
# (3). 创建database
mysql> create database mydb;
Query OK, 1 row affected (0.00 sec)
 
# (4). 列出database
mysql>show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mydb               |
| mysql              |
| performance_schema |
| test               |
+--------------------+
5 rows in set (0.00 sec)
 
# (5). 退出mysql及容器
mysql> exit
root@4320a6f596fe:/# exit
 
# (6). 删除容器
docker stop mysql_1 && docker rm mysql_1
 
# (7). 创建msqyl_2
docker run --name mysql_2 -e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 mysql
 
# (8). 登录mysql_2
docker exec -it mysql_2 /bin/bash
root@fe32ea420460:/# mysql -uroot
 
# (9). 列出database
mysql>show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
+--------------------+
4 rows in set (0.00 sec)
```

这里我们可以看到新创建的容器并没有包含我们先前创建的 mydb 数据库，这是因为非执久化的容器所有数据都在内存中，数据会随着容器的删除一起删除。
持久化 MYSQL 数据库容器
下面我们再用 GlusterFS 卷来实现数据持久化的效果。
清单6. 创建持久化 MYSQL 数据库容器
```sh
# (1). 创建Volume
curl -X POST http://root:root@192.168.1.101/api/1.0/volume/gluster_volume -d \
"bricks=bricksserver1:/exports/bricks/gluster_volume,bricksserver2:/exports/bricks/ gluster_volume&start=1&replica=2&limit=1&quota=2"
 
# (2). 创建mysql_3
docker run --name mysql_3 --volume-driver glusterfs \
--volume gluster_volume:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 mysql
 
# (3). 登录mysql_3
docker exec -it mysql_1 /bin/bash
root@b3f71265a066:/# mysql -u root
 
# (4). 创建database
mysql> create database mydb;
Query OK, 1 row affected (0.00 sec)
 
# (5). 列出database
mysql>show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mydb               |
| mysql              |
| performance_schema |
| test               |
+--------------------+
5 rows in set (0.00 sec)
 
# (6). 退出mysql及容器
mysql>exit
root@b3f71265a066:/# exit
 
# (7). 删除容器
docker stop mysql_3 && docker rm mysql_3
 
# (8). 创建msqyl_4
docker run --name mysql_4 --volume-driver glusterfs \
--volume gluster_volume:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=password -d -p 3306:3306 mysql
 
# (9). 登录mysql_4
docker exec -it mysql_4 /bin/bash
root@1aafc1734abb:/# mysql -u root
 
# (10). 列出database
Mysql > show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mydb               |
| mysql              |
| performance_schema |
| test               |
+--------------------+
5 rows in set (0.02 sec)
```
这里我们可以看到新创建的容器包含了之前创建的数据库 mydb，也就实现了我们说的数据持久化效果。
小结
GlusterFS 作为一种开源分布式存储组件，具有非常强大的扩展能力，同时也提供了非常丰富的卷类型，能够轻松实现PB级的数据存储。本文基于 docker glusterfs volume 插件和 gluster-rest API 封装，实现了容器的集群分布式存储功能。Docker 本身提供了本地存储的方案，但无法跨越主机，因此容器一旦被销毁后，如果不是落在先前的宿主机上运行也就意味着数据丢失。本文实现的 GlusterFS 存储方案，卷信息不随 Docker 宿主机的变更而发生变化，因此能够方便实现 Docker 集群的横向扩展。本文为 Docker 集群提供持久化的功能，例如关系型数据、文件服务等，提供了非常有价值的参考。
相关主题
了解 GlusterFS 基本术语。
查看 GlusterFS 总体架构。
了解更多 GlusterFS 卷类型。
了解 GlusterFS Plugin。
了解 glusterfs rest 封装。