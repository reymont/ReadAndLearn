基于 Harbor 和 Cephfs 搭建高可用 Docker 镜像仓库集群 - CSDN博客 http://blog.csdn.net/aixiaoyang168/article/details/78909038

目录

Harbor & Cephfs 介绍
环境、软件准备
Cephfs 文件系统创建
单节点 Harbor 服务搭建 
安装 Harbor
配置挂载路径
配置使用外部数据库
多节点 Harbor 集群服务搭建
测试 Habor 集群
1、Harbor & Cephfs 介绍

Harbor 是由 VMware 公司开源的企业级的 Docker Registry 管理项目，它包括权限管理(RBAC)、LDAP、日志审核、管理界面、自我注册、镜像复制和中文支持等功能，可以很好的满足我们公司私有镜像仓库的需求。Cephfs 是 Ceph 分布式存储系统中的文件存储，可靠性高，管理方便，伸缩性强，能够轻松应对 PB、EB 级别数据。我们可以使用 Cephfs 作为 Harbor 底层分布式存储使用，提高 Harbor 集群的高可用性。
2、环境、软件准备

本次演示环境，我是在虚拟机 Linux Centos7 上操作，以下是安装的软件及版本：

Docker：version 1.12.6
Docker-compose： version 1.13.0
Harbor： version 1.1.2
Ceph：version 10.2.10
Mysql：version 5.7.15
注意：要完成搭建 Harbor 高可用 Docker 镜像仓库集群，我们使用到 Cephfs，所以需要提前搭建好 Ceph 存储集群，这里就忽略搭建过程了，详细过程可参考之前文章 初试 Centos7 上 Ceph 存储集群搭建。单节点 Harbor 服务的搭建以及使用配置，可参考之前文章 Docker镜像仓库Harbor之搭建及配置。

本次演示 Harbor 集群和 Ceph 存储集群均在本机虚拟机搭建，由于本机内存限制，共开启了 4 个虚拟机，

admin: 10.222.77.73
node0: 10.222.78.7
node1: 10.222.78.8
nginx: 10.222.76.70
mysql: 10.222.76.74

说明一下，Ceph 存储集群搭建，参考之前搭建的系统，admin 作为 ceph-deploy 和 mon，node0 作为 osd0，node1 作为 osd1 (这里我只有一个 mon，建议多配置几个，组成 HA 高可用)，并且将创建的 cephfs mount 到这三个节点上，同时在这三个节点上安装 Harbor 服务组成一个镜像仓库集群（这样 Harbor 就可以直接挂载本地 cephfs 路径了）。此外，在提供一个节点 Nginx 作为负载均衡将请求均衡到这三个节点，最后在提供一个节点 Mysql 作为外部数据库存储，建议做成 HA 高可用，鉴于资源有限，这里我就暂时拿本机 Mysql 替代一下。因此节点功能图大致如下：

这里写图片描述

这里要提一下的是，本次演示搭建的镜像仓库集群，并不是最理想的高可用状态，鉴于成本和资源的考虑，只要我们能保证数据安全，即我们的 Harbor 集群出现故障，要保证数据不丢失，能够很快恢复服务就很好。如何保证 Harbor 后端镜像数据能够及时同步，不丢失呢？Harbor 默认提供了镜像复制方法，即通过配置两个或多个 Harbor 之间相互复制镜像数据规则的方式，来实现数据同步。不过这种方式对于多个 Harbor 之间数据同步，稍嫌麻烦，而且实时性有待考证。这里我们采用多 Harbor 服务共享后端存储的方式，即通过 Ceph 分布式存储方案来解决。

这里写图片描述

结合上图，再次说明一下，我们在每个 Harbor 服务节点上都 mount 配置好的 cephfs，然后配置每个 Harbor 服务的各个组件 volume 都挂载 cephfs 路径，最后通过统一的入口 Nginx 负载均衡将流量负载在各个 Harbor 服务上，来实现整个 Harbor 集群的 “高可用”。

注意，这里我们要将默认 harbor-db 数据库组件拆出来，让其连接外部 Mysql 数据库 (默认 Harbor 会在每个节点都启动 Mysql 服务进行数据存储，这样数据就没法统一，即使我们将 Mysql 数据存储在 cephfs 上，三个节点共用同一份数据，但是依旧不可行，因为 Mysql 多个实例之间无法共享一份 mysql 数据文件，启动的时候会报错 [ERROR] InnoDB: Unable to lock ./ibdata1, error: 11)。

3、Cephfs 文件系统创建

在安装 Harbor 之前，我们先创建一个 Cephfs 文件系统，具体创建过程可参考之前文章 初试 Ceph 存储之块设备、文件系统、对象存储 中文件存储部分，这里就不详细阐述了，直接贴操作代码吧！

# 在 admin（ceph-deploy） 节点操作

# 创建 MDS 元数据服务器
$ ceph-deploy mds create admin node0 node1
...

# 查看 MDS 状态
$ ceph mds stat
e6: 1/1/1 up {0=node0=up:active}, 1 up:standby

# 创建 cephfs
$ ceph osd pool create cephfs_data 128
pool 'cephfs_data' created
$ ceph osd pool create cephfs_metadata 128
pool 'cephfs_metadata' created
$ ceph fs new cephfs cephfs_metadata cephfs_data
new fs with metadata pool 11 and data pool 10
$ ceph fs ls
name: cephfs, metadata pool: cephfs_metadata, data pools: [cephfs_data ]

# 查看密钥
$ cat /etc/ceph/ceph.client.admin.keyring
[client.admin]
    key = AQCeYjxa4vb+CBAA154r9pAO5nZyDkK8cnljDQ==
    caps mds = "allow *"
    caps mon = "allow *"
    caps osd = "allow *"

# 创建密钥文件    
$ sudo vim /etc/ceph/admin.secret
AQCeYjxa4vb+CBAA154r9pAO5nZyDkK8cnljDQ==

# 创建挂载目录
$ sudo mkdir /mnt/cephfs

# 挂载 cephfs 到该目录，并指明用户名和密钥
$ sudo mount -t ceph 10.222.77.73:6789:/ /mnt/cephfs -o name=admin,secretfile=/etc/ceph/admin.secret

$ df -h
...
10.222.77.73:6789:/   66G   31G   36G   47% /mnt/cephfs

经过上边操作，我们就创建好了一个 cephfs 文件系统了。而且将 cephfs 挂载到了 admin 节点的 /mnt/cephfs 目录，下边该节点安装 Harbor 的时候，就可以直接将 volume 修改到此目录即可。

4、单节点 Harbor 服务搭建

接下来，我们以一台节点 admin 为例，安装并配置 Harbor 服务，其他 node0 和 node1 节点照此操作即可了。

4.1 安装 Harbor

安装 Harbor 很简单，按照 Harbor GitHub 安装文档 操作即可。

# 下载 Harbor 安装包
$ sudo mkdir /home/cephd/harbor && cd /home/cephd/harbor
$ wget https://github.com/vmware/harbor/releases/download/v1.1.2/harbor-offline-installer-v1.1.2.tgz
$ tar -zxvf harbor-offline-installer-v1.1.2.tgz
$ cd harbor

# 修改 harbor.cfg 配置
hostname = 10.222.77.73

$ ./install.sh
...

# docker ps
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS                                                              NAMES
8fa11d4329bd        vmware/nginx:1.11.5-patched        "nginx -g 'daemon off"   15 seconds ago      Up 13 seconds       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:4443->4443/tcp   nginx
fb3c7567dbd6        vmware/harbor-jobservice:v1.1.2    "/harbor/harbor_jobse"   15 seconds ago      Up 13 seconds                                                                          harbor-jobservice
e79ed895dd7e        vmware/harbor-ui:v1.1.2            "/harbor/harbor_ui"      16 seconds ago      Up 14 seconds                                                                          harbor-ui
371ba59c7ce8        vmware/registry:2.6.1-photon       "/entrypoint.sh serve"   18 seconds ago      Up 16 seconds       5000/tcp                                                           registry
5b259f7dedd8        vmware/harbor-db:v1.1.2            "docker-entrypoint.sh"   18 seconds ago      Up 16 seconds       3306/tcp                                                           harbor-db
6308ca7f1d7d        vmware/harbor-adminserver:v1.1.2   "/harbor/harbor_admin"   18 seconds ago      Up 16 seconds                                                                          harbor-adminserver
1be51fdfbb62        vmware/harbor-log:v1.1.2           "/bin/sh -c 'crond &&"   19 seconds ago      Up 17 seconds       127.0.0.1:1514->514/tcp    

执行完毕，如果一切顺利的话，我们就可以通过浏览器访问 http://10.222.77.73 看到 Harbor UI 页面了。

4.2 配置挂载路径

Harbor 默认将存储数据 volume 挂载到主机 /data 目录下，日志 volume 挂载到主机 /var/log/harbor/ 目录下。既然上边我们已经搭建好了 Cephfs 存储保证数据的高可用，那么这里就需要修改 Harbor 各个组件挂载的路径，分别将数据和日志 volume 挂载到 cephfs 在节点上的路径 /mnt/cephfs/harbor/ 路径下，这里我们需要修改两个文件，分别为 docker-compose.yml 和 harbor.cfg。

修改 docker-compose.yml 如下

8c8
<       - /var/log/harbor/:/var/log/docker/:z
---
>       - /mnt/cephfs/harbor/log/:/var/log/docker/:z
18c18
<       - /data/registry:/storage:z
---
>       - /mnt/cephfs/harbor/data/registry:/storage:z
57,59c57,59
<       - /data/config/:/etc/adminserver/config/:z
<       - /data/secretkey:/etc/adminserver/key:z
<       - /data/:/data/:z
---
>       - /mnt/cephfs/harbor/data/config/:/etc/adminserver/config/:z
>       - /mnt/cephfs/harbor/data/secretkey:/etc/adminserver/key:z
>       - /mnt/cephfs/harbor/data/:/data/:z
78,79c78,79
<       - /data/secretkey:/etc/ui/key:z
<       - /data/ca_download/:/etc/ui/ca/:z
---
>       - /mnt/cephfs/harbor/data/secretkey:/etc/ui/key:z
>       - /mnt/cephfs/harbor/data/ca_download/:/etc/ui/ca/:z
98c98
<       - /data/job_logs:/var/log/jobs:z
---
>       - /mnt/cephfs/harbor/data/job_logs:/var/log/jobs:z
100c100
<       - /data/secretkey:/etc/jobservice/key:z
---
>       - /mnt/cephfs/harbor/data/secretkey:/etc/jobservice/key:z

修改 harbor.cfg 如下：

#The path of cert and key files for nginx, they are applied only the protocol is set to https
ssl_cert = /mnt/cephfs/harbor/data/cert/server.crt
ssl_cert_key = /mnt/cephfs/harbor/data/cert/server.key

#The path of secretkey storage
secretkey_path = /mnt/cephfs/harbor/data

修改完配置之后，我们需要重启一下 Harbor 服务。

$ docker-compose down -v
$ dokcer-compose up -d
或
$./install

这次 Harbor 服务启动之后，我们再次浏览器访问 http://10.222.77.73，会发现使用了cephfs 之后，页面加载速度有所降低，比上边直接本机存储的方式要慢一些。

确认一下是否已经数据和日志存储到 cephfs 存储目录啦！

$ ls -al /mnt/cephfs/harbor/
drw------- 1 root root 5 12月 22 11:49 data
drwxr-xr-x 1 root root 1 12月 22 11:49 log

OK 到此，Harbor 存储这块已经达到了高可用，那么接下来就要迁移一下 db 存储到外部数据库。在迁移数据之前，我们先来简单的操作一下，造一点数据存储到默认 Mysql 数据库里面去，方便后边 Harbor 其他节点搭建完毕后，验证数据是否同步。

首先使用一个新的用户 wanyang3 上传一个 nginx 镜像到该节点 Harbor 仓库中。创建用户 wanyang3 并且创建一个 wanyang3 的项目，并分配该项目权限给用户 wanyang3，这部分可以在 Harbor UI 页面上操作，这里就不在演示了。

# 注意以下操作前修改一下 docker 配置文件，增加 –insecure-registry=10.222.77.73
# 登录 Harbor
$ docker login 10.222.77.73
Username: wanyang3
Password:
Login Succeeded

# tag 并 push 镜像到 Harbor
$ docker tag nginx:1.11 10.222.77.73/wanyang3/nginx:1.11
$ docker push 10.222.77.73/wanyang3/nginx:1.11
The push refers to a repository [10.222.77.73/wanyang3/nginx]
cbb475ff5c8e: Pushed
2eea2d5e43e6: Pushed
b6ca02dfe5e6: Pushed
1.11: digest: sha256:820c2fa427c19d4369271dfc529870f7c4b963f7c56d7dcedd1426cbaf739946 size: 948

实测确实有点慢啊！有点慢啊！有点慢啊！难道是 cephfs 数据同步到其他 node 花费了这么多时间么。。。

再次查看下镜像数据有没有存储到 cephfs 中吧！

$ ls -al /mnt/cephfs/harbor/data/registry/docker/registry/v2/repositories/wanyang3/nginx
drwxr-xr-x 1 root root 1 12月 22 11:57 _layers
drwxr-xr-x 1 root root 2 12月 22 11:58 _manifests
drwxr-xr-x 1 root root 0 12月 22 11:58 _uploads

## 4.3 配置使用外部数据库

上边提到，将 Mysql 数据存储在 cephfs 上，三个节点共用同一份数据，但是发现不可行，因为 Mysql 多个实例之间无法共享一份 mysql 数据文件，启动的时候会报错 [ERROR] InnoDB: Unable to lock ./ibdata1, error: 11。所以，我们需要使用外部数据库或者 HA 数据库集群来解决这个问题。这里我暂时使用本机的 Mysql 数据库来替代一下，所以并不是理想状态下的 HA，如果想实现 db 高可用，大家可以自行搭建一下吧！

### 4.3.1 迁移 db 数据

因为之前的操作，已经有一部分数据存储到 harbor-db 数据库里面去了，而且 Harbor 启动时也会创建好所需要的数据库、表和数据等。这里我们先进入 harbor-db 容器中，将 registry 数据库 dump 一份，然后 Copy 到当前节点机器。


```sh
# 进入 harbor-db 容器
$ docker exec -it e23760eba95e bash

# 备份数据到默认目录 /tmp/registry.dump 
$ mysqldump -u root -p registry > registry.dump        
Enter password: root123
$ exit

# 退出容器，copy 备份数据到当前节点机器。
$ docker cp e23760eba95e:/tmp/registry.dump /home/cephd/harbor/

# 将备份数据通过共享文件夹复制到本机
$ cp /home/cephd/harbor/registry.dump /media/sf_share/
```
注意：因为当前 master 节点没有安装 mysql-client，所以无法通过 mysql -h <db_ip> -P <db_port> -u <db_user> -p <db_password> 直接连接外部数据库操作。因此，这里我通过虚拟机共享文件夹将数据复制到本机。

现在数据已经到本机了，接下来我们就可以登录本机 Mysql，创建用户并导入数据了。

$ mysql -u root -p xxxxxx
mysql> CREATE USER 'harbor'@'%' IDENTIFIED BY 'root123'; 
mysql> GRANT ALL ON *.* TO 'harbor'@'%';
mysql> FLUSH PRIVILEGES;

这里为了方便后续操作，我们创建一个专门的账户 harbor，并赋上所有操作权限。接下来使用 harbor 账户登录，创建数据库 registry 并导入 dump 数据。

$ mysql -u harbor -p xxxxxx
mysql> CREATE DATABASE IF NOT EXISTS registry default charset utf8 COLLATE utf8_general_ci;
mysql> USE registry;
Database changed
mysql> source /Users/wanyang3/VirtualBox VMs/share/registry.dump;
1
2
3
4
5
OK 现在外部数据库也已经搞定了，那怎么样让 Harbor 组件使用我们配置的外部 db 呢？

## 4.3.2 修改配置使用外部 db

首先，既然我们已经有外部数据库了，那么就不需要 Harbor 在启动 harbor-db 服务了，只需要配置连接外部数据库即可。因此就需要删除 docker-compose.yml 中 mysql 相关配置。

```yml
# 删除以下 mysql 配置
mysql:
    image: vmware/harbor-db:v1.1.2
    container_name: harbor-db
    restart: always
    volumes:
      - /data/database:/var/lib/mysql:z
    networks:
      - harbor
    env_file:
      - ./common/config/db/env
    depends_on:
      - log
    logging:
      driver: "syslog"
      options:  
        syslog-address: "tcp://127.0.0.1:1514"
        tag: "mysql"

# 删除 depends_on 中 mysql 部分
depends_on:
  # - mysql # 此处删除
  - registry
  - ui
  - log
```

其次，我们还需要修改 ./common/config/adminserver/env 配置，这里面主要存放的是一些配置信息，里面就有配置 Mysql 的连接信息。因为该文件是执行 install.sh 的时候根据 ./common/templates/adminserver/env 配置生成的，所以即使我们修改了，也是一次性的，重新 install 又会覆盖掉，所以可以直接修改 ./common/templates/adminserver/env 该文件就一劳永逸了。

# 修改 ./common/templates/adminserver/env 文件
...
MYSQL_HOST=10.222.76.74
MYSQL_PORT=3306
MYSQL_USR=harbor
MYSQL_PWD=root123
MYSQL_DATABASE=registry
...
RESET=true

注意：这里一定要设置 RESET=true 因为只有设置了该开关，Harbor 才会在启动时覆盖默认配置，启用我们配置的信息。

再次启动 Harbor 服务，看下能否启动成功，能否正常连接配置的外部数据库吧。

# 重启 Harbor 服务
$ docker-compose down -v
$ dokcer-compose up -d
或
$./install

# 查看 Harbor 各组件容器启动状态，harbor-db 服务已经移除
$ docker ps
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS                                                              NAMES
b1ab727bc072        vmware/nginx:1.11.5-patched        "nginx -g 'daemon off"   4 seconds ago       Up 2 seconds        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:4443->4443/tcp   nginx
d818f03c08f8        vmware/harbor-jobservice:v1.1.2    "/harbor/harbor_jobse"   4 seconds ago       Up 2 seconds                                                                           harbor-jobservice
77f4fd50d1d9        vmware/harbor-ui:v1.1.2            "/harbor/harbor_ui"      4 seconds ago       Up 3 seconds                                                                           harbor-ui
933b3273c062        vmware/registry:2.6.1-photon       "/entrypoint.sh serve"   5 seconds ago       Up 3 seconds        5000/tcp                                                           registry
c7e93e736150        vmware/harbor-adminserver:v1.1.2   "/harbor/harbor_admin"   5 seconds ago       Up 4 seconds                                                                           harbor-adminserver
29efd79e17c8        vmware/harbor-log:v1.1.2           "/bin/sh -c 'crond &&"   6 seconds ago       Up 4 seconds        127.0.0.1:1514->514/tcp  

# 查看 ui 和 jobservice 日志，是否连接上 mysql
$ cat /mnt/cephfs/harbor/log/2017-12-22/ui.log
...
Dec 22 14:40:28 172.18.0.1 ui[26424]: 2017-12-22T06:40:28Z [INFO] configurations initialization completed
Dec 22 14:40:28 172.18.0.1 ui[26424]: 2017-12-22T06:40:28Z [INFO] initializing database: type-MySQL host-10.222.76.74 port-3306 user-harbor database-registry
Dec 22 14:40:28 172.18.0.1 ui[26424]: 2017-12-22T06:40:28Z [INFO] initialize database completed

$cat /mnt/cephfs/harbor/log/2017-12-22/cat /mnt/cephfs/harbor/log/2017-12-22/jobservice.log
...
Dec 22 14:40:29 172.18.0.1 jobservice[26424]: 2017-12-22T06:40:29Z [INFO] configurations initialization completed
Dec 22 14:40:29 172.18.0.1 jobservice[26424]: 2017-12-22T06:40:29Z [INFO] initializing database: type-MySQL host-10.222.76.74 port-3306 user-harbor database-registry
Dec 22 14:40:29 172.18.0.1 jobservice[26424]: 2017-12-22T06:40:29Z [INFO] initialize database completed

OK 成功启动，harbor-db 服务按照设计也没有启动，日志显示连接外部数据库也没有问题，再次通过浏览器访问 http://10.222.77.73 看下之前操作的数据是否能够正常显示出来吧！

这里写图片描述

妥妥没问题！ 到此，单节点的 Harbor 服务已经完成了仓库存储和数据库存储的 “高可用”，实际应用中，单一节点肯定是不能满足需求的，暂且不说能否抵抗高流量的访问冲击，光发生节点故障时，就没法满足镜像仓库集群的高可用性，所以我们还需要搭建多个 Harbor 节点组成一个集群。

## 5、多节点 Harbor 集群服务搭建

单节点 Harbor 服务搭建以及配置 “高可用” 已经搞定，其他节点也就同样操作了，不过也要稍微改下配置，这里就不一一详细描述过程了，直接贴操作过程，这里以 node0 (10.222.78.7) 操作为例。

```sh
# 登录 node0 节点操作 
$ ssh node0

# 查看当前 MDS 状态，显示报错，是因为文件权限的问题
$ ceph mds stat
2017-12-22 15:03:16.626707 7fec89740700 -1 auth: unable to find a keyring on /etc/ceph/ceph.client.admin.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin: (2) No such file or directory
2017-12-22 15:03:16.626715 7fec89740700 -1 monclient(hunting): ERROR: missing keyring, cannot use cephx for authentication
2017-12-22 15:03:16.626716 7fec89740700  0 librados: client.admin initialization error (2) No such file or directory
Error connecting to cluster: ObjectNotFound

# 对密钥文件赋权限
$ sudo chmod +r /etc/ceph/ceph.client.admin.keyring

# 查看当前 MDS 状态显示正常状态
$ ceph mds stat
e6: 1/1/1 up {0=node0=up:active}, 1 up:standby

# 查看当前 fs 列表，注意一个集群只支持一个 cephfs
$ ceph fs ls
name: cephfs, metadata pool: cephfs_metadata, data pools: [cephfs_data ]

# 查看密钥
$ cat /etc/ceph/ceph.client.admin.keyring 
[client.admin]
    key = AQCeYjxa4vb+CBAA154r9pAO5nZyDkK8cnljDQ==
    caps mds = "allow *"
    caps mon = "allow *"
    caps osd = "allow *"

# 创建密钥文件    
$ sudo vim /etc/ceph/admin.secret
AQCeYjxa4vb+CBAA154r9pAO5nZyDkK8cnljDQ==

# 创建挂载目录并挂载 cephfs 到该目录，并指明用户名和密钥
$ sudo mkdir /mnt/cephfs
$ sudo mount -t ceph 10.222.77.73:6789:/ /mnt/cephfs -o name=admin,secretfile=/etc/ceph/admin.secret

$ df -h
...
10.222.77.73:6789:/   66G   31G   36G   47% /mnt/cephfs

# 显示数据已经挂载进来了，这是上边 admin 节点启动 Harbor 时创建的数据
$ sudo ls -al /mnt/cephfs/harbor/
drw------- 1 root root 5 12月 22 11:49 data
drwxr-xr-x 1 root root 1 12月 22 11:49 log

# 切换到 root  用户操作，操作同上边单节点操作。
1、下载 harbor 安装包
2、修改 harbor.conf 
hostname = 10.222.78.7
ssl_cert = /mnt/cephfs/harbor/data/cert/server.crt
ssl_cert_key = /mnt/cephfs/harbor/data/cert/server.key
secretkey_path = /mnt/cephfs/harbor/data

3、修改 docker-compose.yml
删除 mysql 配置，修改 log 组件 volume 配置路径为
volumes:
      - /mnt/cephfs/harbor/log0/:/var/log/docker/:z
将各个节点日志分隔开，不然日志会覆盖，不方便查找问题。

4、修改 common/templates/adminserver/env 配置 mysql 连接

5、启动 Harbor 服务
./install.sh

6、查看挂载数据 ls -al /mnt/cephfs/harbor/
drwxr-xr-x 1 root root 1 12月 22 15:25 log0
drw------- 1 root root 5 12月 22 11:49 data
drwxr-xr-x 1 root root 1 12月 22 11:49 log
```
好了，经过上述操作，node0 也已经成功启动了 Harbor 服务，并且仓库存储及日志使用了 cephfs 共享存储，db 数据存储使用了外部数据库，同理，按照上述操作步骤对 node1 (10.222.78.8) 进行操作，这里就不描述了。

## 6、测试 Habor 集群

好了，现在已经创建好了由三个 Harbor 节点组成的一个简单的 “高可用” 镜像仓库集群，那么接下来，我们来测试一下 Harbor 集群。我们都知道，生产环境下，针对某个服务集群，一般使用一个统一的域名进行访问，然后将请求负载均衡分发到各个子节点上。这里我们就模拟一下通过统一 IP（生产环境下申请域名替换即可） 入口访问该 Harbor 集群吧！

这里，我们在一个新的节点 Nginx (10.222.76.70) 上边安装 Nginx 服务，作为访问 Harbor 服务统一的入口，然后负载均衡到上边各个 Harbor 子节点上。为了快速安装 Nginx，可采用 Docker 方式启动 Nginx 服务。

```sh
# 创建 default.conf 配置文件
$ mkdir /root/nginx
$ vim default.conf
upstream service_harbor {
    server 10.222.77.73;
    server 10.222.78.7;
    server 10.222.78.8;
    ip_hash;
}

server {
    listen       80;
    server_name  10.222.76.70;
    index  index.html index.htm;    

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        add_header Access-Control-Allow-Origin *;
        proxy_next_upstream http_502 http_504 error timeout invalid_header;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://service_harbor;    
    }

    access_log /var/log/harbor.access.log;
    error_log /var/log/harbor.error.log;    

    error_page  404              /404.html;

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
# Docker 启动 Nginx 服务，挂载上边配置文件覆盖默认配置，并开放 80 端口
docker run --name nginx-harbor -p 80:80 -v /root/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro -d nginx
```

OK 现在 Nginx 服务也起来了，我们来测试一下，通过浏览器访问 http://10.222.76.70/ 是否能够访问 Harbor UI 吧！

这里写图片描述

妥妥没问题的，我们可以看到数据也是同步显示出来的。接下来我们本机或其他机器通过命令行方式登录 Harbor 并且尝试推送一个新的 Image 到镜像仓库集群中试试吧。

# 注意以下操作前修改一下 docker 配置文件，增加 –insecure-registry=10.222.76.70
# 登录 Harbor
$ docker login 10.222.76.70
Username: wanyang3
Password:
Login Succeeded

# tag 并 push 镜像到 Harbor
$ docker tag tomcat:8.0 10.222.76.70/wanyang3/tomcat:8.0
$ docker push 10.222.76.70/wanyang3/tomcat:8.0
The push refers to a repository [10.222.76.70/wanyang3/tomcat]
06a56cfbd702: Pushed
978148d13d7d: Pushing [==================================================>]  16.32MB/16.32MB
e31c8669b930: Pushing [==================================================>]    130kB
8443dd1bccc9: Pushing [==================================================>]  7.316MB/7.316MB
bf40d7791c7e: Pushed
9125381ad905: Pushing   2.56kB
be6a597f6221: Waiting
ff8f2671c638: Waiting
9e9ecb074181: Waiting
60a0858edcd5: Waiting
b6ca02dfe5e6: Waiting
error parsing HTTP 413 response body: invalid character '<' looking for beginning of value: "<html>\r\n<head><title>413 Request Entity Too Large</title></head>\r\n<body bgcolor=\"white\">\r\n<center><h1>413 Request Entity Too Large</h1></center>\r\n<hr><center>nginx/1.13.7</center>\r\n</body>\r\n</html>\r\n"

不过貌似发生了错误 413 Request Entity Too Large。。。 出现这个错误，是因为 Nginx 默认设置的接收客户端发送的 body 实体长度太小所致，解决办法就是增大接收 body 实体长度限制。

$ vim default.conf
    ...
    location / {
         ...
         client_max_body_size  1024m  # 设置接收客户端 body 最大长度为 1024M
     }
1
2
3
4
5
6
这里我设置 1G 大小，基本上能够满足日常需求。重启 nginx-harbor 容器，然后再次 push 一下试试。

# nginx (10.222.76.70) 节点上重启
$ docker restart nginx-harbor

# 本机 push 镜像到 Harbor
$ docker push 10.222.76.70/wanyang3/tomcat:8.0
The push refers to a repository [10.222.76.70/wanyang3/tomcat]
06a56cfbd702: Layer already exists
978148d13d7d: Pushed
e31c8669b930: Layer already exists
8443dd1bccc9: Pushed
bf40d7791c7e: Layer already exists
9125381ad905: Layer already exists
be6a597f6221: Pushed
ff8f2671c638: Pushed
9e9ecb074181: Pushed
60a0858edcd5: Pushed
b6ca02dfe5e6: Pushed
8.0: digest: sha256:13d33abafd848993176a8a04e3c4143bdf8aeda2454705f642bf37cfe80730d5 size: 2624

# 任意 Harbor 服务节点查看下数据是否存储到 cephfs
$ ll -al /mnt/cephfs/harbor/data/registry/docker/registry/v2/repositories/wanyang3
drwxr-xr-x 1 root root 3 12月 22 11:58 nginx
drwxr-xr-x 1 root root 3 12月 22 16:53 tomcat

# 测试下 pull，先删除本地已存在的镜像 tag 以及原镜像，否则不会执行 pull
$ docker rmi 10.222.76.70/wanyang3/tomcat:8.0
Untagged: 10.222.76.70/wanyang3/tomcat:8.0
Untagged: 10.222.76.70/wanyang3/tomcat@sha256:13d33abafd848993176a8a04e3c4143bdf8aeda2454705f642bf37cfe80730d5
$ docker rmi tomcat:8.0

# pull 镜像
$ docker pull 10.222.76.70/wanyang3/tomcat:8.0
8.0: Pulling from wanyang3/tomcat
1ade878aecd1: Already exists
fdca7d84dcaf: Pull complete
89db77df620b: Pull complete
b0cac26819d3: Pull complete
fd0c12e9a364: Pull complete
6e834cb7f4c2: Pull complete
e23224460585: Pull complete
2978c7a1a062: Pull complete
a1b2cddfa98e: Pull complete
cf2776c8b30b: Pull complete
3a0099682c97: Pull complete
Digest: sha256:13d33abafd848993176a8a04e3c4143bdf8aeda2454705f642bf37cfe80730d5
Status: Downloaded newer image for 10.222.76.70/wanyang3/tomcat:8.0

实测，Push 速度确实有点慢哈！网上搜索了一下，确实大家反映 cephfs 分布式文件系统整体性能不是很理想，会慢一些，不过 Ceph 可以根据系统环境进行性能调优，比如 osd、 rbd chache 参数调优等，当然对这个 Ceph 调优我不太了解，以后有时间在慢慢研究下吧！

这里写图片描述

值的一提的是，当我尝试在 Harbor UI 上删除某一个镜像时，发现 cephfs 共享存储中依旧存在，我们可以通过删除某镜像后再次 push 该镜像来验证一下。

# Harbor UI 上先删除 wanyang3/tomcat:8.0 镜像，在进行如下操作

$ docker push 10.222.76.70/wanyang3/tomcat:8.0
The push refers to a repository [10.222.76.70/wanyang3/tomcat]
06a56cfbd702: Layer already exists
978148d13d7d: Layer already exists
e31c8669b930: Layer already exists
8443dd1bccc9: Layer already exists
bf40d7791c7e: Layer already exists
9125381ad905: Layer already exists
be6a597f6221: Layer already exists
ff8f2671c638: Layer already exists
9e9ecb074181: Layer already exists
60a0858edcd5: Layer already exists
b6ca02dfe5e6: Layer already exists
8.0: digest: sha256:13d33abafd848993176a8a04e3c4143bdf8aeda2454705f642bf37cfe80730d5 size: 2624

会显示远端仓库已经存在该镜像了。这是什么原因呢？ 查看了下 Harbor 文档，发现我们在 UI 上执行 Delete 操作，是逻辑删除，并没有执行真正的物理文件删除，这也就解释了为啥第二次 push 会显示远端已经存在了。如果我们想删除物理文件的话，可以通过官方提供的方法执行 GC 回收。

# 执行 GC 前需要停止 Harbor 服务
$ docker-compose stop

# docker 启动 gc 容器删除镜像数据，可以加上 --dry-run 参数，这样会只打印详情，并未真正执行删除操作。
$ docker run -it --name gc --rm --volumes-from registry vmware/registry:2.6.2-photon garbage-collect --dry-run /etc/registry/config.yml

# 确认上述打印详情日志没问题后，去掉参数，执行删除操作。
$ docker run -it --name gc --rm --volumes-from registry vmware/registry:2.6.2-photon garbage-collect /etc/registry/config.yml

通过上边一系列的操作，一个 “高可用” 的 Docker 镜像仓库集群就搭建完成了，基本能够满足我们的日常需求。不过之所以称之为带引号的高可用，因为还有几个地方可以改进下，比如 Ceph 集群 HA 高可用、Cephfs 性能调优、Mysql 集群达到 HA 高可用、增加 Harbor 集群节点数来支撑大流量的冲击、Nginx 参数调优等等。

## 参考资料

Harbor Github user_guide
Harbor Github installation_guide
Ceph 存储集群快速入门
Ceph 文件系统