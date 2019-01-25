

Docker用户指南(13) – 用户定义网络中的内置DNS服务器-Linux运维日志 https://www.centos.bz/2016/12/embedded-dns-server-in-docker-user-defined-networks/

本文介绍自定义网络的容器的内置DNS服务器操作。连接到用户定义网络的容器与连接到默认bridge网络的容器的DNS查询方法不太一样。
从Docker 1.10起，docker daemon为使用有效名称或网络别名或link别名创建的容器实现了一个内置的DNS服务器来提供内置的服务发现功能。
下面是是影响容器域名名称服务的各种容器选项。

–name=CONTAINER-NAME： 使用–name配置的容器名称用来在一个用户定义的docker网络内发现容器。内置的DNS服务器维护容器名称与它的IP地址的映射关系。
–network-alias=ALIAS：除了以上提供的–name，还可以在用户定义网络通过它配置的一个或多个–network-alias(或docker network connect命令的–alias)发现容器。内置的DNS服务器维护在一个指定用户定义网络的所有容器别名和它的IP地址之间的映射关系。在docker network connect命令中使用–alias选项容器可以在不同的网络中有不同的别名。
–link=CONTAINER_NAME:ALIAS：在你运行一个容器时使用这个选项给了内置DNS一条称为ALIAS额外的条目，这个ALIAS指向CONTAINER_NAME识别出来的IP地址。当使用–link时，内置的DNS会保证ALIAS只在使用–link的容器中可用。这使得新容器中的进程不需要知识容器的名称或IP就能够连接容器。
–dns=[IP_ADDRESS…]：此选项指定的DNS服务器IP地址用来当内置的DNS服务器无法解析来自容器的DNS解析请求时就把它的请求转向到这个指定的外部DNS服务器。这些–dns IP地址由内置的DNS服务器管理且不会更新到容器的/etc/resolv.conf文件。
–dns-search=DOMAIN…：设置当容器内部请求一个不合格的主机名时再次搜索的域名。这些dns-search选项由内置的DNS服务器管理且不会更新到容器的/etc/resolv.conf文件。当一个容器进程尝试访问host且搜索域名设置为example.com时，DNS不仅会查询host，也会查询host.example.com。
–dns-opt=OPTION…：设置用于DNS解析器的选项。这些选项由内置的DNS服务器管理且不会更新到容器的/etc/resolv.conf文件。

当没有指定–dns=IP_ADDRESS…, –dns-search=DOMAIN…, 或–dns-opt=OPTION…选项时，Docker使用主机(运行docker daemon的那台主机)的/etc/resolv.conf。如果是这种情况，daemon将从原始的文件过滤所有localhost IP地址nameserver条目。

过滤是必要的因为从容器的网络无法到达主机的所有本地地址。过滤之后，如果/etc/resolv.conf文件没有条目了，那么daemon将添加Google的公共DNS服务器 (8.8.8.8和8.8.4.4)到容器的DNS配置。如果IPv6启用了，将添加Google的IPv6 DNS服务器(2001:4860:4860::8888 和 2001:4860:4860::8844)。