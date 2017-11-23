

* http://docs.gluster.org/en/latest/Administrator%20Guide/GlusterFS%20Introduction/

Introducing Gluster File System

GlusterFS is an open source, distributed file system capable of scaling to several petabytes and handling thousands of clients. It is a file system with a modular, `stackable design(堆叠式)`, and a unique `no-metadata server architecture(无元数据架构)`. This no-metadata server architecture ensures better performance, linear scalability, and reliability. GlusterFS can be flexibly combined with commodity physical, virtual, and cloud resources to deliver highly available and performant enterprise storage at a fraction of the cost of traditional solutions.

GlusterFS clusters together storage building blocks over Infiniband RDMA and/or TCP/IP interconnect, aggregating disk and memory resources and managing data in a single global namespace.
GlusterFS集群，通过InfiniBand RDMA和/或TCP / IP，存储的数据，在一个单一的全局命名空间管理磁盘、内存资源和数据。

GlusterFS aggregates various storage servers over network interconnects into one large parallel network file system. Based on a stackable user space design, it delivers exceptional performance for diverse workloads and is a key building block of GlusterFS. The POSIX compatible GlusterFS servers, use any ondisk file system which supports extended attributes (eg: ext4, XFS, etc) to format to store data on disks, can be accessed using industry-standard access protocols including `Network File System (NFS) and Server Message Block (SMB)`.

640px-glusterfs_architecture

GlusterFS is designed for today's high-performance, virtualized cloud environments. `Unlike traditional data centers, cloud environments require multi-tenancy(多租户) along with the ability to grow or shrink resources on demand(按需增长或收缩资源)`. Enterprises can scale capacity, performance, and availability on demand, `with no vendor lock-in(没有厂商的限制)`, `across on-premise, public cloud, and hybrid environments(在私有云、公共云和混合环境中)`.

GlusterFS is in production `at thousands of enterprises(在成千上万的企业中) spanning(涵盖，跨越)` media, healthcare, government, education, web 2.0, and financial services.

Commercial offerings and support

Several companies offer support or consulting.

Red Hat Storage is a commercial storage software product, based on GlusterFS.

About On-premise Installation

GlusterFS for On-Premise allows physical storage to be utilized as a virtualized, scalable, and centrally managed pool of storage.

GlusterFS can be installed on commodity servers resulting in a powerful, massively scalable, and highly available NAS environment.

GlusterFS On-premise enables enterprises to treat physical storage as a virtualized, scalable, and centrally managed storage pool by using commodity storage hardware. It supports multi-tenancy by partitioning users or groups into logical volumes on shared storage. It enables users to eliminate, decrease, or manage their dependence on high-cost, monolithic and difficult-to-deploy storage arrays. You can add capacity in a matter of minutes across a wide variety of workloads without affecting performance. Storage can also be centrally managed across a variety of workloads, thus increasing storage efficiency.