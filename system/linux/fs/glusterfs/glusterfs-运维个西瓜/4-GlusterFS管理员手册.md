

【四】GlusterFS管理员手册 - CSDN博客 
http://blog.csdn.net/watermelonbig/article/details/49228141

四、GlusterFS管理员手册

1. GlusterFS术语

GNFS 和KNFS，前者是GlusterFS自带的NFS Server，而后者指的是操作系统内核提供的kernel NFS服务。两者可选其一，也可以配置成同时提供服务。
Brick，存储块，指可信主机池中由主机提供的用于存储的专用分区，是GlusterFS中的基本存储单元。
Volume，逻辑卷，一个逻辑卷是一组bricks的集合。
Subvolume，一个在经由至少一个的转换器处理之后的brick，被称为sub-volume。
Volfile，代指GlusterFS的各种配置文件，定义了服务端和客户端使用到的各种转换器以及卷和块的配置信息。
GlusterFS共包含三部分，服务端、客户端和管理进程，每部分都有自己的配置文件。其中服务端和客户端的vol files放置在/var/lib/glusterd/vols/VOLNAME目录下，后台管理进程的配置文件在/etc/glusterfs/目录下。
 Glusterd，后台管理进程，需要在存储集群中的每个节点上都要运行。
Extended Attributes，扩展属性是文件系统的一个特性，允许用户或应用为文件和目录关联更多的元数据信息。
 FUSE，用户空间内的文件系统。
GFID，每个GlusterFS中的文件或目录都有一个128bit的数字标识，称为GFID。
 Quorum，该参数设置了在一个可信的存储池中最多可失效的主机节点数量，超出该值则认为该可信存储池已不可用了。
 Rebalance，当一个brick被加入或移除后，会有一个修复进程对数据分布进行重新计算与优化。
 RRDNS，是随机式域名解析的缩写，用于对一个域名设置多个IP解析时，实现数据读负载的分布式处理。
 Split-brain，脑裂，即处于一个镜像复制关系中的bricks之间，发生了数据或元数据的不一致问题，而无法认定哪边的数据正确。
2. GlusterFS的两种访问控制方式

每个GlusterFS逻辑卷的配置文件中都会有相似的两种文件，名称分别是trusted--fuse.vol和-fuse.vol。这实际上与GlusterFS的两种访问控制策略有关。GlusterFS的可信存储池设计，可以满足已经被加入到可信主机池中的主机节点挂接GlusterFS存储的访问需求，此时使用的是带有trusted-volfile前缀的配置文件。而对于不在可信主机池中的主机节点，在使用GlusterFS逻辑存储卷时，需要使用non-trusted-volfile的相关配置文件，使用username/password通过访问控制。
3. 创建和管理可信存储主机池

首先，不能在第一个主机节点上probe自己。其次，需要为所有主机做好主机名解析。
3.1 创建一个包含四个节点的可信主机池
# gluster peer probe server2Probe successful# gluster peer probe server3Probe successful# gluster peer probe server4Probe successful
3.2 在第一个节点上对可信主机池状态进行检查
# gluster peer statusNumber of Peers: 3Hostname: server2
Uuid: 5e987bda-16dd-43c2-835b-08b7d55e94e5State: Peer in Cluster (Connected)Hostname: server3
Uuid: 1e0ca3aa-9ef7-4f66-8f15-cbc348f29ff7State: Peer in Cluster (Connected)Hostname: server4
Uuid: 3e0caba-9df7-4f66-8e5d-cbc348f29ff7State: Peer in Cluster (Connected)
3.3 从已经加入到可信池的其它节点上probe第一个节点
server2# gluster peer probe server1
 Probe successful
3.4 继续在server2上执行可信池状态检查的命令
server2# gluster peer statusNumber of Peers: 3Hostname: server1
Uuid: ceed91d5-e8d1-434d-9d47-63e914c93424State: Peer in Cluster (Connected)Hostname: server3
Uuid: 1e0ca3aa-9ef7-4f66-8f15-cbc348f29ff7State: Peer in Cluster (Connected)Hostname: server4
Uuid: 3e0caba-9df7-4f66-8e5d-cbc348f29ff7State: Peer in Cluster (Connected)
3.5 从可信存储主机池中移除一个主机节点
# gluster peer detach server4Detach successful
4. 管理glusterd服务进程

启动与停止：
# /etc/init.d/glusterd start
# /etc/init.d/glusterd stop
设置为随系统自启动：
# chkconfig glusterd on
 
5. 使用Gluster CLI工具

你可以在Gluster集群中的任一个节点上执行Gluster CLI命令，而配置结果会被自动同步到整个集群。即使逻辑卷正在被挂接中和使用中，也一样可以使用CLI命令进行管理。
直接运行CLI命令，如：
# gluster peer status
使用CLI命令的交互模式：
# gluster
gluster>
gluster > peer status
 
6. POSIX ACL文件权限管理

使用POSIX Access Control Lists (ACLs) 可以实现更加细粒度的文件访问权限控制。
6.1 在服务端启用POSIX Access Control Lists (ACLs) 
如果需要使用POSIX Access Control Lists (ACLs) ，那么在服务器端挂接逻辑卷时就需要指定acl选项，如下所示：
# mount -o acl /dev/sda1 /export1
在/etc/fstab文件中可以这样配置：
LABEL=/work /export1 ext3 rw, acl 14
 
6.2 在客户端启用POSIX Access Control Lists (ACLs)
# mount -t glusterfs -o acl 198.192.198.234:glustervolume /mnt/gluster
 
6.3 设置POSIX ACLs
一般地，你可以设置两种类型的POSIX ACLs，access ACLs和default ACLs。前者用于对一个指定的目录或文件设置访问策略，而后者则为目录及目录中的文件提供一种默认的访问控制策略。你可以基于每个用户、用户组以至于不在文件属组内的其它用户，来设置ACLs。
设置access ACLs的命令格式：# setfacl –m file
下表为可以设置的权限项目和格式要求，其中<permission>必须是r (read), w (write), and x (execute)的组合形式。
ACL Entry
Description
u:uid:\<permission>
Sets the access ACLs for a user. You can specify user name or UID
g:gid:\<permission>
Sets the access ACLs for a group. You can specify group name or GID.
m:\<permission>
Sets the effective rights mask. The mask is the combination of all access permissions of the owning group and all of the user and group entries.
o:\<permission>
Sets the access ACLs for users other than the ones in the group for the file.
 
授权对象可以是文件，也可以是目录。例如，为用户antony授权testfile的读写权限。
# setfacl -m u:antony:rw /mnt/gluster/data/testfile
 
设置default ACLs的命令格式：# setfacl –m –-set
例如，设置/data目录的默认ACLs为向不在文件所属用户组内的其它所有用户，开放只读的权限：
# setfacl –m --set o::r /mnt/gluster/data
注：如果同时设置了default acls和access acls，则access acls优先级更高。
 
6.4 怎样查看已经设置的POSIX ACLs
查看文件的access acls：# getfacl targetfile
    查看目录的default acls：# getfacl /mnt/gluster/data/doc
6.5 移除POSIX ACLs
例如，移除用户antony对test-file的所有访问权限：
# setfacl -x u:antony /mnt/gluster/data/test-file
6.6 Samba and ACLs
如果你使用Samba访问GlusterFS FUSE挂接的存储卷，那么POSIX ACLs会默认被启用。
7. 怎样配置使用GlusterFS客户端

你可以通过多种方式访问gluster存储卷。
在Linux系统主机中，使用gluster原生客户端方式，可以获得更高的并发性能和透明的失效转移功能。
在Linux/Unix系统主机中，使用NFSv3访问gluster存储卷。
在Windows系统主机中，使用CIFS访问gluster存储卷。
7.1 使用Gluster原生客户端访问存储卷

Gluster原生客户端是一个基于FUSE的运行在客户的用户空间中的客户端程序，也是推荐用于高并发访问逻辑存储卷数据的工具。
1) 安装FUSE内核模块：
# modprobe fuse
# dmesg | grep -i fuse fuse init (API version 7.13)
2) 安装客户端软件及依赖包（以RedHat/CentOS为例）：
$ sudo yum -y install openssh-server wget fuse fuse-libs openib libibverbs
3) 打开服务器端的TCP/UDP端口
需要在所有的Gluster服务器上打开TCP和UDP的24007， 24008端口。
需要在所有的Gluster服务器上为启用了的brick打开特定端口，在一台主机上设置了多个bricks的情况下，brick的对外服务端口是从49152开始使用，逐渐递增。例如在主机上设置启用了5个brick，那么：
$ sudo iptables -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 24007:24008 -j ACCEPT 
$ sudo iptables -A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 49152:49156 -j ACCEPT
注：以上仅做参考，在RedHat/CentOS系统上需对命令做微调。
4) 在客户机上下载最新的glusterfs, glusterfs-fuse, and glusterfs-rdma RPM包
Glusterfs包中包含了Gluster原生客户端。glusterfs-fuse包中包含了FUSE转换器，用于在客户机上挂接glusterfs存储卷。glusterfs-rdma 包是用于客户机使用Infiniband网络时提供相关驱动。
RedHat/CentOS系统应该可以使用yum进行下载和安装。其它Linux系统可以从以下地址中下载从上rpm包：http://www.gluster.org/download/ 。
$ sudo rpm -i glusterfs-3.3.0qa30-1.x86_64.rpm 
$ sudo rpm -i glusterfs-fuse-3.3.0qa30-1.x86_64.rpm 
$ sudo rpm -i glusterfs-rdma-3.3.0qa30-1.x86_64.rpm
注：gluster-fs-rdma包在不使用Infiniband网络时则不需要安装。
5) 源码方式安装Gluster原生客户端
# mkdir glusterfs 
# cd glusterfs
下载源码至该目录并解压：
# tar -xvzf SOURCE-FILE
# ./configure
# make # make install
验证安装结果：
# glusterfs –-version
6) 挂接逻辑存储卷到本地
怎样手工实现挂接：
# mount -t glusterfs server1:/test-volume /mnt/glusterfs
注：在挂接时所指定的server1只是为了从它那里获取到必要的配置信息，在挂接之后，客户机会与不仅仅server1进行通信，也会直接和逻辑存储卷内其它bricks所在的主机进行通信。
关于可选的配置项，格式及样例如下：
# mount -t glusterfs -o backupvolfile-server=volfile_server2,use-readdirp=no,volfile-max-fetch-attempts=2,log-level=WARNING,log-file=/var/log/gluster.log server1:/test-volume /mnt/glusterfs
选项的说明：
backupvolfile-server=server-name
volfile-max-fetch-attempts=number of attempts
log-level=loglevel
log-file=logfile
transport=transport-type
direct-io-mode=[enable|disable]
use-readdirp=[yes|no]
 
选项volfile-max-fetch-attempts=X在使用到RRDNS或在挂接卷时指定的多个服务器IP的情况下，是比较有用的。
选项backupvolfile-server可以手工设置好当第一个volfile服务器失效时，可以把存储卷的挂接源转移到另一个指定的Server。
怎样实现自动化的挂接：
编辑/etc/fstab文件，增加以下内容：
server1:/test-volume /mnt/glusterfs glusterfs defaults,_netdev 0 0
 
同样可以设置好一些有用的配置选项：
server1:/test-volume /mnt/glusterfs glusterfs defaults,_netdev,log-level=WARNING,log-file=/var/log/gluster.log 0 0
7.2 使用NFS协议访问存储卷

在服务端和客户端主机上均需要安装NFS工具包，这个工个包的名称在不同发行版本的Linux上并不相同，但大多以nfs-commons, nfs-utils为主。
手工挂接到本地：
# mount -t nfs -o vers=3 server1:/test-volume /mnt/glusterfs
注：Gluster NFS server不支持UDP，如果你的NFS客户端报错提示NFS版本或协议不正确，则可以在挂接命令的参数选项中明确指定下使用TCP协议。
# mount -o mountproto=tcp -t nfs server1:/test-volume /mnt/glusterfs
在Solaris客户机上挂接存储卷：
# mount -o proto=tcp,vers=3 nfs://server1:38467/test-volume /mnt/glusterfs
 
设置成系统启动时自动挂接存储卷：
修改/etc/fstab文件并添加以下内容：
server1:/test-volume /mnt/glusterfs nfs defaults,_netdev,vers=3 0 0
或
server1:/test-volume /mnt/glusterfs nfs defaults,_netdev,mountproto=tcp 0 0
 
7.3 使用CIFS协议访问存储卷

1) 在服务端挂接存储卷在本地。
2) 设置Samba配置文件，将挂接目录发布出去。
编辑smb.conf文件并添加以下内容：
[glustertest]
comment = For testing a Gluster volume exported through CIFS
path = /mnt/glusterfs
read only = no
guest ok = yes
保存并重启smb服务： #service smb restart
你需要在Gluster集群内的每个节点上都配置以上内容。
3) 手工在Windows系统中挂接存储卷
Windows Explorer, choose Tools > Map Network Drive
Choose the drive letter using the Drive drop-down list
Click Browse, select the volume to map to the network drive, and click OK
 
实现基于CIFS的自动挂接：
Windows Explorer, choose Tools > Map Network Drive
Choose the drive letter using the Drive drop-down list.
Click Browse, select the volume to map to the network drive, and click OK.
Click the Reconnect at logon checkbox.
 
 
8. 怎样管理GlusterFS服务器的存储卷

8.1 调优存储卷参数

命令格式：# gluster volume set
例如,设置存储卷使用的缓存为256MB：
# gluster volume set test-volume performance.cache-size 256MBSet volume successful
 
查看修改的结果： # gluster volume info
 
GlusterFS存储卷配置选项清单：
Option
Description
Default Value
Available Options
auth.allow
IP addresses of the clients which should be allowed to access the volume.
* (allow all)
Valid IP address which includes wild card patterns including *, such as 192.168.1.*
auth.reject
IP addresses of the clients which should be denied to access the volume.
NONE (reject none)
Valid IP address which includes wild card patterns including *, such as 192.168.2.*
client.grace-timeout
Specifies the duration for the lock state to be maintained on the client after a network disconnection.
10
10 - 1800 secs
cluster.self-heal-window-size
Specifies the maximum number of blocks per file on which self-heal would happen simultaneously.
16
0 - 1025 blocks
cluster.data-self-heal-algorithm
Specifies the type of self-heal. If you set the option as "full", the entire file is copied from source to destinations. If the option is set to "diff" the file blocks that are not in sync are copied to destinations. Reset uses a heuristic model. If the file does not exist on one of the subvolumes, or a zero-byte file exists (created by entry self-heal) the entire content has to be copied anyway, so there is no benefit from using the "diff" algorithm. If the file size is about the same as page size, the entire file can be read and written with a few operations, which will be faster than "diff" which has to read checksums and then read and write.
reset
full/diff/reset
cluster.min-free-disk
Specifies the percentage of disk space that must be kept free. Might be useful for non-uniform bricks
10%
Percentage of required minimum free disk space
cluster.stripe-block-size
Specifies the size of the stripe unit that will be read from or written to.
128 KB (for all files)
size in bytes
cluster.self-heal-daemon
Allows you to turn-off proactive self-heal on replicated
On
On/Off
cluster.ensure-durability
This option makes sure the data/metadata is durable across abrupt shutdown of the brick.
On
On/Off
diagnostics.brick-log-level
Changes the log-level of the bricks.
INFO
DEBUG/WARNING/ERROR/CRITICAL/NONE/TRACE
diagnostics.client-log-level
Changes the log-level of the clients.
INFO
DEBUG/WARNING/ERROR/CRITICAL/NONE/TRACE
diagnostics.latency-measurement
Statistics related to the latency of each operation would be tracked.
Off
On/Off
diagnostics.dump-fd-stats
Statistics related to file-operations would be tracked.
Off
On
features.read-only
Enables you to mount the entire volume as read-only for all the clients (including NFS clients) accessing it.
Off
On/Off
features.lock-heal
Enables self-healing of locks when the network disconnects.
On
On/Off
features.quota-timeout
For performance reasons, quota caches the directory sizes on client. You can set timeout indicating the maximum duration of directory sizes in cache, from the time they are populated, during which they are considered valid
0
0 - 3600 secs
geo-replication.indexing
Use this option to automatically sync the changes in the filesystem from Master to Slave.
Off
On/Off
network.frame-timeout
The time frame after which the operation has to be declared as dead, if the server does not respond for a particular operation.
1800 (30 mins)
1800 secs
network.ping-timeout
The time duration for which the client waits to check if the server is responsive. When a ping timeout happens, there is a network disconnect between the client and server. All resources held by server on behalf of the client get cleaned up. When a reconnection happens, all resources will need to be re-acquired before the client can resume its operations on the server. Additionally, the locks will be acquired and the lock tables updated. This reconnect is a very expensive operation and should be avoided.
42 Secs
42 Secs
nfs.enable-ino32
For 32-bit nfs clients or applications that do not support 64-bit inode numbers or large files, use this option from the CLI to make Gluster NFS return 32-bit inode numbers instead of 64-bit inode numbers.
Off
On/Off
nfs.volume-access
Set the access type for the specified sub-volume.
read-write
read-write/read-only
nfs.trusted-write
If there is an UNSTABLE write from the client, STABLE flag will be returned to force the client to not send a COMMIT request. In some environments, combined with a replicated GlusterFS setup, this option can improve write performance. This flag allows users to trust Gluster replication logic to sync data to the disks and recover when required. COMMIT requests if received will be handled in a default manner by fsyncing. STABLE writes are still handled in a sync manner.
Off
On/Off
nfs.trusted-sync
All writes and COMMIT requests are treated as async. This implies that no write requests are guaranteed to be on server disks when the write reply is received at the NFS client. Trusted sync includes trusted-write behavior.
Off
On/Off
nfs.export-dir
This option can be used to export specified comma separated subdirectories in the volume. The path must be an absolute path. Along with path allowed list of IPs/hostname can be associated with each subdirectory. If provided connection will allowed only from these IPs. Format: \<dir>[(hostspec[hostspec...])][,...]. Where hostspec can be an IP address, hostname or an IP range in CIDR notation.Note: Care must be taken while configuring this option as invalid entries and/or unreachable DNS servers can introduce unwanted delay in all the mount calls.
No sub directory exported.
Absolute path with allowed list of IP/hostname
nfs.export-volumes
Enable/Disable exporting entire volumes, instead if used in conjunction with nfs3.export-dir, can allow setting up only subdirectories as exports.
On
On/Off
nfs.rpc-auth-unix
Enable/Disable the AUTH_UNIX authentication type. This option is enabled by default for better interoperability. However, you can disable it if required.
On
On/Off
nfs.rpc-auth-null
Enable/Disable the AUTH_NULL authentication type. It is not recommended to change the default value for this option.
On
On/Off
nfs.rpc-auth-allow\<IP- Addresses>
Allow a comma separated list of addresses and/or hostnames to connect to the server. By default, all clients are disallowed. This allows you to define a general rule for all exported volumes.
Reject All
IP address or Host name
nfs.rpc-auth-reject\<IP- Addresses>
Reject a comma separated list of addresses and/or hostnames from connecting to the server. By default, all connections are disallowed. This allows you to define a general rule for all exported volumes.
Reject All
IP address or Host name
nfs.ports-insecure
Allow client connections from unprivileged ports. By default only privileged ports are allowed. This is a global setting in case insecure ports are to be enabled for all exports using a single option.
Off
On/Off
nfs.addr-namelookup
Turn-off name lookup for incoming client connections using this option. In some setups, the name server can take too long to reply to DNS queries resulting in timeouts of mount requests. Use this option to turn off name lookups during address authentication. Note, turning this off will prevent you from using hostnames in rpc-auth.addr.* filters.
On
On/Off
nfs.register-with-portmap
For systems that need to run multiple NFS servers, you need to prevent more than one from registering with portmap service. Use this option to turn off portmap registration for Gluster NFS.
On
On/Off
nfs.port \<PORT- NUMBER>
Use this option on systems that need Gluster NFS to be associated with a non-default port number.
NA
38465- 38467
nfs.disable
Turn-off volume being exported by NFS
Off
On/Off
performance.write-behind-window-size
Size of the per-file write-behind buffer.
1MB
Write-behind cache size
performance.io-thread-count
The number of threads in IO threads translator.
16
0-65
performance.flush-behind
If this option is set ON, instructs write-behind translator to perform flush in background, by returning success (or any errors, if any of previous writes were failed) to application even before flush is sent to backend filesystem.
On
On/Off
performance.cache-max-file-size
Sets the maximum file size cached by the io-cache translator. Can use the normal size descriptors of KB, MB, GB,TB or PB (for example, 6GB). Maximum size uint64.
2 \^ 64 -1 bytes
size in bytes
performance.cache-min-file-size
Sets the minimum file size cached by the io-cache translator. Values same as "max" above
0B
size in bytes
performance.cache-refresh-timeout
The cached data for a file will be retained till 'cache-refresh-timeout' seconds, after which data re-validation is performed.
1s
0-61
performance.cache-size
Size of the read cache.
32 MB
size in bytes
server.allow-insecure
Allow client connections from unprivileged ports. By default only privileged ports are allowed. This is a global setting in case insecure ports are to be enabled for all exports using a single option.
On
On/Off
server.grace-timeout
Specifies the duration for the lock state to be maintained on the server after a network disconnection.
10
10 - 1800 secs
server.statedump-path
Location of the state dump file.
tmp directory of the brick
New directory path
storage.health-check-interval
Number of seconds between health-checks done on the filesystem that is used for the brick(s). Defaults to 30 seconds, set to 0 to disable.
30
 
 
 
8.2 配置存储卷的通信类型

GlusterFS支持三种数据传输类型，分别是TCP,RDMA 以及二种混合的方式。
1) 在修改传输类型前需要从所有客户机上先卸载该存储卷： # umount mount-point
2) 停止存储卷服务：# gluster volume stop volname
3) 修改传输类型：# gluster volume set volname config.transport tcp,rdma OR tcp OR rdma
4) 在所有客户机上使用指定传输类型选项来挂接存储卷：# mount -t glusterfs -o transport=rdma server1:/test-volume /mnt/glusterfs
 
8.3 在线扩展存储卷

GlusterFS支持在线对已经使用的存储卷进行扩容，比如补充添加更多的bricks进来，但是新增加的bricks数量需要满足原存储卷的数据存储分布规则要求。
1) 在集群的第一个节点上执行以下命令，实现可信主机池扩容：
# gluster peer probe server4 --假设是向已有3个节点的cluster中添加第4个节点
Probe successful
 
2) 向逻辑存储卷中追加更多的bricks：
# gluster volume add-brick test-volume server4:/exp4
Add Brick successful
 
3) 检查存储卷的状态：
# gluster volume info
4) 执行命令使数据在所有bricks上重新均衡分布：
# gluster volume rebalance test-volume start
 
8.4 在线缩小存储卷

在从逻辑存储卷中删除指定的bricks时，删除的bricks目标和数量都需要和该存储卷的数据冗余机制相匹配。指定的bricks虽然被从存储卷中删除了，但然可以通过直接访问brick来访问其数据。
1) 移除指定的brick
移除bricks的命令格式为：# gluster volume remove-brick start
例如：
# gluster volume remove-brick test-volume server2:/exp2 force
Remove Brick successful
2) 查看被移除了的brick的状态
# gluster volume remove-brick test-volume server2:/exp2 status
  Node                                       Rebalanced-files  size  scanned       status
  ---------  ----------------  ----  -------  -----------
617c923e-6450-4065-8e33-865e28d9428f    34   340      162   in progress
 
3) 查看存储卷的状态
# gluster volume info
4) 重新分布数据
# gluster volume rebalance test-volume start
 
8.5 替换发生错误的brick

使用什么方法来替换出现错误的brick，需要视逻辑存储卷的数据冗余机制来定。
对于一个分布存储逻辑卷，方法是先移除指定brick，然后新增一个brick，最后执行数据均衡分布命令。
对于一个镜像存储卷或分布式镜像存储卷，方法是使用replace-brick命令。
1) 一个维护分布式存储卷的例子
当前存储卷中的信息：
Bricks:
Brick1: Server1:/home/gfs/r2_0
Brick2: Server1:/home/gfs/r2_1
先增加新brick进来：
gluster volume add-brick r2 Server1:/home/gfs/r2_2
着手移除有错误的brick：
gluster volume remove-brick r2 Server1:/home/gfs/r2_1 start
当上一步执行完成后，对变更进行确认：
gluster volume remove-brick r2 Server1:/home/gfs/r2_1 commit
现在的存储卷管理信息已经变为：
Bricks:
Brick1: Server1:/home/gfs/r2_0
Brick2: Server1:/home/gfs/r2_2
2) 一个维护镜像复制或分布式镜像复制存储卷的例子
我们演示的是对一个数据冗余度为2的存储卷r2，使用新的Server1:/home/gfs/r2_5替换出现问题了的Server1:/home/gfs/r2_0 。
当前存储卷中的信息：
Volume Name: r2    Type: Distributed-Replicate    Volume ID: 24a0437a-daa0-4044-8acf-7aa82efd76fd    Status: Started    Number of Bricks: 2 x 2 = 4    Transport-type: tcp    Bricks:    Brick1: Server1:/home/gfs/r2_0    Brick2: Server2:/home/gfs/r2_1    Brick3: Server1:/home/gfs/r2_2    Brick4: Server2:/home/gfs/r2_3
确认几点信息：被新增进来的brick中为空；除了出现故障的brick，卷中其它brick的状态都需要是ok；如果将被替换下来的brick的状态还是在线状态，则需要手工把它设置为离线。
#gluster volume status
Status of volume: r2
Gluster process                          Port    Online    Pid    Brick Server1:/home/gfs/r2_0            49152    Y    5342
Brick Server2:/home/gfs/r2_1            49153    Y    5354
Brick Server1:/home/gfs/r2_2            49154    Y    5365
Brick Server2:/home/gfs/r2_3            49155    Y    5376
从上面信息中可以看到每个brick都有一个进程负责提供服务，pid是它的进程ID。
①　请登录上面主机Server1，然后手工终止进程“5342”：#kill  5342
②　使用gluster存储卷的fuse mount（这个例子里是/mnt/r2）创建一份元数据信息，以实现向新的brick同步数据（from Server1:/home/gfs/r2_1 to Server1:/home/gfs/r2_5）
通过在/mnt/r2挂接点下创建和删除一个子目录，设置和清除一项元数据信息，来触发Glusterfs的自我修复进程开始工作，即执行from Server1:/home/gfs/r2_1 to Server1:/home/gfs/r2_5的自修复工作。
mkdir /mnt/r2/<name-of-nonexistent-dir>
rmdir /mnt/r2/<name-of-nonexistent-dir>setfattr -n trusted.non-existent-key -v abc /mnt/r2setfattr -x trusted.non-existent-key  /mnt/r2
查看与将被替换的brick处于镜像关系的另一个brick的元数据状态：
#getfattr -d -m. -e hex /home/gfs/r2_1
# file: home/gfs/r2_1security.selinux=0x756e636f6e66696e65645f753a6f626a6563745f723a66696c655f743a733000trusted.afr.r2-client-0=0x000000000000000300000002 <<---- xattrs are marked     from source brick Server2:/home/gfs/r2_1trusted.afr.r2-client-1=0x000000000000000000000000trusted.gfid=0x00000000000000000000000000000001trusted.glusterfs.dht=0x0000000100000000000000007ffffffetrusted.glusterfs.volume-id=0xde822e25ebd049ea83bfaa3c4be2b440
 
③　查看存储卷r2的“heal info”
#gluster volume heal r2 info
    Brick Server1:/home/gfs/r2_0    Status: Transport endpoint is not connected    Brick Server2:/home/gfs/r2_1    /    Number of entries: 1    Brick Server1:/home/gfs/r2_2    Number of entries: 0    Brick Server2:/home/gfs/r2_3    Number of entries: 0
从上面我们可以看到/home/gfs/r2_1需要修复。
④　执行替换brick的命令
#gluster volume replace-brick r2 Server1:/home/gfs/r2_0 Server1:/home/gfs/r2_5 commit force
volume replace-brick: success: replace-brick commit successful
可以看到新的brick已经上线：
#gluster volume status
Status of volume: r2
Gluster process                        Port    Online    Pid
------------------------------------------------------------------------------
Brick Server1:/home/gfs/r2_5            49156    Y    5731 <<<---- new  brick is online
Brick Server2:/home/gfs/r2_1            49153    Y    5354
Brick Server1:/home/gfs/r2_2            49154    Y    5365
Brick Server2:/home/gfs/r2_3            49155    Y    5376
用户可以使用gluster volume heal info来追踪修复进度。当修复工作完成后，再查看/home/gfs/r2_1的元数据信息已经变为：
#getfattr -d -m. -e hex /home/gfs/r2_1getfattr: Removing leading '/' from absolute path names# file: home/gfs/r2_1security.selinux=0x756e636f6e66696e65645f753a6f626a6563745f723a66696c655f743a733000trusted.afr.r2-client-0=0x000000000000000000000000 <<-- Pending changelogs are clearedtrusted.afr.r2-client-1=0x000000000000000000000000trusted.gfid=0x00000000000000000000000000000001trusted.glusterfs.dht=0x0000000100000000000000007ffffffetrusted.glusterfs.volume-id=0xde822e25ebd049ea83bfaa3c4be2b440
Ok，此时查看gluster volume heal r2 info 已经显示没有任何需要被修复的条目了。
8.6 存储卷数据的重新均衡分布

一个逻辑存储卷在经过了扩容或移除存储块后，需要对其数据进行重新均衡分布。有两种使用场景，分别是“修复布局”和“修复布局并迁移数据”。
1) 修复GlusterFS存储卷布局
在GlusterFS3.6及以后版本，布局信息的设置会考虑到brick的大小，一个20TB的brick将会被分配2倍于10TB的brick所能存放的文件数量。
# gluster volume rebalance test-volume fix-layout start
Starting rebalance on volume test-volume has been successful
 
2) 修复布局并迁移数据
是否需要迁移数据，要看存储卷的数据冗余策略而定。在需要修复并局并迁移数据时，可以执行以下命令。
Start the rebalance operation：
# gluster volume rebalance test-volume startStarting rebalancing on volume test-volume has been successful
Start the migration operation forcefully：
# gluster volume rebalance test-volume start forceStarting rebalancing on volume test-volume has been successful
查看进度和状态：
# gluster volume rebalance test-volume status
 
3) 手工停止数据的重新均衡
可以使用命令人为得中断存储卷的数据重新均衡的任务。
# gluster volume rebalance test-volume stopNode                                        Rebalanced-files  size  scanned       status617c923e-6450-4065-8e33-865e28d9428f               59   590      244       stoppedStopped rebalance process on volume test-volume
 
8.7 停止存储卷

# gluster volume stop test-volumeStopping volume will make its data inaccessible. Do you want to continue? (y/n)
Stopping volume test-volume has been successful
8.8 删除存储卷

# gluster volume delete test-volumeDeleting volume will erase all information about the volume. Do you want to continue? (y/n)
Deleting volume test-volume has been successful
8.9 怎样使用镜像卷的自修复服务

现在已经有一个可以实现发现和干预数据修复问题的后台进程，它可以每10分钟执行一次扫描，诊断和进行自动得修复工作。你可以查看存储卷中处于脑裂状态的文件列表，然后手工地触发该进程执行整卷的或指定文件的修复操作。
1) 对处于数据不一致状态的文件进行修复
# gluster volume heal test-volumeHeal operation on volume test-volume has been successful
2) 对整个存储卷上所有的文件进行修复
# gluster volume heal test-volume fullHeal operation on volume test-volume has been successful
3) 查看需要进行修复的文件列表
# gluster volume heal test-volume infoBrick :/gfs/test-volume_0Number of entries: 0Brick :/gfs/test-volume_1Number of entries: 101/95.txt/32.txt/55.txt/85.txt...
4) 查看已经被成功修复了的文件列表
# gluster volume heal test-volume info healedBrick :/gfs/test-volume_0Number of entries: 0Brick :/gfs/test-volume_1Number of entries: 69/99.txt/93.txt/37.txt/46.txt...
5) 查看修复失败的文件列表
# gluster volume heal test-volume info failed
Brick :/gfs/test-volume_0
Number of entries: 0
Brick server2:/gfs/test-volume_3
Number of entries: 72
/90.txt
/87.txt
/24.txt
...
6) 查看一个存储卷上有哪些数据处于脑裂状态
# gluster volume heal test-volume info split-brainBrick server1:/gfs/test-volume_2Number of entries: 12/83.txt/28.txt/69.txt...Brick :/gfs/test-volume_2Number of entries: 12/83.txt/28.txt/69.txt...
 
8.10 启用NUFA转换器

Non Uniform File Allocation转换器的设计意图是提高本地磁盘的访问性能，可以应用于分布式和镜像式存储卷中。该转换器会力图优先在本地brick中落盘，再通过网络写入其它brick。启用NUFA功能需要满足几个条件：
1) 每个存储主机节点上只提供一个brick；
2) 需要使用FUSE客户端，且NUFA不支持NFSA或SMB；
3) 一个客户机如果要挂接启用了NUFA 功能的存储卷，那么这个客户机本身必须在可信存储池内；
启用NUFA的命令是：
 # gluster volume set VOLNAME cluster.nufa enable on
 
8.11 关于BitRot磁盘错误检测功能

有一些轻微的磁盘错误虽然已经发生了，但还未没发现或读取到，而暂时处于潜伏状态中。BitRot功能可以主动发现并进行坏道的修补。这个功能默认是关闭的。
打开BitRot功能：
# gluster volume bitrot <VOLNAME> enable
关闭BitRot功能：
# gluster volume bitrot <VOLNAME> disable
启用BitRot功能地，会在每个存储节点主机上启动一个“Signer & Scrubber daemon”进程。我们可以根据数据的重要性来调整该进程的工作力度和频率。
参数1：scrub-throttle
# volume bitrot <VOLNAME> scrub-throttle lazy# volume bitrot <VOLNAME> scrub-throttle normal# volume bitrot <VOLNAME> scrub-throttle aggressive
 
参数2：scrub-frequency
# volume bitrot <VOLNAME> scrub-frequency daily# volume bitrot <VOLNAME> scrub-frequency weekly# volume bitrot <VOLNAME> scrub-frequency biweekly# volume bitrot <VOLNAME> scrub-frequency monthly
 
暂停Scrubber进程：
# volume bitrot <VOLNAME> scrub pause
继续运行Scrubber进程：
# volume bitrot <VOLNAME> scrub resume
 
 
9. 怎样使用过滤器方式修改.vol文件

任何直接修改.vol文件的尝试都是有风险的。建议使用命令行客户端工具（‘gluster foo’）重建.vol文件。
第二种办法就是使用过滤器方式。你可以在 '/usr/lib*/glusterfs/\$VERSION/filter'目录下创建一个可执行脚本文件。每次.vol文件被更新时，这会先执行这些脚本文件，并把.vol文件的文件名作为参数传递给它们。这些脚本文件的内容可能类似：
#!/bin/sh`\ 
sed -i 'some-sed-magic' "$1"
 
10. 怎样处理Peer Rejectd State故障

当你使用gluster peer status来查看存储节点状态时，看到某个节点处于peer rejectd state状态，那么这个节点与其它集群中其它节点的数据同步出现的错误。下面是修复办法。
在这个出现故障的主机节点上面：
1) 停glusterd进程；
2) 进入/var/lib/glusterd目录，删除除了glusterd.info文件之外的其它全部内容；
3) 重新启动glusterd进程；
4) Probe一个正常运行的节点；
5) 再次重启glusterd进程，查看gluster peer status的状态；
6) 如果以上操作仍未能恢复故障节点，那么反复重启几次glusterd进程试试看，或者把全部步骤操作几次试试。
11. Logging

1) Glusterd:  /var/log/glusterfs/etc-glusterfs-glusterd.vol.log
2) Gluster cli command: /var/log/glusterfs/cmd_history.log
3) Bricks: /var/log/glusterfs/bricks/<path extraction of brick path>.log
4) Rebalance: /var/log/glusterfs/VOLNAME-rebalance.log
5) Self heal deamon: /var/log/glusterfs/glustershd.log
6) Gluster NFS: /var/log/glusterfs/nfs.log
7) SAMBA Gluster: /var/log/samba/glusterfs-VOLNAME-<ClientIp>.log
8) FUSE Mount: /var/log/glusterfs/<mountpoint path extraction>.log
9) Geo-replication: /var/log/glusterfs/geo-replication/<master>   /var/log/glusterfs/geo-replication-slaves
10) Gluster volume heal VOLNAME info command: /var/log/glusterfs/glfsheal-VOLNAME.log
12. Brick命名风格

建议把brick在本地的挂载点设置为：
    /data/glusterfs/`<volume>`/`<brick>`/brick
1) 例如，对一每个存储主机提供一个brick的情况
我们假设/dev/sdb用作glusterfs存储，卷名为myvol1，共4个节点。
在4个主机上：
     mkdir -p /data/glusterfs/myvol1/brick1    mount /dev/sdb1 /data/glusterfs/myvol1/brick1
在任一个主机上：
    gluster volume create myvol1 replica 2 server{1..4}:/data/glusterfs/myvol1/brick1/brick
最终我们在myvol1卷上创建了一个/brick的目录。
2) 对于每个存储主机提供2个bricks的情况
假设每个主机上都有/dev/sdb, /dev/sdc用于glusterfs存储。我们将要创建一个名为myvol2的卷。
在4个主机上：
     mkdir -p /data/glusterfs/myvol2/brick{1,2}     mount /dev/sdb1 /data/glusterfs/myvol2/brick1     mount /dev/sdc1 /data/glusterfs/myvol2/brick2
在任一个主机上：
    gluster volume create myvol2 replica 2 server{1..4}:/data/glusterfs/myvol2/brick1/brick server{1..4}:/data/glusterfs/myvol2/brick2/brick
13. 管理Geo-replication

Geo-replication可以基于局域网、城域网或互联网实现逻辑存储卷的镜像复制，使用主从模式工作，底层复制基于rsync实现。Master需要是一个GlusterFS逻辑存储卷，Slave可以是一个主机上的本地目录（/path/to/dir），也可以是另一个GlusterFS存储卷（gluster://host:volname）。以上路径均需要可以通过SSH进行访问（ssh://root@remote-host:/path/to/dir或ssh://root@remote-host:gluster://localhost:volname）。
13.1 镜像复制卷VS Geo复制卷

Replicated Volumes
Geo-replication
Mirrors data across clusters
Mirrors data across geographically distributed clusters
Provides high-availability
Ensures backing up of data for disaster recovery
Synchronous replication (each and every file operation is sent across all the bricks)
Asynchronous replication (checks for the changes in files periodically and syncs them on detecting differences)
13.2 环境配置

1) 请在goe-replication集群内每个节点上都部署NTP时间服务，以统一时间。
2) 请在主从节点间建立SSH免密码登录：
在主节点（where geo-replication Start command will be issued）上执行以下命令：
# ssh-keygen -f /var/lib/glusterd/geo-replication/secret.pem
敲两下回车，直接设置为空密码。
在master节点上执行以下命令：
# ssh-copy-id -i /var/lib/glusterd/geo-replication/secret.pem.pub @
13.3 怎样建立一个安全的Geo-replication从机

主要有3种办法，分别是限制可以使用的远程命令，从机使用Mountbroker，使用IP访问控制。
http://gluster.readthedocs.org/en/latest/Administrator%20Guide/Geo%20Replication/#setting-up-the-environment-for-a-secure-geo-replication-slave
13.4 启停和查看Geo-replication

# gluster volume geo-replication Volume1 example.com:/data/remote_dir startStarting geo-replication session between Volume1example.com:/data/remote_dir has been successful
查看状态：
# gluster volume geo-replication Volume1 example.com:/data/remote_dir status# gluster volume geo-replication Volume1 example.com:/data/remote_dir statusMASTER    SLAVE                            STATUS______    ______________________________   ____________Volume1 root@example.com:/data/remote_dir  Starting....
# gluster volume geo-replication MASTER status
查看geo-replication卷的配置参数：
# gluster volume geo-replication Volume1 example.com:/data/remote_dir config
停止geo-replication服务：
# gluster volume geo-replication Volume1 example.com:/data/remote_dir stopStopping geo-replication session between Volume1 andexample.com:/data/remote_dir has been successful
13.5 使用从节点来恢复数据

在主节点发生数据损坏后，可以使用从机的数据恢复到主节点。以下为一个演示。
主节点上：
machine1# gluster volume info
Type: Distribute
Status: Started
Number of Bricks: 2
Transport-type: tcp
Bricks:
Brick1: machine1:/export/dir16
Brick2: machine2:/export/dir16
Options Reconfigured:
geo-replication.indexing: on
数据是从主节点的Volume1同步到从机的example.com:/data/remote_dir。
在主节点上查看geo-replication session的状态：
# gluster volume geo-replication Volume1 root@example.com:/data/remote_dir status
在发生故障前：
假定主节点存储卷上有100个文件，挂接在客户机的/mnt/gluster。在客户机上查看文件列表：
client# ls /mnt/gluster | wc –l
100
在从机的目录中(example.com) 也会有和主节点相同的数据：
example.com# ls /data/remote_dir/ | wc –l
100
发生故障后：
假设machine2的brick坏了，Geo-replication session的状态从 "OK" 变为"Faulty"。
    # gluster volume geo-replication Volume1 root@example.com:/data/remote_dir status
因为是分布式的存储卷，所以machine2坏了后，数据已经丢失。这时只有从节点上还保留了完整的数据备份。接下来我们使用从节点的数据进行恢复。
先停止所有的Master's geo-replication sessions：
    machine1# gluster volume geo-replication Volume1
    example.com:/data/remote_dir stop
重复以上操作，停止所有的master volume上的geo-replication会话。
执行以下命令进行损坏存储块的替换：
    machine1# gluster volume replace-brick Volume1 machine2:/export/dir16 machine3:/export/dir16 commit force
查看替换后的master volume状态：
    machine1# gluster volume info
    Volume Name: Volume1
    Type: Distribute
    Status: Started
    Number of Bricks: 2
    Transport-type: tcp
    Bricks:
    Brick1: machine1:/export/dir16
    Brick2: machine3:/export/dir16
    Options Reconfigured:
    geo-replication.indexing: on
手工执行rsync命令，从从节点把数据同步到master volume's client (mount point)：
    example.com# rsync -PavhS --xattrs --ignore-existing /data/remote_dir/ client:/mnt/gluster
重新启动geo-replication服务：
    machine1# gluster volume geo-replication Volume1
    example.com:/data/remote_dir start
    Starting geo-replication session between Volume1 &
    example.com:/data/remote_dir has been successful
 
13.6 正确地手工调整geo-replication主从节点的系统时间

1) 停服务    # gluster volume geo-replication stop
2) 停索引服务  # gluster volume set  geo-replication.indexing off
3) 手工对主从节点时间进行设置
4) 重新启动服务    # gluster volume geo-replication start
 
http://gluster.readthedocs.org/en/latest/Administrator%20Guide/Distributed%20Geo%20Replication/
14. 分布式Geo-replication （glusterfs-3.5）

该功能是从3.5版本开始加入进来的。在Geo-replication中，只有有master volume中的一个节点参与到向从机的数据同步工作中去，而在分布式Geo-replication中则是master volume中的每个节点均加入到与从机的数据同步管理中了。
与Geo-replication相比，文件变化的检测机制也发生了改变，从原来的每次同步前要扫描整个glusterfs文件系统变为了通过”changelog xlator”来确定需要同步的文件列表。
在分布式Geo-replication中的另一个新功能是，提供一“tar+ssh”的传输方式。这种方式在处理有大量小文件的场景时可以明显提升传输性能。
关于怎样配置和管理分布式Geo-replication服务，请参见以下链接。
http://gluster.readthedocs.org/en/latest/Administrator%20Guide/Distributed%20Geo%20Replication/#using-distributed-geo-replication
15. 怎样管理目录配额

GlusterFS提供了基于卷或目录的存储空间配额管理功能，存储系统管理员可以设置空间分配与使用的限额。目前仅支持hard limits，即使用超出配额的空间或inodes都被禁止。目前提供了基于目录和卷的配额管理功能，你甚至可以先行为一个未创建的目录设置好存储使用配额，一旦该目录被创建了，就会自动应用先前指定的存储配额策略。
1) 启动或停用配额功能
# gluster volume quota test-volume enableQuota is enabled on /test-volume
# gluster volume quota test-volume disableQuota translator is disabled on /test-volume
2) 设置存储配额数值
在设置配额时，默认得把存储卷作为存储环境的“/”，配额限制是基于它的相对路径进行设置。例如在卷空间中创建的一个子目录“data”，我们为其设定可以使用的glusterfs存储卷空间为10GB，可以这样操作：
# gluster volume quota test-volume limit-usage /data 10GBUsage limit has been set on /data
注：如果存储路径的多个层次目录进行了配额限制，那么glusterfs会优先选择执行相对更严格的限制策略。
移除磁盘的存储配额使用限制：
# gluster volume quota test-volume remove /dataUsage limit set on /data is removed
 
3) 怎样查看磁盘的存储配额限制
# gluster volume quota test-volume list/Test/data    10 GB       6 GB/Test/data1   10 GB       4 GB
或只查看一个指定的目录：
# gluster volume quota test-volume list /data/Test/data    10 GB       6 GB
4) 请启用quota-deem-statfs功能
如果不启用quota-deem-statfs功能，那么在客户机上使用“df -hT”查看挂接到本地的存储卷时，会发现所显示出来的存储分区的全部空间、空闲空间实际上就是glusterfs volume整卷的统计数据。尤其是在为允许用户使用的最大存储空间上已经做了配额限制的情况下，这样的显示结果容易产生混乱。
而启用quota-deem-statfs功能的结果就是，显示给客户机上用户的”df -hT”信息会与用户得到的存储配额限制保持一致。
打开： # gluster volume set test-volume features.quota-deem-statfs on
关闭： # gluster volume set test-volume features.quota-deem-statfs off
5) 更新配额信息的缓存
默认地，在客户机本地会缓存一份存储卷配额信息的缓存，用于客户机在写数据时查询配额信息。这份缓存的配额信息有一个超时时间，如果超时时间比较长，可能会引起一个问题，就是虽然客户机向存储卷写入的实际数据量已经超出配额限制了，但本地缓存的配额管理信息却没有及时得到更新。这样一来，就造成了客户机使用了超出配额限制的空间。因此这个超时时间需要权衡后设置一个相对合理的值。例如，
# gluster volume set test-volume features.quota-timeout 5
Set volume successful
 
16. GlusterFS存储卷快照管理

GlusterFS存储卷快照功能是基于操作系统的LVM快照功能来实现的。因此，使用glusterfs快照功能需要满足几个条件：
1) 每个brick都必须是支持自动精简配置功能（thinly provisioned）的独立LVM卷；
2) 除了brick外，在Brick LVM不能存放其它数据；
3) 任一个brick都不能是thick LVM上的；
4) Gluster版本需要3.6或更高。
GlusterFS存储卷快照可以用于灾难恢复，支持在线创建快照，但是在创建快照的过程中，会对部份文件操作产生堵塞，直到快照创建完成。这个堵塞的默认超时时间是2分钟，也就是说超过2分钟后，快照会创建失败，同时解除对文件操作的堵塞。
16.1 怎样创建精简配置的LVM系统分区

RedHat企业版6.4及以后的版本支持了自动精简配置的LVM分区功能。这个功能允许你把存储池中的空间超额分配给更多的用户，用户得到的空间配额并不是一次分配全部存储空间，而是动态增长的。需要注意的是，创建的thin pool和thin volumes都必须是在同一个主机节点上的，不支持跨节点的实现。
1) 使用本地磁盘/dev/cciss/c0d1创建分区/dev/cciss/c0d1p1，设置分区类型为8e
2) 创建PV
#pvcreate /dev/cciss/c0d1p1
#pvdisplay
3) 把创建的PV做成VG
  #vgcreate vg0 /dev/cciss/c0d1p1 //创建成VG
  #vgdisplay vg0
4) 创建精简配置的LV
# lvcreate -L 1.3T -T vg0/mythinpool -V3T -n thinvolume
  Rounding up size to full physical extent 1.30 TiB
  Logical volume "thinvolume" created.
“-L”，指定LV分区的实际大小为1.3TB。
“-T”，设定启用精简配置功能。
“-V”，设定该thinvolume卷的虚拟大小为3TB。
其它：创建的thin pool名为mythinpool，创建的thin volume名为thinvolume。
 
5) 查看已经创建好的LV：
# lvs
  LV   VG   Attr  LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  mythinpool vg0  twi-aotz-- 1.30t                   0.00   0.44                            
  thinvolume vg0  Vwi-a-tz-- 3.00t mythinpool        0.00        
6) 查看我们创建的使用了精简配置功能的LVM卷：
# fdisk -l /dev/mapper/vg0-thinvolume
Disk /dev/mapper/vg0-thinvolume: 3298.5 GB, 3298534883328 bytes
255 heads, 63 sectors/track, 401024 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 524288 bytes / 1048576 bytes
Disk identifier: 0x00000000
16.2 快照管理

1) 创建快照
Syntax : gluster snapshot create <snapname> <volname> [no-timestamp] [description <description>] [force]
注：GlusterFS存储卷在创建快照时，要求卷的状态正常且处于运行中。
2) 克隆快照
Syntax : gluster snapshot clone <clonename> <snapname>
3) 从快照中恢复
Syntax : gluster snapshot restore <snapname>
注：从快照中恢复glusterfs卷数据的操作，要求存储卷处于下线状态，否则恢复快照的动作会失败。当一个快照已经被恢复到存储卷后，快照列表中的这个快照也会变成不可用。
4) 删除快照
Syntax : gluster snapshot delete (all | <snapname> | volume <volname>)
5) 查看快照列表
Syntax: gluster snapshot list [volname]
6) 查看快照的详细信息
Syntax: gluster snapshot info [(snapname | volume <volname>)]
7) 查看快照的状态
Syntax: gluster snapshot status [(snapname | volume <volname>)]
8) 快照行为的其它配置
Syntax: snapshot config [volname] ([snap-max-hard-limit ]) | ([auto-delete <enable|disable>]) | ([activate-on-create <enable|disable>])
9) 激活与禁用快照
Syntax: gluster snapshot activate <snapname>
Syntax: gluster snapshot deactivate <snapname>
10) 怎样访问快照中的数据
挂接快照在本地路径：
mount -t glusterfs host1:/snaps/my-snap/vol /mnt/snapshot
注：host1为某一可信主机，快照名为my-snap，vol为存储卷的名称。
另外还有一种办法，可以让客户机看到快照的只读数据。这需要启用glusterfs的一个特性功能“features.uss”。
17. 怎样监控GlusterFS的工作负载

17.1 启用数据收集和分析功能

默认地，数据收集与分析功能是关闭的，你需要主动打开这一功能：
# gluster volume profile test-volume start
Profiling started on test-volume
此时，再查看卷的状态信息时会多出以下两个配置项：
diagnostics.count-fop-hits: ondiagnostics.latency-measurement: on
查看每个brick的I/O统计信息：
# gluster volume profile test-volume infoBrick: Test:/export/2Cumulative Stats:Block                     1b+           32b+           64b+Size:       Read:                0              0              0       Write:             908             28              8Block                   128b+           256b+         512b+Size:       Read:                0               6             4       Write:               5              23            16Block                  1024b+          2048b+        4096b+Size:       Read:                 0              52           17       Write:               15             120          846Block                   8192b+         16384b+      32768b+Size:       Read:                52               8           34       Write:              234             134          286Block                                  65536b+     131072b+Size:       Read:                               118          622       Write:                             1341          594%-latency  Avg-      Min-       Max-       calls     Fop          latency   Latency    Latency  ___________________________________________________________
4.82      1132.28   21.00      800970.00   4575    WRITE
5.70       156.47    9.00      665085.00   39163   READDIRP
11.35      315.02    9.00     1433947.00   38698   LOOKUP
11.88     1729.34   21.00     2569638.00    7382   FXATTROP
47.35   104235.02 2485.00     7789367.00     488   FSYNC------------------------------------Duration     : 335BytesRead    : 94505058BytesWritten : 195571980
使用后关闭该统计功能：
# gluster volume profile test-volume stop
17.2 使用“TOP Command”查看最影响glusterfs性能的前100个系统动作

这些Top command可以统计到read, wirte, file open calls, file write calls, directory open calls, directory real calls. 
1) 查看Open fd Count（list of files being opened）
查看当前打开的文件数、最大打开的文件数量并列出排在前10的open calls：
# gluster volume top open brick list-cnt
Brick: server:/export/dir1
Current open fd's: 34 Max open fd's: 209
             ==========Open file stats========open call count          file name2               /clients/client0/~dmtmp/PARADOX/COURSES.DB11              /clients/client0/~dmtmp/PARADOX/ENROLL.DB11              /clients/client0/~dmtmp/PARADOX/STUDENTS.DB10              /clients/client0/~dmtmp/PWRPNT/TIPS.PPT10              /clients/client0/~dmtmp/PWRPNT/PCBENCHM.PPT9               /clients/client7/~dmtmp/PARADOX/STUDENTS.DB9               /clients/client1/~dmtmp/PARADOX/STUDENTS.DB9               /clients/client2/~dmtmp/PARADOX/STUDENTS.DB9               /clients/client0/~dmtmp/PARADOX/STUDENTS.DB9               /clients/client8/~dmtmp/PARADOX/STUDENTS.DB                
2) 查看那些排名靠前的读文件请求(file read calls)
# gluster volume top read brick list-cnt
Brick: server:/export/dir1
          ==========Read file stats======== read call count             filename116              /clients/client0/~dmtmp/SEED/LARGE.FIL64               /clients/client0/~dmtmp/SEED/MEDIUM.FIL54               /clients/client2/~dmtmp/SEED/LARGE.FIL54               /clients/client6/~dmtmp/SEED/LARGE.FIL54               /clients/client5/~dmtmp/SEED/LARGE.FIL54               /clients/client0/~dmtmp/SEED/LARGE.FIL54               /clients/client3/~dmtmp/SEED/LARGE.FIL54               /clients/client4/~dmtmp/SEED/LARGE.FIL54               /clients/client9/~dmtmp/SEED/LARGE.FIL54               /clients/client8/~dmtmp/SEED/LARGE.FIL
3) 查看那些排名靠前的写文件请求（file write calls）
# gluster volume top write brick list-cnt
Brick: server:/export/dir1
               ==========Write file stats========write call count   filename83                /clients/client0/~dmtmp/SEED/LARGE.FIL59                /clients/client7/~dmtmp/SEED/LARGE.FIL59                /clients/client1/~dmtmp/SEED/LARGE.FIL59                /clients/client2/~dmtmp/SEED/LARGE.FIL59                /clients/client0/~dmtmp/SEED/LARGE.FIL59                /clients/client8/~dmtmp/SEED/LARGE.FIL59                /clients/client5/~dmtmp/SEED/LARGE.FIL59                /clients/client4/~dmtmp/SEED/LARGE.FIL59                /clients/client6/~dmtmp/SEED/LARGE.FIL59                /clients/client3/~dmtmp/SEED/LARGE.FIL
4) 查看哪些目录被频繁打开(open calls on directory)
# gluster volume top opendir brick list-cnt
Brick: server:/export/dir1
         ==========Directory open stats========Opendir count     directory name1001              /clients/client0/~dmtmp454               /clients/client8/~dmtmp454               /clients/client2/~dmtmp454               /clients/client6/~dmtmp454               /clients/client5/~dmtmp454               /clients/client9/~dmtmp443               /clients/client0/~dmtmp/PARADOX408               /clients/client1/~dmtmp408               /clients/client7/~dmtmp402               /clients/client4/~dmtmp
5) 查看哪些目录被频繁读(read calls on directory)
# gluster volume top readdir brick list-cnt
==========Directory readdirp stats========readdirp count           directory name1996                    /clients/client0/~dmtmp1083                    /clients/client0/~dmtmp/PARADOX904                     /clients/client8/~dmtmp904                     /clients/client2/~dmtmp904                     /clients/client6/~dmtmp904                     /clients/client5/~dmtmp904                     /clients/client9/~dmtmp812                     /clients/client1/~dmtmp812                     /clients/client7/~dmtmp800                     /clients/client4/~dmtmp
6) 查看每个brick的读性能统计
实际上是使用的dd完成的测试，统计的是文件读的吞吐量
# gluster volume top read-perf bs 256 count 1 brick list-cnt
Brick: server:/export/dir1 256 bytes (256 B) copied, Throughput: 4.1 MB/s
7) 查看每个brick的写性能统计
# gluster volume top write-perf bs 256 count 1 brick list-cnt
 
17.3 怎样获取GlusterFS的Statedump统计信息

Statedump是一种导出GlusterFS运行环境和当前状态信息的机制，支持导出以几个方面的统计信息：
1) mem - Dumps the memory usage and memory pool details of the bricks.
2) iobuf - Dumps iobuf details of the bricks.
3) priv - Dumps private information of loaded translators.
4) callpool - Dumps the pending calls of the volume.
5) fd - Dumps the open fd tables of the volume.
6) inode - Dumps the inode tables of the volume.
命令格式：
#gluster volume statedump [nfs] 
[all|mem|iobuf|callpool|priv|fd|inode]
例如：
# gluster volume statedump test-volume
Volume statedump successful
导出的统计文件默认存放在/tmp下。
 
17.4 查看卷状态的命令及参数

# gluster volume status [all| []] [detail|clients|mem|inode|fd|callpool]
 
18. 怎样使用Cinder存储主机访问GlusterFS

我们在部署OpenStack云环境时经常使用Cinder作为持久化存储的解决方案，而Cinder只是一套提供了各种存储驱动接口的框架，必须与其它能提供物理存储能力的设备或软件集成使用。在这里，我们是对Cinder与GlusterFS进行集成，Cinder向上对接OpenStack，以GlusterFS作为底层的存储管理系统。以下为二者进行集成部署的步骤。
1) 确认Cinder系统的状态
使用Cinder list和Cinder delete查看并删除Cinder中可能存在的任何存储卷。
2) 在所有的Cinder存储主机上安装GlusterFS Client
#yum -y install glusterfs-fuse
 
3) 在所有的Cinder主机上修改配置文件并增加使用GlusterFS的配置
# openstack-config --set /etc/cinder/cinder.conf DEFAULT volume_driver cinder.volume.drivers.glusterfs.GlusterfsDriver # openstack-config --set /etc/cinder/cinder.conf DEFAULT glusterfs_shares_config /etc/cinder/shares.conf# openstack-config --set /etc/cinder/cinder.conf DEFAULT glusterfs_mount_point_base /var/lib/cinder/volumes
4) 为所有的Cinder主机创建GlusterFS存储卷列表
#vi /etc/cinder/shares.conf
    myglusterbox.example.org:myglustervol
注：如果有多个存储卷，可以填写多行，每行一个。
5) 打开Cinder主机的防火墙端口
在filter段落的“:OUTPUT ACCEPT”下面，增加以下内容：
-A INPUT -m state --state NEW -m tcp -p tcp --dport 111 -j ACCEPT
-A INPUT -m state --state NEW -m udp -p udp --dport 111 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 24007 -j ACCEPT-A INPUT -m state --state NEW -m tcp -p tcp --dport 24008 -j ACCEPT-A INPUT -m state --state NEW -m tcp -p tcp --dport 24009 -j ACCEPT-A INPUT -m state --state NEW -m tcp -p tcp --dport 24010 -j ACCEPT-A INPUT -m state --state NEW -m tcp -p tcp --dport 24011 -j ACCEPT-A INPUT -m state --state NEW -m tcp -p tcp --dport 38465:38469 -j ACCEPT
 
#service iptables restart
 
6)  重启Cinder服务
# for i in api scheduler volume; do  service openstack-cinder-${i} start; done
查看日志以确认服务正确启动了：
#tail -50 /var/log/cinder/volume.log
7) 测试Cinder与GlusterFS的集成效果
手工创建一个Cinder存储卷：
# cinder create --display_name myvol 10
查看创建结果和卷的状态：
#cinder list
查看Cinder本地生成的卷管理文件：
#ls -lah /var/lib/cinder/volumes/29e55f0f3d56494ef1b1073ab927d425/
     total 4.0K     drwxr-xr-x. 3 root   root     73 Apr  4 15:46 .     drwxr-xr-x. 3 cinder cinder 4.0K Apr  3 09:31 ..     -rw-rw-rw-. 1 root   root    10G Apr  4 15:46 volume-a4b97d2e-0f8e-45b2-9b94-b8fa36bd51b9
 
19. 是否需要调优Linux kernel for GlusterFS

在非常多的GlusterFS使用场景中，大家积累了一些通过调优内核参数，解决部分GlusterFS性能或任何其它问题的经验。这些内核参数的调优并不适合全部场景，建议从分析你的GlusterFS各种监控统计数据入手，带着问题寻找接近答案的调优方案。
1) vm.swappiness
控制系统内存进行swapping的比率。通常，对于重负载流式数据，建议将该参数置为0。
2) vm.vfs_cache_pressure
这个选项控制内核索回用于缓存目录数据结构和inode对象的那些内存的力度，默认值为100。如果设置为0，则内核完全不追回以上缓存消耗的内存，但应用容易陷入out of memory的后果。建议适当调大该参数，既缓存更多的目录项，也对内核负责。
3) vm.dirty_background_ratio and vm.dirty_ratio
这两个选项定义了内存中的脏数据所占比率，达到设置比例则内核将脏数据刷入磁盘。对于使用了大内存的主机节点，建议调低这个比率，否则每次要向磁盘刷入几十GB数据，对前台应用产生阻塞，严重影响性能。
4) "1" > /proc/sys/vm/pagecache
Pagecache是文件在磁盘中的缓存，如果像上面这样把该值设为1，意味着主机内存的1%将用于缓存文件内容。但是如果已经启用了第3个参数设置了内存脏数据比率，那么pagecache的设置效果就不是很可靠了。
 
 
GlusterFS Troubleshooting的内容详见：
http://gluster.readthedocs.org/en/latest/Administrator%20Guide/Troubleshooting/
http://gluster.readthedocs.org/en/latest/Troubleshooting/README/
 
GlusterFS文件系统读写性能测试详见：
http://gluster.readthedocs.org/en/latest/Administrator%20Guide/Performance%20Testing/


欢迎关注我的新浪微博：运维个西瓜
问题交流请邮件联系： watermelonbig@163.com