

http://blog.mallux.me/archives/
02 - Moosefs 分布式文件系统 | Mallux - 宁静致远 http://blog.mallux.me/2017/03/11/mfs/

官网 ：http://www.moosefs.org
应用场景 ：海量小文件， 需要标准文件系统接口，需要较高的可扩展性， 一次性顺序读写大量数据、较少随机写， 且对可用性和数据一致性要求不高的应用。

MooseFS 概述
MooseFS 是容错的分布式文件系统，支持标准文件系统接口。MFS 架构非常类似 GFS，看起来是一个支持随机读写的 GFS 实现。MFS 既提供随机读写能力，又拥有类似 GFS 的高容错特性。其是由波兰人开发的。MFS 文件系统能够实现 RAID 的功能，不但能够更节约存储成本，而且不逊色于专业的存储系统，更重要的是它能够实现在线扩展。MFS 是一种半分布式文件系统。

硬件资源消耗

CPU 和 内存消耗（出自官方数据）

In our environment (ca. 500 TiB, 25 million files, 2 million folders distributed on 26 million chunks on 70 machines) the usage of chunkserver CPU (by constant file transfer) is about 15-20% and chunkserver RAM usually consumes about 100MiB (independent of amount of data).
在我们的测试环境中（大约 500 TiB 的数据，250 万份文件，200 万文件夹，分成 260 万块分布在 70 台机器上），chunkserver 的 CPU 使用情况为（持续的文件传输）约为 15-20％ 同时 chunkserver 内存使用 100MiB（和数据量的多少无关）。

The master server consumes about 30% of CPU (ca. 1500 operations per second) and 8GiB RAM. CPU load depends on amount of operations and RAM on number of files and folders.
master 元数据管理服务器消耗约 30％ 的CPU（每秒钟约1500次操作）和 8G 的内存。 CPU 负载取决于操作的次数，内存的使用取决于文件和文件夹的个数。

File data is divided to fragments (chunks) of maximum size 64MB each which are stored as files on selected disks on data servers (chunkservers). Each chunk is saved on different computers in a number of copies equal to a “goal” for the given file.
文件数据是按块为单位（块的最大大小 64MB 以上）存储在数据服务器（chunkservers）上指定磁盘上。如果设置的 goal 的存储分数和机器个数相同，不同的块儿会存储在每一个机器上。

对 Master 主服务器有什么需求？

The most important factor is RAM of mfsmaster machine, as the full file system structure is cached in RAM for speed. Besides RAM mfsmaster machine needs some space on HDD for main metadata file together with incremental logs.
最重要的因素就是 mfsmaster 机器的内存，因为整个文件系统结构都缓存到内存中以便加快访问速度。除了内存 mfsmaster 机器还需要一定硬盘大小用来存储 Metadata 数据和增长的日志文件。

The size of the metadata file is dependent on the number of files (not on their sizes). The size of incremental logs depends on the number of operations per hour, but length (in hours) of this incremental log is configurable.
Metadata 文件的大小是取决于文件数的多少（而不是他们的大小）。changelog 日志的大小是取决于每小时操作的数目，但是这个时间长度（默认是按小时）是可配置的。

1 million files takes approximately 300 MiB of RAM. Installation of 25 million files requires about 8GiB of RAM and 25GiB space on HDD.
100 万文件大约需要 300M 内存。25 百万份文件（2500万）大约需要 8GiB 内存 和 25GiB 硬盘空间。

MooseFS 特性

开源
通用文件系统，不需要修改上层应用就可以使用
可以在线扩容，体系架构可伸缩性极强
部署简单
体系架构高可用，所有组件无单点故障
文件对象高可用，可设置任意的文件冗余程度，而绝对不会影响读写的性能，只会加速
提供如 windows 回收站的功能，
提供类似 java 语言 GC（垃圾回收）机制
提供 NetAPP、EMC、IBM 等商业存储的 snapshot 特性
Google filesystem 的一个 C 实现
提供 Ｗeb GUI 监控接口
提高随机读写的效率
提高海量小文件的读写效率
MooseFS 架构

读（read）流程



Client 向 Master 请求 Chunk Server 地址和 Chunk 版本
Master 返回按照拓扑位置排序 Chunk Server 地址列表，以及 Chunk 版本
Client 从第一个 Chunk Server 读取数据
若版本匹配，Chunk Server 返回 Chunk 数据
写（write）流程



Client 向 Master 请求 Chunk Server 地址和 Chunk 版本
Master 返回 Chunk Server 地址和版本
若 Chunk 不存在， Master 通知 Chunk Server 创建 Chunk
若 Chunk 存在， Master 通知 Chunk Server 增加 Chunk 版本。
若多个文件引用 chunk，Master 通知 Chunk Server 复制一份 Chunk
若 Chunk 上没有Lease，Master 设置 Lease，Lease 超时时间为120s
Master 返回 Chunk版本，和按照拓扑排序之后的 Chunk Server 地址
Client 与第一个 Chunk Server 建立连接， 发送写请求 CLTOCS_WRITE，CLTOCS_WRITE 包含 Chunk Server 链信息，Chunk Server 转发该消息到后续 Chunk Server，建立一条 Chunk Server pipeline
Client 发送多个 CLTOCS_WRITE_DATA 消息到 Chunk Server pipeline，CLTOCS_WRITE_DATA 包含要写入的数据，偏移和长度等信息。
Chunk Server 收到消息后， forward 写请求到下一个 Chunk Server， 同时调用写本地 Chunk 文件（与 forward 是并发的），写 Chunk 文件过程如下：
检查请求版本和 Chunk 版本是否一致、检查请求的 CRC 校验是否正确（Chunk 分为 64KB block，每个 block 对应 32位 CRC 校验），检查其他参数
修改 Chunk 文件（写到操作系统缓存）
重新计算 block checksum
如果写 Chunk 文件成功，且后续 Chunk Serve r也返回成功，则返回成功到前一个 Chunk Server 或者 Client
Client 收到 Chunk Server 响应消息之后， 通知 Master 写操作完成， Master 记录必要的日志，并释放 Chunk Lease
性能分析

从上述流程可以看到， MooseFS 写操作代价较高，包括以下几个关键操作：

访问 Master 得到 Chunk Server 地址；
由 Master 通知 Chunk Server 增加版本；
Chunk Server 修改 Chunk 文件；
Chunk server 修改 checksum。
整个过程包括多次网络交互，单个 Chunk Server 上可能有 3 到 4 次写操作，至少一次 sync 操作。增加版本需要写 Chunk 文件头，关闭文件，重命名文件。
MooseFS 本地不会缓存 Chunk 信息， 每次读写操作都会访问 Master， Master 的压力较大。
MooseFS 支持快照，但是以整个 Chunk 为单位进行 COW（写时复制），可能造成响应时间恶化，补救办法是以牺牲系统规模为代价， 降低 Chunk 大小。

容错性分析

可用性不高，任意 Chunk Server 故障，写操作都会失败。
存在数据不一致情况。首先，若写操作失败， 出现版本已经修改，但是数据未修改情况，因此不能保证副本一致性。其次，由于数据和版本是写入到操作系统 Page Cache， Chunk Server 意外宕机重启导致版本和数据不一致。
读写存在并发问题。 读操作不受 Lease 限制，多个 Client 可能从不同 Chunk Server 读取数据，因此无法保证 Client 一定读到最新数据。
MooseFS 文件系统结构

MFS 文件系统结构包含 4 种角色，分别是：

管理服务器（Master）
元数据备份服务器（Metalogger）
数据存储服务器（Chunk Server）
客户端（Client）
4 种角色作用如下：

管理服务器：有时也称为 元数据（文件大小、属性、对应的 Chunk 等）服务器，负责管理各个数据存储服务器，调度文件读写，回收文件空间以及恢复多节点拷贝。

元数据日志服务器：负责备份管理服务器的变化日志文件，文件类型为 changelog_ml.*.mfs，以便于在管理服务器出问题时接替其进行工作。元数据日志服务器是 mfs1.6 以后版本新增的服务，可以把元数据日志保留在管理服务器中，也可以单独存储在一台服务器中。为保证数据的安全性和可靠性，建议单独用一台服务器来存放元数据日志。需要注意的是，元数据日志守护进程跟管理服务器在同一个服务器上，备份元数据日志服务器作为它的客户端，从管理服务器取得日志文件进行备份。

数据存储服务器：是真正存储用户数据的服务器。在存储文件时，首先把文件分成块，然后将这些块在数据存储服务器之间互相复制。同时，数据存储服务器还负责连接管理服务器，听从管理服务器调度，并为客户提供数据传输。数据存储服务器可以有多个，并且数量越多，可靠性越高，MFS 可用的磁盘空间也越大。

客户端：通过 fuse 内核接口挂接远程管理服务器上所管理的数据存储服务器，使共享的文件系统和使用本地Linux文件系统的效果看起来是一样的。

硬件推荐

Master：MFS 的大脑，记录着管理信息，比如：文件大小，存储的位置，份数等，这些信息被记录到 metadata.mfs 中，当该文件被载入内存后，改文件会重命名为 metadata.mfs.back，当 chunkserver 上有更新时，master 会定期将获得的新的信息回写到 metadata.mfs.back 中，保证元数据的可靠。硬件推荐：大内存，因为内存中需要将 metadata.mfs 加载进来，这个文件的大小取决于你 chunkserver 上存储的数据量，内存的大小会成为之后的问题，需要支持 ECC 错误校验，当内存中数据量达到一定程度，如果没有个容错的机制，会很可怕；冗余电池，和磁盘配置 RAID1/RAID5/RAID10，都是为了保证高可靠。

Metalogger：mfs 的备份，好比 MySQL 中的主从架构，metalogger 会定期从 master 上将的 metadata、changelog、session 类型的文件下载同步到本地目录下，并加后缀“_ml”将其重命名。硬件推荐：与 master 机器配置一致，metalogger 本身就是 master 的一个备机，当 master 宕机后，可以直接将metalogger 提升为 master。

Chunkserver：数据存储地，文件以 chunk 大小存储，每 chunk 最大为 64M，小于 64M 的，该 chunk 的大小即为该文件大小，超过 64M 的文件将被均分，每一份（chunk）的大小以不超过 64M 为原则；文件可以有多份 copy，即除了原始文件以外，该文件还存储的份数，当 goal 为 1 时，表示只有一份 copy，这份 copy 会被随机存到一台 chunkserver 上，当 goal 的数大于1时，每一份 copy 会被分别保存到每一个 chunkserver 上，goal 的大小不要超过 chunkserver 的数量，否则多出的 copy，不会有 chunkserver 去存，goal 设置再多实际上也就没有意义的。Copy 的份数，一般设为大于 1 份，这样如果有一台 chukserver 坏掉后，至少还有一份 copy，当这台又被加进来后，会将失去的那份 copy 补回来，始终保持原有的 copy 数，而如果 goal 设为 1 copy，那么当存储该 copy 的 chunkserver 坏掉，之后又重新加入回来，copy 数将始终是 0，不会恢复到之前的 1 个copy。Chunkserver 上的剩余存储空间要大于1GB（Reference Guide 有提到），新的数据才会被允许写入，否则，你会看到“No space left on device”的提示。实际中，测试发现当磁盘使用率达到 95% 左右的时候，就已经不行写入了。硬件建议：普通的机器就行，就是要来存几份数据，只要磁盘够大就好。

检查 master 服务器硬件要求：

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
29
30
31
32
33
34
35
36
37
38
### 查看当前机器型号
[root@SZ-GIT-DR1 ~]# dmidecode -t 1
# dmidecode 2.12
SMBIOS 2.7 present.
Handle 0x0001, DMI type 1, 27 bytes
System Information
    Manufacturer: LENOVO
    Product Name: 4351AF4
    Version: ThinkStation S30
    Serial Number: PCCKWV1
    UUID: 185B1651-938D-E411-B68B-4439C492174D
    Wake-up Type: Power Switch
    SKU Number: LENOVO_BI_A2
    Family: To be filled by O.E.M.
### 查看内存是否支持 ECC、最大可支持的内存容量上限
[root@SZ-GIT-DR1 ~]# dmidecode -t 16
# dmidecode 2.12
SMBIOS 2.7 present.
Handle 0x0016, DMI type 16, 23 bytes
Physical Memory Array
    Location: System Board Or Motherboard
    Use: System Memory
    Error Correction Type: Multi-bit ECC
    Maximum Capacity: 256GB
    Error Information Handle: 0x0017
    Number Of Devices: 8
### 查看当前设备支持的内存 socket 及已配备了内存 socket 数量
[root@SZ-GIT-DR1 ~]# dmidecode -t 17 | grep 'Size: [[:digit:]]\{1,\}'
    Size: 8192 MB
    Size: 8192 MB
### 内存/磁盘估算：Git 应用，存储 380 万个文件、容量为 1.2T。
### 按官方数据估算，大概需要 1.2G 内存和 4G 的硬盘空间。
MooseFS FAQ

[Doc] https://moosefs.com/documentation/faq.html

MooseFS 最佳实践（摘自官方）

Best practices

Lots of people are asking us about technical aspects of setting up MooseFS instances.
In order to answer these questions, we are publishing here a list of best practices and hardware recommendations. Follow these to achieve best reliability of your MooseFS installation.

Minimum goal set to 2
Enough space for metadata dumps
RAID 1 or RAID 1+0 for storing metadata
Virtual Machines and MooseFS
JBOD and XFS for Chunkservers
Network
overcommit_memory on Master Servers (Linux only)
Disabled updateDB feature (Linux only)
Up-to-date operating system
Hardware recommendation
Minimum goal set to 2（goal >=2，至少两份副本 copy）

In order to keep your data safe, we recommend to set the minimum goal to 2 for the whole MooseFS instance.
The goal is a number of copies of files’ chunks distributed among Chunkservers.It is one of the most crucial aspects of keeping data safe.
If you have set the goal to 2, in case of a drive or a Chunkserver failure, the missing chunk copy is replicated from another copy to another chunkserver to fulfill the goal, and your data is safe.
If you have the goal set to 1, in case of such failure, the chunks that existed on a broken disk, are missing, and consequently, files that these chunks belonged to, are also missing. Having goal set to 1 will eventually lead to data loss.
To set the goal to 2 for the whole instance, run the following command on the server that MooseFS is mounted on (e.g. in /mnt/mfs):

1
# mfssetgoal -r 2 /mnt/mfs
You should also prevent the users from setting goal lower than 2. To do so, edit your /etc/mfs/mfsexports.cfg file on every Master Server and set mingoalappropriately in each export:

1
*    /    rw,alldirs,mingoal=2,maproot=0:0
After modifying /etc/mfs/mfsexports.cfg you need to reload your Master Server(s):

1
# mfsmaster reload
or

1
2
# service moosefs-master reload
# service moosefs-pro-master reload
or

1
# kill -HUP `pidof mfsmaster`
For big instances (like 1 PiB or above) we recommend to use minimum goal set to 3, because probability of disk failure in such a big instance is higher.

Enough space for metadata dumps（元数据磁盘空间需求）

We had a number of support cases raised connected to the metadata loss. Most of them were caused by a lack of free space for /var/lib/mfs directory on Master Servers.
The free space needed for metadata in /var/lib/mfs can be calculated by the following formula:

RAM is amount of RAM
BACK_LOGS is a number of metadata change log files (default is 50 - from/etc/mfs/mfsmaster.cfg)
BACK_META_KEEP_PREVIOUS is a number of previous metadata files to be kept (default is 1 - also from /etc/mfs/mfsmaster.cfg)
1
SPACE = RAM * (BACK_META_KEEP_PREVIOUS + 2) + 1 * (BACK_LOGS + 1) [GiB]
(If default values from /etc/mfs/mfsmaster.cfg are used, it is RAM 3 + 51 [GiB])
The value 1 (before multiplying by BACK_LOGS + 1) is an estimation of size used by one changelog.[number].mfs file. In highly loaded instance it uses a bit less than 1 GB.
Example:
If you have 128 GiB of RAM on your Master Server, using the given formula, you should reserve for /var/lib/mfs on Master Server(s): 1283 + 51 = 384 + 51 = 435 GiB minimum.

RAID 1 or RAID 1+0 for storing metadata（元数据实现 RAID 机制，不推荐网络存储）

We recommend to set up a dedicated RAID 1 or RAID 1+0 array for storing metadata dumps and changelogs. Such array should be mounted on /var/lib/mfs directory and should not be smaller than the value calculated in the previous point.
We do not recommend to store metadata over the network (e.g. SANs, NFSes, etc.).

Virtual Machines and MooseFS

For high-performance computing systems, we do not recommend running MooseFS components (especially Master Server(s)) on Virtual Machines.

JBOD and XFS for Chunkservers（Chunkserver 使用 XFS 磁盘格式，不使用 RAID 阵列）

We recommend to connect to Chunkserver(s) JBODs. Just format the drive as XFS and mount on e.g. /mnt/chunk01, /mnt/chunk02, … and put these paths into/etc/mfs/mfschunkserver.cfg. That’s all.

We recommend such configuration mainly because of two reasons:
MooseFS has a mechanism of checking if the hard disk is in a good condition or not. MooseFS can discover broken disks, replicate the data and mark such disks as damaged. The situation is different with RAID: MooseFS algorithms do not work with RAIDs, therefore corrupted RAID arrays may be falsely reported as healthy/ok.

The other aspect is time of replication. Let's assume you have goal set to 2 for the whole MooseFS instance. If one 2 TiB drive breaks, the replication (from another copy) will last about 40-60 minutes. If one big RAID (e.g. 36 TiB) becomes corrupted, replication can last even for 12-18 hours. Until the replication process is finished, some of your data is in danger, because you have only one valid copy. If another disk or RAID fails during that time, some of your data may be irrevocably lost. So the longer replication period puts your data in greater danger.

Network（>=1Gps network）

We recommend to have at least 1 Gbps network. Of course, MooseFS will perform better in 10 Gbps network (in our tests we saturated the 10 Gbps network).
We recommend to set LACP between two switches and connect each machine to both of them to enable redundancy of your network connection.

overcommit_memory on Master Servers（Linux only，允许分配所有物理内存）

If you have an entry similar to the following one in /var/log/syslog or/var/log/messages:

1
fork error (store data in foreground - it will block master for a while)
you may encounter (or are encountering) problems with your master server, such as timeouts and dropped connections from clients. This happens, because your system does not allow MFS Master process to fork and store its metadata information in background.

Linux systems use several different algorithms of estimating how much memory a single process needs when it is created. One of these algorithms assumes that if we fork a process, it will need exactly the same amount of memory as its parent. With a process taking 24 GB of memory and total amount of 40 GB (32 GB physical plus 8 GB virtual) and this algorithm, the forking would always be unsuccessful.

But in reality, the fork commant does not copy the entire memory, only the modified fragments are copied as needed. Since the child process in MFS master only reads this memory and dumps it into a file, it is safe to assume not much of the memory content will change.

Therefore such “careful” estimating algorithm is not needed. The solution is to switch the estimating algorithm the system uses. It can be done one-time by a root command:

1
# echo 1 > /proc/sys/vm/overcommit_memory
0：表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
1：表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
2：表示内核允许分配超过所有物理内存和交换空间总和的内存（overcommit_ratio 在该分配方式下才会生效）
To switch it permanently, so it stays this way even after the system is restarted, you need to put the following line into your /etc/sysctl.conf file:

1
vm.overcommit_memory=1
Disabled updateDB feature (Linux only，禁用 fuse.mfs 的 updatedb 文件查找功能)

Updatedb is part of mlocate which is simply an indexing system, that keeps a database listing all the files on your server. This database is used by the locate command to do searches.

Updatedb is not recommended for network distributed filesystems.

To disable Updatedb feature for MooseFS, add fuse.mfs to variable PRUNEFS in /etc/updatedb.conf (it should look similar to this):

1
PRUNEFS="NFS nfs nfs4 rpc_pipefs afs binfmt_misc proc smbfs autofs iso9660 ncpfs coda devpts ftpfs devfs mfs shfs sysfs cifs lustre tmpfs usbfs udf fuse.glusterfs fuse.sshfs fuse.mfs curlftpfs ecryptfs fusesmb devtmpfs"
Up-to-date operating system（必要时，使用最新内核，以支持 MooseFS 新特性）

We recommend to use up-to-date operating system. It doesn’t matter if your OS is Linux, FreeBSD or MacOS X. It needs to be up-to-date. For example, some features added in MooseFS 3.0 will not work with old FUSE version (which is e.g. present on Debian 5).

Hardware recommendation（硬件推荐）

Since MooseFS Master Server is a single-threaded process, we recommend to use modern processors with high clock and low number of cores for Master Servers, e.g.:

Intel(R) Xeon(R) CPU E5-1630 v3 @ 3.70GHz
Intel(R) Xeon(R) CPU E5-1620 v2 @ 3.70GHz
We also recommend to disable hyper-threading CPU feature for Master Servers.

Minimum recommended and supported HA configuration for MooseFS Pro is 2 Master Servers and 3 Chunkservers. If you have 3 Chunkservers, and one of them goes down, your data is still accessible and is being replicated and system still works. If you have only 2 Chunkservers and one of them goes down, MooseFS waits for it and is not able to perform any operations.

Minumum number of Chunkservers required to run MooseFS Pro properly is 3.

KVM 实验环境
实验拓扑



准备模板硬像

1
2
3
4
5
6
7
[root@Mallux ~]# cd /home/kvm-machine/
[root@Mallux kvm-machine]# qemu-img info 1-Template/CentOS-6.5.img
image: 1-Template/CentOS-6.5.img
file format: qcow2
virtual size: 30G (32212254720 bytes)
disk size: 4.3G
cluster_size: 65536
创建节点硬像：基于后端模板

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
### 复制模板硬像
[root@Mallux kvm-machine]# cp -af 1-Template/CentOS-6.5.img CentOS.img
### 创建 mfs-m1（元数据服务器）、mfs-m2（元数据备份服务器）、node1 ~ node4（存储服务器）磁盘硬像文件
[root@Mallux kvm-machine]# qemu-img create -f qcow2 mfs-m1.img -o backing_file=CentOS.img,size=30G
[root@Mallux kvm-machine]# qemu-img create -f qcow2 mfs-m2.img -o backing_file=CentOS.img,size=30G
[root@Mallux kvm-machine]# qemu-img create -f qcow2 node1.img -o backing_file=CentOS.img,size=30G
[root@Mallux kvm-machine]# qemu-img create -f qcow2 node2.img -o backing_file=CentOS.img,size=30G
[root@Mallux kvm-machine]# qemu-img create -f qcow2 node3.img -o backing_file=CentOS.img,size=30G
[root@Mallux kvm-machine]# qemu-img create -f qcow2 node4.img -o backing_file=CentOS.img,size=30G
### 创建存储服务器额外的使用的数据硬盘
[root@Mallux kvm-machine]# qemu-img create -f qcow2 -o size=5G,preallocation=metadata disk1.img
[root@Mallux kvm-machine]# qemu-img create -f qcow2 -o size=5G,preallocation=metadata disk2.img
[root@Mallux kvm-machine]# qemu-img create -f qcow2 -o size=5G,preallocation=metadata disk3.img
[root@Mallux kvm-machine]# qemu-img create -f qcow2 -o size=5G,preallocation=metadata disk4.img
创建节点 KVM 虚拟机（以 node1 为例）

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
### 创建、启动虚拟机
[root@Mallux kvm-machine]# virt-install -n "node1" --vcpus 1 -r 1024 \
--connect qemu:///system \
--disk path=/home/kvm-machine/node1.img,bus=virtio \
--network network=default,model=virtio \
--graphics vnc,listen=0.0.0.0 \
--noautoconsole \
--import
### 创建快照，方便出问题后恢复
[root@Mallux kvm-machine]# virtsh snapshot-create-as node1 node1-n1-init
### 挂载数据磁盘：创建、格式化为 /dev/vdb1 分区，挂载到 /mfspool 目录下。
[root@Mallux kvm-machine]# virsh attach-disk node1 /home/kvm-machine/disk1.img vdb
配置 MooseFS 源
MooseFS 2.0 开始，分出了两个版本，社区版和专业版（需要 license）。

MooseFS Official 源

[Official] http://ppa.moosefs.com/stable/

MooseFS Local 源

1
2
3
[root@Mallux repo_mirror]# wget -r -N -np -l inf -P ./ http://ppa.moosefs.com/stable/
[root@Mallux repo_mirror]# find ppa.moosefs.com/ -type f -name 'index.html*' | xargs rm -rf
[root@Mallux repo_mirror]# ln -sf ppa.moosefs.com/stable moosefs-official
1
2
3
4
5
6
[root@Mallux config.repo]# cat MooseFS-official.repo
[moosefs]
name=MooseFS $releasever - $basearch
baseurl=http://10.128.161.195:88/moosefs-official/stable/yum/el6
enabled=1
gpgcheck=0
安装 MooseFS
ＭooseFS 启动和关闭顺序

启动顺序

启动 mfsmaster
启动 mfschunkserver（所有的）
启动 mfsmetalogger（如果配置了 mfsmetalogger）
关闭顺序

客户端 umount MFS 文件系统（所有的）
停止 mfschunkserver 进程
停止 mfsmetalogger 进程
停止 mfsmaster 进程
安装和配置 master 元数据服务

安装元数据服务

1
2
3
4
[root@MFS-M1 ~]# wget -O /etc/yum.repos.d/MooseFS-official.repo \
http://10.128.161.195:88/mixed/repo/MooseFS-official.repo
[root@MFS-M1 ~]# yum install moosefs-master moosefs-cgi moosefs-cgiserv
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
[root@MFS-M1 ~]# rpm -ql moosefs-master
/etc/mfs/mfsexports.cfg.dist                  ### 权限示列配置文件
/etc/mfs/mfsmaster.cfg.dist                   ### 主配置示列配置文件
/etc/mfs/mfstopology.cfg.dist
/etc/rc.d/init.d/moosefs-master               ### init 服务脚本
/usr/sbin/mfsmaster
/usr/sbin/mfsmetadump
/usr/sbin/mfsmetarestore
/usr/share/doc/moosefs-master-2.0.83
/usr/share/doc/moosefs-master-2.0.83/NEWS
/usr/share/doc/moosefs-master-2.0.83/README
/usr/share/man/man5/mfsexports.cfg.5.gz
/usr/share/man/man5/mfsmaster.cfg.5.gz
/usr/share/man/man5/mfstopology.cfg.5.gz
/usr/share/man/man8/mfsmaster.8.gz
/usr/share/man/man8/mfsmetarestore.8.gz
/var/lib/mfs                                  ### mfsmeta 元数据存储目录
/var/lib/mfs/metadata.mfs.empty               ### mfsmeta 元数据文件


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
### 配置 hosts 解析
[root@MFS-M1 ~]# tail -n1 /etc/hosts
192.168.96.15   mfsmaster
###　允许分配所有物理内存　
[root@MFS-M1 ~]# tail -n2 /etc/sysctl.conf
# MFS parameters
vm.overcommit_memory = 1
### 重载内核设置
[root@MFS-M1 ~]# sysctl -p
### 关闭 iptables
[root@MFS-M1 ~]# iptables -F
禁用网络文件系统的 updatedb 功能：

若解析的 FQDN 非 mfsmaster，可修改 /usr/share/mfscgi/mfs.cgi 中的 masterhost 设置，否则会报错。




mfsmaster.cfg 配置文件（/etc/mfs/mfsmastere.cfg）

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
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
### RUNTIME OPTIONS
# WORKING_USER = mfs                 ### 运行 MASTER SERVER 的用户
# WORKING_GROUP = mfs                ### 运行 MASTER SERVER 的组
# SYSLOG_IDENT = mfsmaster           ### syslog 日志标识
# LOCK_MEMORY = 0                    ### 是否执行 mlockall（）以避免 mfsmaster 进程溢出（默认为0）
# NICE_LEVEL = -19                   ### 进程优先级
# FILE_UMASK = 027　　　　　　       ### 创建的文件或目录掩码
# DATA_PATH = /var/lib/mfs           ### 数据存放路径，大致有三类文件，changelog、sessions 和 stats
# EXPORTS_FILENAME = /etc/mfs/mfsexports.cfg
# TOPOLOGY_FILENAME = /etc/mfs/mfstopology.cfg
# BACK_LOGS = 50                     ### 元数据的改变日志文件数量（默认是50）
# BACK_META_KEEP_PREVIOUS = 1        ### 保留早前的 metadata 元数据的文件份数，默认值是 1
# CHANGELOG_PRESERVE_SECONDS = 1800  ### 保存多少秒内的 changle log 在内存中，默认值是 1800
# MISSING_LOG_CAPACITY = 100000
### COMMAND CONNECTION OPTIONS
# MATOML_LISTEN_HOST = *             ### 元数据日志服务器监听的IP地址（默认是 *，代表任何 IP）
# MATOML_LISTEN_PORT = 9419          ### 元数据日志服务器监听的端口地址（默认是 9419）
### CHUNKSERVER CONNECTION OPTIONS
# MATOCS_LISTEN_HOST = *             ### 用于 CHUNKSERVER 连接的 IP 地址（默认是 *，代表任何 IP）
# MATOCS_LISTEN_PORT = 9420          ### 用于 CHUNKSERVER 连接的端口地址（默认是 9420）
# MATOCS_TIMEOUT = 10                ### 连接 CHUNKDRTVRT 的超时时间
### CHUNKSERVER WORKING OPTIONS
# REPLICATIONS_DELAY_INIT = 300      ### 延迟复制的时间（默认是 300 秒）
# CHUNKS_LOOP_MAX_CPS = 100000       ### 每秒可检查的 chunk 数量
# CHUNKS_LOOP_MIN_TIME = 300
# CHUNKS_SOFT_DEL_LIMIT = 10
# CHUNKS_HARD_DEL_LIMIT = 25
# CHUNKS_WRITE_REP_LIMIT = 2,1,1,4
# CHUNKS_READ_REP_LIMIT = 10,5,2,5
# CS_HEAVY_LOAD_THRESHOLD = 100
# CS_HEAVY_LOAD_RATIO_THRESHOLD = 5.0
# CS_HEAVY_LOAD_GRACE_PERIOD = 900
# ACCEPTABLE_PERCENTAGE_DIFFERENCE = 1.0
# PRIORITY_QUEUES_LENGTH = 1000000
### CLIENTS CONNECTION OPTIONS
# MATOCL_LISTEN_HOST = *             ### 用于客户端挂接连接的 IP 地址（默认是 *，代表任何 IP）
# MATOCL_LISTEN_PORT = 9421          ### 用于客户端挂接连接的端口地址（默认是 9421）
### CLIENTS WORKING OPTIONS
# SESSION_SUSTAIN_TIME = 86400       ### 客户端 session 会话保持多久，默认 1 day
# QUOTA_TIME_LIMIT = 604800          ### 磁盘软限额，默认 7 days
mfsexports.cfg 配置文件（/etc/mfs/mfsexports.cfg）

1
2
192.168.96.0/24          /   rw,alldirs,maproot=0:0,mingoal=2,password=mfspass
192.168.96.0/24          .   rw
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
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
# Line format:
#  [ip range] [path] [options]　　　　　　 ### 格式：客户端 IP、被挂载目录、客户端拥有的权限
# ip range:
#  * = any ip (same as 0.0.0.0/0)
#  A.B.C.D = single ip address
#  A.B.C.D-E.F.G.H = range of ip addresses
#  A.B.C.D/XX = A.B.C.D network with XX bits netmask
#  A.B.C.D/E.F.G.H = A.B.C.D network with E.F.G.H netmask
# path:
#  . = special 'path' that means 'meta'   ### mfsmeta 文件系统
#  /... = path in mfs structure           ### moosefs 根
# options:
#  ro/rw/readonly/readwrite = meaning is obvious
#  alldirs = any subdirectory can be mounted as root
#  dynamicip = ip is tested only during first authentication, then client can use the same session id from any ip
#  ignoregid = group id (gid) is not tested - important when you want to use auxiliary groups
#  admin = administrative privileges - currently: manipulating quota values is allowed
#  maproot=UID[:GID] = treat all root (uid zero) operations as operations done by user with uid equal to UID and gid equal to GID (or default gid of this user if GID not specified)
#  mapall=UID[:GID} = like above but for all operations (for both options UID and/or GID can be specified as username or groupname existing on master machine)
#  password=TEXT = force authentication using given password
#  md5pass=MD5 = like above, but with password defined as it's MD5 hash (MD5 specified as 128-bit hexadecimal number)
#  minversion=VER = allow only clients with version number equal or greater than VER (VER can be specified as X or X.Y or X.Y.Z)
#  mingoal=N = do not allow to set goal below N (N should be a digit from '1' to '9')
#  maxgoal=N = do not allow to set goal above N (N as above)
#  mintrashtime=TIMEDURATION = do not allow to set trashtime below TIMEDURATION (TIMEDURATION can be specified as number of seconds or combination of elements #W,#D,#H,#M,#S in set order)
#  maxtrashtime=TIMEDURATION = do not allow to set trashtime above TIMEDURATION (TIMEDURATION can be specified as above)
# Defaults:
#  readonly,maproot=999:999,mingoal=1,maxgoal=9,mintrashtime=0,maxtrashtime=4294967295
# TIMEDURATION examples:
#  2H = 2 hours
#  4h30M = 4 hours and 30 minutes (time units are case insensitive)
#  12w = 12 weeks
#  86400 = 86400 seconds = 1 day
#  11d13h46m40s = 1000000 seconds (defined in a bit strage way as 11 days, 13 hours, 46 minutes and 40 seconds)
#  48H = 48 hours = 2 days (it is allowed to use any positive number with any time unit as long as calculated number of seconds do not exceed 4294967295)
#  30m12h = wrong definition (minutes before hours)
#  30m12 = wrong definition (12 without unit definition - only a single number is allowed without unit definition, which then defaults to seconds)
#  50000d = wrong definition (calculated number of seconds is 4320000000, which is greater than 4294967295)
# Some examples:
#  Users from any IP can mount root directory as a read-only file system. Local roots are mapped as users with uid:gid = 999:999.
#*          /   ro
#  Users from IP 192.168.1.0-192.168.1.255 can mount root directory as a standard read/write file system. Local roots are mapped as users with uid:gid = 999:999.
#192.168.1.0/24     /   rw
#  Users from IP 192.168.1.0-192.168.1.255 when give password 'passcode' can mount any subdirectory as a standard read/write file system. Local roots are left unmapped.
#192.168.1.0/24     /   rw,alldirs,maproot=0,password=passcode
#  Users from IP 10.0.0.0-10.0.0.5 when give password 'test' can mount 'test' subdirectory as a standard read/write file system. Local roots are mapped as 'nobody' users (usually uid=65534).
#10.0.0.0-10.0.0.5  /test   rw,maproot=nobody,password=test
#  Users from IP 10.1.0.0-10.1.255.255 can mount 'public' subdirectory as a standard read/write file system. All users are mapped as users with uid:gid = 1000:1000.
#10.1.0.0/255.255.0.0   /public rw,mapall=1000:1000
#  Users from IP 10.2.0.0-10.2.255.255 can mount everything, but can't decrease trash time below 2 hours and 30 minutes nor increse it above 2 weeks
#10.2.0.0/16        /   rw,alldirs,maproot=0,mintrashtime=2h30m,maxtrashtime=2w
启动 metadata 服务（默认数据目录：/var/lib/mfs，由 mfsmaster.cfg DATA_PATH 定义）

1
[root@MFS-M1 ~]# /etc/init.d/moosefs-master start


运行一段时间以后：

安装和配置 metalogger 服务

安装元数据备份服务

1
2
3
4
5
6
7
8
9
### 安装 metalogger
[root@MFS-M2 ~]# yum install moosefs-metalogger
### hosts 解析设置
[root@MFS-M2 ~]# tail -n1 /etc/hosts
192.168.96.15   mfsmaster
### 关闭 iptables
[root@MFS-M2 ~]# iptables -F
mfsmetalogger.cfg 配置文件（/etc/mfs/mfsmetalogger.cfg）

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
# WORKING_USER = mfs
# WORKING_GROUP = mfs
# SYSLOG_IDENT = mfsmetalogger
# LOCK_MEMORY = 0
# NICE_LEVEL = -19
# FILE_UMASK = 027
# DATA_PATH = /var/lib/mfs
# BACK_LOGS = 50
# BACK_META_KEEP_PREVIOUS = 3   ### 保留多少个 medata.mfs.back 历史备份文件
  META_DOWNLOAD_FREQ = 1        ### 元数据备份文件下载请求频率,每隔这个间隔时间去下载
　　　　　　　　　　　　　　　　　  mfsmaster 上的 medata.mfs.back 文件，默认为 24 小时。
                                    在备份服务器上，该文件为 metadata_ml.mfs.bak 文件（最新备份）。
                                    当元服务器关闭或者故障时，metadata.mfs.back 文件将消失，
                                    那么要恢复整个 mfs,则需从 metalogger 服务器取得该文件。
                                    它与日志文件一起，才能够恢复整个被损坏的分布式文件系统。
                                    日志文件在备份服务器上显示为 changelog_ml.*.mfs。
                                    一旦元数据服务器有数据变化时，备份服务器就会同步更新
                                    changelog_m1.0.mfs 文件（最新日志）。
### MASTER CONNECTION OPTIONS
# MASTER_RECONNECTION_DELAY = 5
# BIND_HOST = *
# MASTER_HOST = mfsmaster
# MASTER_PORT = 9419
# MASTER_TIMEOUT = 10
启动 metalogger 服务



运行一段时间以后：

安装和配置 chunkserver 服务（以 node1 为例）

安装数据存储服务

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
### 安装 chunkserver
[root@NODE1 ~]# yum install moosefs-chunkserver
### hosts 解析设置（或者依赖于 DNS 轮询解析）
### mfschunkserver.cfg 配置中，有提到 mfs metadata 若使用 IP 连接的话，只适用于单 master 的情况。
### 实际上，官方的这个说明，是在有 DNS 的前提下，使用 DNS 轮询来完成最简单的双 master 负载均衡调度的。
### 所以，官方才会说单 IP 适用于单 master 的情况，而双 master 目前 MooseFS PRO 专业版是提供的。
### 而基于 MooseFS CE 社区版，我们可以实现类似的双 master 机制，
### 具体实现方式，见 “6. Corosync + Pacemaker + DRBD 高可用集群”。
### 而至于其稳定性应该是不如官方的，因 DRBD 存在比较恼人的脑裂问题。
### 但 Corosync 是个重量级的、强大的 HA 高可用软件。
[root@NODE1 mfs]# tail -n1 /etc/hosts
192.168.96.15   mfsmaster
### 关闭 iptables
[root@NODE1 ~]# iptables -F
1
2
[root@NODE1 ~]# mfschunk
mfschunkserver  mfschunktool
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
[root@NODE1 ~]# rpm -ql moosefs-chunkserver
/etc/mfs/mfschunkserver.cfg.dist          ### chunkserver 示配配置文件
/etc/mfs/mfshdd.cfg.dist                  ### 集资使用资源示列配置文件
/etc/rc.d/init.d/moosefs-chunkserver      ### init 服务脚本
/usr/sbin/mfschunkserver
/usr/sbin/mfschunktool
/usr/share/doc/moosefs-chunkserver-2.0.83
/usr/share/doc/moosefs-chunkserver-2.0.83/NEWS
/usr/share/doc/moosefs-chunkserver-2.0.83/README
/usr/share/man/man5/mfschunkserver.cfg.5.gz
/usr/share/man/man5/mfshdd.cfg.5.gz
/usr/share/man/man8/mfschunkserver.8.gz
/var/lib/mfs
mfschunkserver.cfg 配置文件（/etc/mfs/mfschunkserver.cfg）

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
29
30
31
### RUNTIME OPTIONS
# WORKING_USER = mfs
# WORKING_GROUP = mfs
# SYSLOG_IDENT = mfschunkserver
# LOCK_MEMORY = 0
# NICE_LEVEL = -19
# FILE_UMASK = 027
# DATA_PATH = /var/lib/mfs
# HDD_CONF_FILENAME = /etc/mfs/mfshdd.cfg     ### 分配给 MFS 使用的磁盘空间配置文件
# HDD_TEST_FREQ = 10                          ### 检查 chunk 间隔时间
# HDD_LEAVE_SPACE_DEFAULT = 256MiB            ### 每个磁盘上不分配使用的空间大小
# HDD_REBALANCE_UTILIZATION = 20              ### 重新均衡空间的百分比
# HDD_ERROR_TOLERANCE_COUNT = 2　　　　　　　 ### 单磁盘可容忍的 IO 错误数
# HDD_ERROR_TOLERANCE_PERIOD = 600            ### 单磁盘可容忍的不可用时间
# HDD_FSYNC_BEFORE_CLOSE = 0                  ### 在关闭 chunk 时，是否启用文件同步
# WORKERS_MAX = 150                           ### 活动进程最大数
# WORKERS_MAX_IDLE = 40                       ### 空闲进程最大数
### MASTER CONNECTION OPTIONS
# BIND_HOST = *
# MASTER_HOST = mfsmaster                     ### 元数据服务器的名称（集群环境）或 IP（单 master）
# MASTER_PORT = 9420                          ### 元数据服务器用于 chunkserver 连接的端口
# MASTER_TIMEOUT = 10                         ### 元数据服务器连接超时时间
# MASTER_RECONNECTION_DELAY = 5               ### 元数据服务器重新连接延迟时间
### CLIENTS CONNECTION OPTIONS
# CSSERV_LISTEN_HOST = *                      ### 用于客户端连接监听的地址
# CSSERV_LISTEN_PORT = 9422                   ### 用于客户端连接监控的端口
mfshdd 配置文件（/etc/mfs/mfshdd.cfg）



启动 chunkserver 服务

1
2
[root@NODE1 ~]# mkdir -pv /mfspool/hd1 ; mount /dev/vdb1 /mfspool/hd1 ; chown mfs.mfs -R /mfspool
[root@NODE1 ~]# /etc/init.d/moosefs-chunkserver start




安装 Client 端

安装 fuse 和 MooseFS 客户端

1
2
3
4
### 如果系统已经安装了 fuse，则跳过此步骤，linux kernel >= 2.6.20 已开始支持。
[root@Mallux ~]# yum -y install fuse fuse-libs fuse-devel
[root@Mallux ~]# yum install moosefs-client


挂载 MFS 文件系统



1
2
3
4
5
6
7
8
9
[root@Mallux ~]# tail -n1 /etc/hosts
192.168.96.15   mfsmaster
[root@Mallux ~]# mkdir -pv /data
mkdir: created directory `/data'
[root@Mallux ~]# mfsmount /data -H mfsmaster -p
MFS Password:
mfsmaster accepted connection with parameters: read-write,restricted_ip ; root mapped to root:root



管理 MooseFS
设定目标（goal）：mfsgetgoal、mfssetgoal

目标（goal）是指文件被复制的份数，设定了复制的份数后就可以通过 mfsgetgoal 命令来证实，也可以通过 mfssetgoal 来改变设定。假如改变一个已经存在的文件的拷贝个数，那么文件的拷贝份数将会被扩大或者被删除，这个过程会有延时。而对一个目录设定 “目标” ，此目录下的新创建文件和子目录均会继承此目录的设定，但不会改变已经存在的文件及目录的拷贝份数。

实际的应用中，我们应当把 goal 至少设置为 2 份（保留 2 份副本），那么只要不是保存有这两份副本的存储服务器同时故障，在任何一台故障的情况下，MooseFS 都会自行拷贝一份副本到其它存储服务器上。而在设置 goal 为 1 的情况下，倘若保存这个文件的存储服务器故障了，那么该文件将不可读（除非预先读取过，且还保存在内存当中）。

Step 1：Demo，设置目标（goal）副本数

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
[root@Mallux ~]# mkdir /data/c{1,2}
### 设置目录 goal 份数，其下的目录或文件将继承目录的设置
[root@Mallux ~]# mfssetgoal 1 /data/c1
[root@Mallux ~]# mfssetgoal 2 /data/c2
[root@Mallux ~]# mfsgetgoal /data/c{1,2}
/data/c1: 1
/data/c2: 2
[root@Mallux ~]# cp /etc/fstab /data/c1/
[root@Mallux ~]# cp /etc/issue /data/c2/


Step 2: 停止 node2 节点的 mfschkunkserver 服务，看看会发生什么？

结论：/data/c1/fstab 文件不可用



Step 3：恢复 node2 节点的 mfschunkserver 服务

在 node2 节点存储服务恢复时，issue 文件显示有三份副本，但实际 goal 为 2，chunk 状态为 overgoal 状态。在 MFS 运行期间，系统会自行检查 chunk 的状态。在一段时间后，overgoal 状态的 chunk 会转变为原设定的 goal 的 stable 状态。这些有关 MFS 运行中的状态都可在运行 mfscgiserv 的 Web UI 上查看到。



mfscgiserver web 页面统计信息：

MooseFS chunkservers 的维护

假如每个文件的 goal （目标）都不小于 2，并且没有 undergoal 文件（这些可以用 mfsgetgoal -r 和 mfsdirinfo 命令来检查），那么一个单一的 chunkserver 在任何时刻都可以做停止或者是重新启动。以后每当需要做停止或者是重新启动另一个 chunkserver 的时候，要确定之前的 chunkserver 被连接，而且要没有 undergoal chunks。

MooseFS 垃机箱机制

删除的文件存放在 “垃圾箱（trash bin）” 的时间就是隔离时间（quarantine time），这个时间可以用 mfsgettrashtime 命令来验证，也可以用 mfssettrashtime 命令来设置。

与文件被存储的份数一样，为一个目录设定存放时间后，在此目录下新创建的文件和目录就可以继承这个设置了。数字 0 意味着一个文件被删除后，会立即彻底删除，不可能再恢复了。删除的文件可以通过一个单独安装的mfsmeta 辅助文件系统来恢复。这个文件系统包含了目录 sustained（含有仍然可以被还原的删除文件的信息）和目录trash/undel（用于获取文件）。只有管理员有权限访问 mfsmeta 辅助文件系统（管理员用户的系统 uid 为 0，通常是 root 用户）

1
2
[root@Mallux ~]# mkdir /mfsmeta
[root@Mallux ~]# mfsmount /mfsmeta -H mfsmaster -o mfsmeta


MooseFS 快照



MFS 系统的另一个特征是利用 mfsmakesnapshot 工具给文件或者目录树做快照（snapshot）。

其中，src 是源文件路径或者目录，det 是快照文件路径或者目录。需要注意的是，dst 路径必须在 MFS 文件系统下，即 src 与 dst 路径必须都在 MFS 体系下，不能将快照放到 MFS 文件系统之外的其他文件系统下。mfsmakesnapshot 是在一次执行中整合了一个或一组文件的副本，而且对这些文件的源文件进行任何修改都不会影响源文件的快照，就是说任何对源文件的操作，如写入源文件，将不会修改副本（反之亦然）。

MooseFS 的快照，是以整个 Chunk 为单位进行 COW（写时复制），可能造成响应时间恶化，补救办法是以牺牲系统规模为代价， 降低 Chunk 大小。

1
2
[root@Mallux ~]# cd /data/
[root@Mallux ~]# mfsmakesnapshot c3 c3.snap


维护 MFS

维护 MFS，最重要的是维护元数据服务器，而元数据服务器最重要的目录为 /var/lib/mfs, MFS 数据的存储、修改、更新等操作变化都会记录在这个目录的某个文件中，因此只要保证这个目录的数据安全，就能保证整个 MFS 文件系统的安全性和可靠性。/var/lib/mfs 目录下的数据由两部分组成：一部分是元数据服务器的改变日志文件，文件名称类似于changelog.*.mfs；另一部分是元数据文件metadata.mfs，运行 mfsmaster 时该文件会被命名为metadata.mfs.back。只要保证了这两部分数据的安全，即使元数据服务器遭到致命的破坏，也可以通过备份的元数据文件重新部署一套元数据服务器。

MooseFS 元数据的备份

通常元数据由两部分数据组成：

主要元数据文件 metadata.mfs，在 MFS 的管理服务器 master 运行时会被命名为 metadata.mfs.back。
元数据改变日志 changelog.*.mfs，存储过去 N 小时内的文件改变（N 的数值是由 BACK_LOGS 参数设置的，参数的设置在 mfschunkserver.cfg 配置文件中进行）。
主要的元数据文件需要定期备份，备份的频率取决于多少小时改变日志的储存。元数据改变日志应该实时地自动复制。自从 MooseFS 1.6.5 开始，这两项任务都是由元数据日志服务器守护进程完成的。

元数据日志备份服务器，元数据改变日志的命名方式为：changelog_ml.<数字>.log，元数据备份文件为 metadata_ml.mfs.back，历史的备份为 metadata_ml.mfs.back.<数字>。

元数据改变日志有个很有趣的现象，表现为：存储服务器有元数据变化时，会有个最新的改变日志文件 changelog_ml.0.log；如果一段时间都没有变化，这个文件会转变为历史备份文件，命名方式是数字 0 转变为０以后的其它数字。因此，changelog_ml.0.log 是实时从 master 服务器同步过来的有改变的元数据改变日志。

MooseFS master 的恢复

一旦管理服务器崩溃（例如由主机或电源失败导致的），需要最后一个元数据改变日志 changelog（changelog_ml.0.mfs 或者最后一个改变日志） 和主要元数据文件 metadata.mfs（metadata_ml.mfs.back），从 1.7 版本开始，原先的 mfsmetarestore 工具将不可用，需要使用 mfsmaster -a 子命令来完成恢复动作。

1
2
[root@MFS-M1 ~]# mfsmaster help | grep '^\-a'
-a : automatically restore metadata from change log
执行此命令后，默认会在 /var/lib/mfs 目录中自动寻找需要的改变日志文件和主要元数据文件。注意，在恢复时自动查找的是 metadata.mfs.back 文件，而不是 metadata.mfs 文件，如果找不到 metadata.mfs.back 文件，会继续查找是否存在 metadata_ml.mfs.back 文件，如果没有，将提示恢复错误。

Step 1：破坏演示，停止 mfsmaster，删除 /var/lib/mfs/ 目录下所有文件



Step 2：从 metalogger 上传备份的元数据日志和元数据文件



Step 3：元数据服务器恢复操作



从备份恢复 MFS 管理服务器

为了从备份中恢复一个管理服务器，需要按以下步骤进行：

安装一个管理服务器。
利用同样的配置来配置这台管理服务器（利用备份找回 mfsmaster.cfg），可见配置文件也是需要备份的。
找回 metadata.mfs.back 文件，可以从备份服务器中找，也可以从元数据日志服务器中找（如果启动了元数据日志服务），然后把 metadata.mfs.back 放入 /var/lib/mfs 目录中。
从在管理服务器宕机之前的任何运行元数据日志服务的服务器上复制最后一个changelog_m1.*.mfs文件，放入管理服务器的数据目录。
利用 mfsmaster -a 命令合并元数据改变日志。
增加 chunkserver 服务器

增加前：

新增 node4 服务器，所需要做的动作就是按照前面的步骤，正确安装 chunkserver 服务，追加集群资源即可。加入 chunkservers 集群后，MFS 会自动做 rebalance 均衡处理，下图为正在做 rebalance 中的 chunkservers 集群。



MooseFS 性能测试
常见的 IO 性能测试工具：dd、iozone、fio。

此节仅提供参考数据，因测试环境中 server 和 client 都是在基于一台 KVM 宿主机部署的，如下图所示



测试前，为避免客户端内存缓存的影响，特别对读操作的影响。因此，下面的所有 IO 测试中，每次测试前都执行一次清除内存缓存的操作，再执行相关测试。实际测试写性能因副本的关系，实际写性能是会下降的，而读性能，Moosefs 在文件超过 64M 时，会分成多个 chunk，分布存储在集群的 chunkservers 上，因此读性能是会大大提升的。以下所有测试，受限于单 KVM、单硬盘的架构，数据有所出入。

1
2
3
4
5
6
7
To free pagecache：echo 1 > /proc/sys/vm/drop_caches
To free dentries and inodes：echo 2 > /proc/sys/vm/drop_caches
To free pagecache, dentries and inodes：echo 3 > /proc/sys/vm/drop_caches
### sync/clean/restore
[root@Mallux ~]# sync && echo 3 > /proc/sys/vm/drop_caches && sleep 3 && \
sync && echo 0 > /proc/sys/vm/drop_caches
dd 工具

单点 write 测试

1
2
3
4
[root@NODE1 ~]# dd if=/dev/zero of=1g.file bs=1M count=1k conv=fsync oflag=direct
### conv=fsync：likewise, but also write metadata，表示每次写入都要同步到物理磁盘上才返回
### oflag=direct：使用直写绕过页面缓存


挂载点 wirte 测试



单点 read 测试

1
2
3
[root@NODE1 ~]# dd if=1g.file of=/dev/null bs=1M count=1k iflag=direct
### iflag=direct：use direct I/O for data，直接从物理磁盘上读取数据


挂载点 read 测试



iozone 工具

官方下载地址：http://www.iozone.org/src/current/
百度百科：http://baike.baidu.com/view/3502720.htm

iozone 是一个文件系统的 benchmark 工具，可以测试不同的操作系统中文件系统的读写性能。 可以测试 Read、write、 re-read、re-write、read backwards、read strided、fread、fwrite, random read、pread、mmap、aio_read、aio_write 等等不同的模式下的硬盘的性能。 测试的时候请注意，设置的测试文件的大小一定要大过你的内存（最佳为内存的两倍大小），不然 linux 会给你的读写的内容进行缓存，会使数值非常不真实。

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
29
### 执行副本为 2 的测试
[root@Mallux ~]# mfsgetgoal /data/c2/
/data/c2/: 2
[root@Mallux ~]# iozone -a -n 1m -g 1g -q 64k -I -i 0 -i 1 \
-f /data/c2/iozone.tgz -Rb ./iozone.xls -C
### -a 表示自动模式，默认时测试的文件块大小为 4k 到 16M，文件大小从 64k 到 512M。
### -R 表示创建 excel 报告，-b 表示指定 excel 报告文件的名字
### -I 表示 Direct IO，直接读写硬盘，绕过 cahce/buffer
### -i 指定测试的类型，有如下 12 种测试类型，常用 0/1/2：
###       0=write/rewrite：顺序写，write/rewrite 区别在于，一个新建、一个重写（存在 inode 信息）
###       1=read/re-read：顺序读
###       2=random-read/write：随机读写，测试环境超级慢，不做测试。
###       3=Read-backwards
###       4=Re-write-record
###       5=stride-read
###       6=fwrite/re-fwrite
###       7=fread/Re-fread
###       8=random_mix
###       9=pwrite/Re-pwrite
###       10=pread/Re-pread
###       11=pwritev/Re-pwritev
###       12=preadv/Re-preadv
### -n 指定测试用的最小文件的大小
### -g 指定测试用的最大文件的大小
### -q 指定测试用的最大块的大小
### -r 指定测试用的块大小：例如只测试 4k/16k/64k，指定 -r 4k -r 16k -r 64k
### -C 指定显示每个节点的吞吐量
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
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
### 1G 大小的文件，按 chunk 64M 分块，分为 15 个 chunk，每个 chunk goal 为 2。
[root@Mallux ~]# mfsfileinfo /data/c2/iozone.tgz
/data/c2/iozone.tgz:
    chunk 0: 00000000000003EE_00000001 / (id:1006 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 1: 00000000000003EF_00000001 / (id:1007 ver:1)
        copy 1: 192.168.96.21:9422
        copy 2: 192.168.96.22:9422
    chunk 2: 00000000000003F0_00000001 / (id:1008 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 3: 00000000000003F1_00000001 / (id:1009 ver:1)
        copy 1: 192.168.96.21:9422
        copy 2: 192.168.96.22:9422
    chunk 4: 00000000000003F2_00000001 / (id:1010 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 5: 00000000000003F3_00000001 / (id:1011 ver:1)
        copy 1: 192.168.96.21:9422
        copy 2: 192.168.96.22:9422
    chunk 6: 00000000000003F4_00000001 / (id:1012 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 7: 00000000000003F5_00000001 / (id:1013 ver:1)
        copy 1: 192.168.96.21:9422
        copy 2: 192.168.96.22:9422
    chunk 8: 00000000000003F6_00000001 / (id:1014 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 9: 00000000000003F7_00000001 / (id:1015 ver:1)
        copy 1: 192.168.96.21:9422
        copy 2: 192.168.96.22:9422
    chunk 10: 00000000000003F8_00000001 / (id:1016 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 11: 00000000000003F9_00000001 / (id:1017 ver:1)
        copy 1: 192.168.96.21:9422
        copy 2: 192.168.96.22:9422
    chunk 12: 00000000000003FA_00000001 / (id:1018 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 13: 00000000000003FB_00000001 / (id:1019 ver:1)
        copy 1: 192.168.96.21:9422
        copy 2: 192.168.96.22:9422
    chunk 14: 00000000000003FC_00000001 / (id:1020 ver:1)
        copy 1: 192.168.96.23:9422
        copy 2: 192.168.96.24:9422
    chunk 15: 00000000000003FD_00000001 / (id:1021 ver:1)
        copy 1: 192.168.96.22:9422
        copy 2: 192.168.96.24:9422


1
2
### 上面的表格当中，最左列为测试的文件大小，第二列开始为每个测试块的读写速度。
### 例 1024 KB的文件，在 Write 4K 的测试中，写速度为 139 MB/s。
fio 工具

HOWTO：http://www.bluestop.org/fio/HOWTO.txt

fio 是测试 IOPS 的非常好的工具，用来对硬件进行压力测试和验证，支持 20 种不同的 I/O 引擎， 包括：sync、mmap、libaio、posixaio、SG v3、splice、null、network、syslet、guasi、solarisaio 等等。支持 Linux 新内核的 I/O 优先级，I/O 速率，子线程及更多的功能。支持裸设备也支持文件系统，支持文本方式的脚本，FIO 会显示 I/O 信息，支持 Linux、FreeBSD、NetBSD、OpenBSD、OS X、OpenSolaris、AIX、HP-UX、Android 和 Windows。

fio 特点主要如下

跨平台，支持 Unxi、Linux、Windows 系统
支持多种 I/O 引擎
支持命令行和脚本
支持对 CPU、内存、线程、I/O 非常细致的配置
支持非常丰富的测试类型，有非常细致的参数，使用简单，功能强大
fio 基本参数

IO 类型（IO type）：顺序读写、随机读写、混合读写等。
块大小（Block size）：测试时使用的块大小，可以是一个数值，也可以一个范围
IO 大小（IO size）：读写数据的大小
IO 引擎（IO engine）：测试时使用的 IO 引擎，例如 mmap、sync、splice、async、syslet 等等
IO 队列深度（IO depth）：如果是异步读写，维护多大的一个队列深度
IO 缓存类型（IO type）：是否打开文件系统的缓存
文件数量（Ｎum files）：同时读写几个文件
线程数量（Num threads）：同时运行几个线程
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
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
### 配置相关的参数
--debug                 ### 调试模式
--version               ### 显示版本信息
### 测试任务相关的参数
--output=str            ### 输出到文件
--runtime=int           ### 限制测试运行的时间，单位为秒
--sync=bool             ### 是否同步写缓存，默认异步
--name=str              ### 测试项目名称
--description=str       ### 测试项目描述
--filename=str          ### 测试文件或裸设备
--size=int              ### 需要测试的文件大小
--filesize=irange       ### 单独的文件大小，也可以是一个范围。
                            fio 在设定的 size 只内随机的选择大小，如果没有指定，每个子文件大小相同。
### 读写相关的参数
--readwrite=str         ### 或 rw=str
                        ### 测试的 IO 模式有：
                            read           顺序读
                            write          顺序写
                            randread       随机读
                            randwrite      随机写
                            rw，readnwrite 混合读写
                            randrw         随机混合读写
                        ### 如果是混合读写，默认是 50/50 即 50% 读加 50% 写。
　　　　　　　　　　　　　　对于特定的类型，结果会有些出入，因为速度可能不一样，可以在测试的指定一个数字。
--rwmixread=int         ### 混合读写，读的比率
--rwmixwrite=int        ### 混合读写，写的比率
--blocksize=int[,int]   ### 或 bs=int[,int] 测试所使用的块大小，例 4K、16K、64K
--blocksize_range=irange[,irange], bsrange=irange[,irange]   ### 测试块大小范围
--bssplit=str           ### 需要测试混合块大小的时候使用，可以按照如下的格式
                            bssplit=4k/10:64k/50:32k/40 4K占10% 64K占50% 32k占40%
                            也可以不指定百分比，fio 会平均分配，比如
                            bssplit=4k/50:1k/:32k/ 就是 4k 占 50%，1K/32K 各占 25%
                            bssplit 读写的时候都可以使用
### 运行相关参数
--iodepth=int           ### IO 队列深度，默认 1
--ioengine=str          ### IO 引擎
                            sync：read() or write() IO
                            psync：pread() or pwrite IO
                            libaio：linux native asynchronous IO
--direct=int            ### 是否使用文件系统缓存，1 为禁用，默认 0
--numjobs=int           ### 使用的线程数量，默认 1
--max-job=int           ### 运行的最高线程
--nrfiles=8 　　　　　  ### 每个进程生成文件的数量
--lockmem=2G            ### 固定测试的时候内存大小，比如 2G
--rate=int              ### 限制读写的速度
                            rate=500k（读写）
　　　　　　　　　　　　　　　rate=1m,500k（读1m，写500k）
                            rate=500k,（限制读）
                            rate=,500K（限制写）
--ratemin=int
--rate_iops=int
--rate_iops_min=init
--cpumask=int           ### cpu 亲和力，绑定在哪些 cpu 上运行
--numa_cpu_nodes=str    ### NUMA 架构
--numa_mem_policy=str
--zero_buffers          ### 如果使用这个参数，fio 会初始化 IO 缓存，并默认使用随机的数据填满缓存。
--refill_buffers        ### 强制重新填写读写缓存
--group_reporting       ### 汇总每个进程的信息
脚文文件格式o

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
; -- start job file --
[global]
rw=randread
size=128m
[job1]
[job2]
; -- end job file --
### 该脚本的命令表现为：fio --name=global --rw=randread --size=128m --name=job1 --name=job2
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
; -- start job file --
[random-writers]
ioengine=libaio
iodepth=4
rw=randwrite
bs=32k
direct=0
size=64m
numjobs=4
; -- end job file --
### 命令格式：$ fio --name=random-writers --ioengine=libaio --iodepth=4 --rw=randwrite --bs=32k --direct=0 --size=64m --numjobs=4
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
###　也可使用 include 包含其它脚本
; -- start job file including.fio --
[global]
filename=/tmp/test
filesize=1m
include glob-include.fio
[test]
rw=randread
bs=4k
time_based=1
runtime=10
include test-include.fio
; -- end job file including.fio --
; -- start job file glob-include.fio --
thread=1
group_reporting=1
; -- end job file glob-include.fio --
; -- start job file test-include.fio --
ioengine=libaio
iodepth=4
; -- end job file test-include.fio --
示例：

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
[global]
filename=/data/c4/fio.iops
direct=1
iodepth=1
numjobs=1
runtime=300
group_reporting
size=64m
bs=4k
### 随机读
[rand-read]
name=rand-read
rw=randread
### 随机写
[rand-write]
name=rand-read
rw=randwrite
### 随机混合读写
[rand-rwmix]
name=rand-rw
rw=randrw
bssplit=4k/20:8k/20:16k/20:32k/20:64k/20
rwmixwrite=20
1
2
3
[root@Mallux ~]# mkdir /data/c4
[root@Mallux ~]# mfssetgoal 4 /data/c4
[root@Mallux ~]# fio iops.conf






Git（物理节点）分布式性能测试报告

双节点 master 机制，无 metalogger
三节点 chunkserver
Git - MFS perf report

Corosync + Pacemaker + DRBD 高可用集群


说明，整个集群使用两组集群方案，其中：

LVS + Keepalvied，实现后端 Git Server 的 HA + LB 集群
Corosync + Pacemake + DRBD，实现后端 Git Server 存储资源的分布式 HA + LB 集群
准备工作

Moosefs master 高可用集群中，我们需要配置：

master 节点（主要配置点）：时间同步；master 之间主机名的互相通信、SSH 互信
chunkserver 节点：时间同步；基于主机名的 master 通信
以 MFS-M1 master 为例：

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
### 配置主机名
[root@MFS-M1 ~]# tail -n3 /etc/hosts
10.128.190.179 MFS-M1
10.128.190.180 MFS-M2
### 配置时间同步机制
[root@MFS-M1 ~]# tail -n1 /etc/crontab
*/10 * * * * root /usr/sbin/ntpdate 10.128.161.195 &> /dev/null
### 配置 SSH 互信
[root@MFS-M1 ~]# ssh-keygen -t rsa
[root@MFS-M1 ~]# ssh-copy-id -i ~/.ssh/id_rsa.pub root@MFS-M2
Ansible 部署脚本

对于 Moosefs + DRBD + Corosync 的高可用集群，为了完成自动化地部署，需要保证集群系统、环境、HA 资源服务的一致性，这是线上大规模自动化运维的基本要求。本文档的所涉及到的服务器，其系统、软件环境全部采用 Cobbler + LNAMP 部署脚本实现。

此外，Ansible 中有一些相当好用的模块，以下是一个 LVM 模块的使用示例。测试环境中，Moosefs master 的 mfsmeta 分区（用于 DRBD），chunkserver 的 data 分区，都是通过此模块来实现批量创建、格式化、挂载等动作。

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
[root@Mallux ansible]# ansible -i mfs.hosts chunkserv -m lvol -a "vg=mainVG lv=lv_mfspool size=50G" -k
[root@Mallux ansible]# ansible -i mfs.hosts chunkserv -a "mkfs.ext4 /dev/mainVG/lv_mfspool" -k
[root@Mallux ansible]# ansible -i mfs.hosts chunkserv -m file -a "path=/mfspool/hd1 \
state=directory owner=mfs group=mfs" -k
[root@Mallux ansible]# ansible -i mfs.hosts chunkserv -m mount \
-a "name=/mfspool/hd1 src=/dev/mainVG/lv_mfspool fstype=ext4 state=present" -k
[root@Mallux ansible]# ansible -i mfs.hosts chunkserv -a "chown mfs.mfs -R /mfspool" -k
下面给出 Ansible playbook 实现 MooseFS + Corosync + Pacemaker + DRBD 整个集群的部署，不包括 LVS + Keepalived 部分（笔记部分，参见 “07 - Cluster 系列笔记” 之 “07 - Keepalived HA Cluster”）和集群资源配置（需手动配置，参见 “7.3 Corosync + Pacemaker 配置集群资源”）。

Download - Ansible scripts

Corosync + Pacemaker 配置集群资源

Corosync + Packemaker 不做具体介绍，以下仅列出使用 crm（crmsh）命令配配置接口定义好的，经过测试无问题，可使用的 CIB 配置。笔记部分参见 “07 - Cluster” 系列文章之 “04 - Corosync HA Cluster“ 及 “06 - DRBD HA Cluster”。

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
29
30
31
32
33
34
35
36
37
38
39
[root@MFS-M1 data]# crm configure show
node MFS-M1 \
        attributes standby="off"
node MFS-M2
primitive mfscgiserv lsb:moosefs-cgiserv
primitive mfsmaster lsb:moosefs-master
primitive mfsmeta ocf:linbit:drbd \
        params drbd_resource="mfsmeta" \
        op start timeout="240s" interval="0" \
        op stop timeout="100s" interval="0" \
        op monitor role="Master" timeout="30s" interval="50s" \
        op monitor role="Slave" timeout="30s" interval="60s"
primitive mfsmount ocf:heartbeat:Filesystem \
        params device="/dev/drbd0" directory="/data/mfsmeta" fstype="ext4" \
        op start timeout="60s" interval="0" \
        op stop timeout="60s" interval="0" \
        op monitor timeout="40s" interval="40s" \
        meta target-role="Started"
primitive mfsvip ocf:heartbeat:IPaddr \
        params ip="10.128.190.210" iflabel="0" \
        op monitor timeout="20s" interval="20s" on-fail="restart"
group mfservice mfsmaster mfscgiserv
ms MS_mfsmeta mfsmeta \
        meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true" target-role="Started"
location mfsvip_on_MFS_M1 mfsvip \
        rule $id="mfsvip_on_MFS_M1-rule" inf: #uname eq MFS-M1
colocation mfservice_with_mfsmount inf: mfservice mfsmount
colocation mfsmount_with_mfsmeta inf: mfsmount MS_mfsmeta:Master
colocation mfsvip_with_mfsmount inf: mfsvip mfsmount
order MS_mfsmeta_before_mfsmount inf: MS_mfsmeta:promote mfsmount:start
order mfsmount_before_mfservice inf: mfsmount:start mfservice:start
order mfsvip_before_MS_mfsmount inf: mfsvip:start mfsmount:start
property $id="cib-bootstrap-options" \
        dc-version="1.1.10-14.el6-368c726" \
        cluster-infrastructure="classic openais (with plugin)" \
        expected-quorum-votes="2" \
        stonith-enabled="false" \
        no-quorum-policy="ignore" \
        last-lrm-refresh="1455890016"
END
# Storage