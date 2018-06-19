【二】GlusterFS体系结构 - CSDN博客
 http://blog.csdn.net/watermelonbig/article/details/49160809

 二、GlusterFS体系结构

注：本文及本系列文章均是翻译自GlusterFS doc官方英文文档，除此之外又根据自己翻阅的其它资源对原文档做了部分补充。
1. 逻辑存储卷的几种类型

在GlusterFS中逻辑卷（volume）是一组存储块（bricks）的集合，GlusterFS可以支持多种类型的逻辑卷，以实现不同的数据保护级别和存取性能。
1.1 分布存储卷（Distributed Glusterfs Volume）

分布存储是Glusterfs 默认使用的存储卷类型。文件会被分布得存储到逻辑卷中的各个存储块上去。以两个存储块的逻辑卷为例，文件file1可能被存放在brick1或brick2中，但不会在每个块中都存一份。分布存储不提供数据冗余保护。
 
创建分布存储的命令格式为：
#gluster volume create NEW-VOLNAME [transport [tcp | rdma | tcp,rdma]] NEW-BRICK...
样例：
#gluster volume create test-volume server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4
Creation of test-volume has been successful Please start the volume to access data
查看逻辑卷的状态：
#gluster volume info 
Volume Name: test-volume 
Type: Distribute 
Status: Created 
Number of Bricks: 4 
Transport-type: tcp 
Bricks: Brick1: server1:/exp1 Brick2: server2:/exp2 Brick3: server3:/exp3 Brick4: server4:/exp4
1.2 镜像存储卷（Replicated Glusterfs Volume）

在镜像存储逻辑卷中，数据至少会在不同的brick上被存储两份，具体采取存储几份的冗余数据则可以在创建镜像存储卷时予以设定。镜像存储可以有效得预防存储块损坏可能引发的数据丢失的风险。
 
创建镜像存储的命令格式为：
#gluster volume create NEW-VOLNAME [replica COUNT] [transport [tcp | rdma | tcp,rdma]] NEW-BRICK...
样例：
# gluster volume create test-volume replica 2 transport tcp server1:/exp1 server2:/exp2 
Creation of test-volume has been successful Please start the volume to access data
 
关于镜像存储卷的仲裁盘配置：
# gluster volume create <VOLNAME> replica 3 arbiter 1 host1:brick1 host2:brick2 host3:brick3
在镜像存储卷中使用一个独立的brick作为仲裁盘，是为了避免发生脑裂后无法认定数据一致性的问题。
注：对于任何涉及到镜像存储的逻辑卷，在创建时都不能把同一个主机节点上的两个brick设置到同一组镜像复制关系中。即使尝试这样做，也会创建失败。
1.3 分布式镜像存储卷（Distributed Replicated Glusterfs Volume）

在这种逻辑卷中，文件是跨镜像存储块的集合（replicated sets of bricks）进行分布式存储的，即文件可能被存储在某一个镜像存储块集合中，但不会同时存储到多个集合。而在一个镜像存储块的集合内，文件是在每个存储块（brick）上各存一份。
在我们使用命令创建分布式镜像存储卷时，需要特别注意在设定需要加入逻辑卷中的brick时，每个brick的顺序会决定它与哪一个brick结成镜像复制的关系。Brick会按照从前至后，选择与自己邻近的brick结成镜像复制的关系。例如，我们有8个bricks，设置的数据复制份数为2，那么前两个brick就会成为互为镜像的关系，紧接着的后两个结为镜像关系，以此类推。
 
创建分布式镜像存储的命令格式为：
# gluster volume create NEW-VOLNAME [replica COUNT] [transport [tcp | rdma | tcp,rdma]] NEW-BRICK...
样例：
# gluster volume create test-volume replica 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4 
Creation of test-volume has been successful Please start the volume to access data
我们可以看到，镜像存储逻辑卷和分布式镜像存储逻辑卷，它们的创建命令是相同的。不同点在于，在设定数据复制份数和指定加入到卷中的bricks时，如果刚好只够一个镜像存储块集合则是镜像存储卷，如果可以组成多个镜像存储块集合，那么自然就成为分布式镜像存储卷。
1.4 分片式存储卷（Striped Glusterfs Volume）

在分片式存储卷中，一个文件会被切分成多份，数量等于brick的数量，然后每个brick中存一份。这种方式不提供数据冗余保护。
 
创建分片式存储的命令格式为：
#gluster volume create NEW-VOLNAME [stripe COUNT] [transport [tcp | dma | tcp,rdma]] NEW-BRICK...
样例：
# gluster volume create test-volume stripe 2 transport tcp server1:/exp1 server2:/exp2 
Creation of test-volume has been successfulPlease start the volume to access data
1.5 分布式分片存储卷（Distributed Striped Glusterfs Volume）

这种方式实际上是在分片式存储卷的基础上做的扩展，即根据你设定的分片参数（一个文件分成几片）和你为逻辑卷加入的bricks数量可以组成多个分片存储块集合时，自然就成为了分布式分片存储卷。每个分片存储块集合中存储的的数据是不同的。
创建分布式分片存储的命令格式为：
#gluster volume create NEW-VOLNAME [stripe COUNT] [transport [tcp | rdma | tcp,rdma]] NEW-BRICK...
样例，以下是一个包含8个存储服务器在内的分布式分片存储逻辑卷：
# gluster volume create test-volume stripe 4 transport tcp  server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4 server5:/exp5 server6:/exp6 server7:/exp7 server8:/exp8 
Creation of test-volume has been successful Please start the volume to access data.
 
1.6 分布式分片及镜像复制存储卷（Distributed Striped Replicated Volume）
这种方式创建的存储卷会将数据分片后，分布式地跨多个镜像bricks集合来存储。用途为解决大数据的、高并发的、性能敏感的数据存储和使用场景，例如Map Reduce负载。
# gluster volume create test-volume stripe 2 replica 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4 server5:/exp5 server6:/exp6 server7:/exp7 server8:/exp8 
Creation of test-volume has been successful Please start the volume to access data.
1.7 分片及镜像复制存储卷（Striped Replicated Volume）
 
 
# gluster volume create test-volume stripe 2 replica 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4 
Creation of test-volume has been successful Please start the volume to access data.
或是如下：
# gluster volume create test-volume stripe 3 replica 2 transport tcp server1:/exp1 server2:/exp2 server3:/exp3 server4:/exp4 server5:/exp5 server6:/exp6 
Creation of test-volume has been successful Please start the volume to access data.
同样地，分片及镜像复制存储卷也是用于处理大数据的、高并发的、性能敏感的业务数据。目前看，这种存储卷仅适合用于Map Reduce负载。
1.8 关于离散存储卷（Dispersed Volume）
离散存储卷是基于一种前向纠错码技术来实现的，它会对存储进来的数据进行切分，然后附加一些部分冗余的纠错码。这种类型的存储卷要以在实现可接受的数据可靠性的条件下，最大化得避免空间的浪费。
# gluster volume create test-volume disperse 4 server{1..4}:/bricks/test-volume There isn't an optimal redundancy value for this configuration. Do you want to create the volume with redundancy 1 ? (y/n)
又例如：
# gluster volume create test-volume disperse 6 server{1..6}:/bricks/test-volume The optimal redundancy for this configuration is 2. Do you want to create the volume with this value ? (y/n)
其中disperse参数指定的是参与到存储冗余数据的bricks数量。详情可参见：
http://gluster.readthedocs.org/en/latest/Administrator%20Guide/Setting%20Up%20Volumes/#creating-dispersed-volumes
相应地，你还可以创建分布式的离散存储卷（Distributed Dispersed Volume）。
2. FUSE用户空间文件系统

GlusterFS是一个基于用户空间实现的文件系统。其中FUSE作为内核模块，用于实现内核VFS和非特权的应用用户的交互。
 
3. 转换器

3.1 什么是转换器
n 转换器把来自用户的请求转换成对存储的访问请求。
n 转换器可以在中途修改用户请求，包括路径、标识甚至数据。
n 转换器可以阻塞或过滤访问请求。
n 转换器可以发起新请求。
3.2 转换器怎么工作
n 共享对象（Shared Objects）
n 动态加载（Dynamically loaded according to 'volfile'）
 
 
3.3 转换器的类型
Translator Type
Functional Purpose
Storage
Lowest level translator, stores and accesses data from local file system.
Debug
Provide interface and statistics for errors and debugging.
Cluster
Handle distribution and replication of data as it relates to writing to and reading from bricks & nodes.
Encryption
Extension translators for on-the-fly encryption/decryption of stored data.
Protocol
Extension translators for client/server communication protocols.
Performance
Tuning translators to adjust for workload and I/O profiles.
Bindings
Add extensibility, e.g. The Python interface written by Jeff Darcy to extend API interaction with GlusterFS.
System
System access translators, e.g. Interfacing with file system access control.
Scheduler
I/O schedulers that determine how to distribute new write operations across clustered systems.
Features
Add additional features such as Quotas, Filters, Locks, etc.
3.4 转换器的通用配置
 
3.5 关于DHT转换器
DHT是GlusterFS整合资源以提供跨多节点的存储服务的核心。它提供的是一个路由功能，为每个文件找到准确的存储位置。DHT使用一致性哈希的算法来管理信息。在每个brick上都设置了一个长度不大于32bit的哈希值空间，覆盖到了这个存储块的整个存储地址范围。存储在brick上的每个文件的文件名的哈希值也同样存储在这个哈希空间里。当你访问一个文件时，DHT转换器会根据你提供的文件名和每个brick的哈希空间中存储的值进行匹配，来发现和找到文件具体的存储地址。
DHT在缩小寻找的哈希范围时使用了一个文件夹的扩展属性，因此DHT是对文件夹敏感的。如果一个brick丢失了，那么就会在哈希空间中留下一个“空洞”，而更糟糕的是如果在下线一个brick时重新计算了存储的哈希范围，一部分新的范围可能会和存储在那个brick上的哈希范围（现在已过期）重叠。这也会给找到文件的存储地址带来麻烦。
3.6 自动文件复制转换器（AFR(Automatic File Replication) Translator）
在GlusterFS中负责实现跨bricks的数据复制。提供数据复制一致性的维护，提供数据恢复服务（当有一个brick损坏，而至少还有一个brick上有正确的数据），以及为新数据提供读文件、文件状态和文件夹信息等服务。
3.7 Geo复制（Geo-Replication）
Geo-replication 是面向广域网环境提供的GlusterFS数据复制解决方案，主要是基于整个的逻辑存储卷进行数据的复制，而不像AFR转换器是面向同一个集群环境内的复制技术。Geo-replication 使用主从模式，主节点需要使用一个GlusterFS逻辑卷，从节点可以是一个本地目录或一个GlusterFS逻辑卷。主从之间通过SSH隧道进行通信。Geo-replication 可以基于局域网、广域网和互联网环境，提供增量的数据复制功能。
Geo-replication over LAN:
 
Geo-replication over WAN:
 
Geo-replication over Internet:
 
Multi-site cascading Geo-replication:
 
异步复制数据的过程主要是两个方面的内容：
n 侦测文件变化
Entry - create(), mkdir(), mknod(), symlink(), link(), rename(), unlink(), rmdir()
Data - write(), writev(), truncate(), ftruncate()
Meta - setattr(), fsetattr(), setxattr(), fsetxattr(), removexattr(), fremovexattr()
n 复制
主要是使用rsync进行数据传输。
4. GlusterFS工作机制

4.1 当在一个主机上安装了GlusterFS服务后，会自动创建一个gluster management后台进程。这个进程需要在存储集群中的每个节点上运行。
4.2 在启动glusterd进程后，接需来需要创建一个包含了全部存储节点主机的可信任主机池（TSP）。
4.3 现在，可以在每个存储主机节点上开始创建存储块bricks了。我们可以把来自TSP的bricks按照一定规则形成我们需要的逻辑存储卷。
4.4 在创建了逻辑存储卷后，在每个被纳入到逻辑卷中的brick节点上都会启动一个glusterfsd进程。同时，在/var/lib/glusterd/vols目录下会生成相关的配置文件（vol files），这些配置文件中包含关于当前brick在逻辑卷中的详细描述信息。此外还会在该路径下创建一个客户端进程需要使用到的配置文件。
到此为止，我们的逻辑卷已经可以挂接使用了。挂接命令格式如下：
#mount.glusterfs  `<IP or hostname>`:`<volume_name>`  `<mount_point>
注：可以使用在可信任存储池中创建了这个逻辑卷的任一个主机节点的IP或主机名。
4.5 当我们在一个客户机上挂接了逻辑卷后，客户机上的glusterfs进程开始与服务端的glusterd进程通信。Glusterd服务端进程向客户机发送一个配置文件（vol file），配置文件中包含了客户机端需要使用的转换器列表信息和逻辑卷中每个brick的信息。
