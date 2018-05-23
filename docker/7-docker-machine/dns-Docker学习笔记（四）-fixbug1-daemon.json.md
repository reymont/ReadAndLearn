

Docker学习笔记（四）-fixbug1-daemon.json - CSDN博客 http://blog.csdn.net/Chenming_Hnu/article/details/54426199

因daemon.json中DNS Server设置而引起的错误

在使用docker的过程中如果报出以下错误：

（1）无法连接到docker daemon (docker 守护进程)

docker: Cannot connect to the Docker daemon. Is the docker daemon running on this host?.
See 'docker run --help'.
（2） 重启docker服务失败

mingchen@mingchen-HP:~$ sudo service docker restart
docker stop/waiting
start: Job failed to start
（3）在容器内部无法ping通百度、谷歌等外网

unknown host www.baidu.com
如何解决：

主要分为三个步骤。首先查询主机使用的DNS服务器；接着根据查询结果设置 /etc/docker/daemon.json 中的DNS server, 这个daemon.json文件实际上是docker中的daemon进程（守护进程）的配置文件，而守护进程又是所有启动的容器的父进程；最后，重启docker 服务。

（1）查询本机的DNS Server

可以通过以下命令之一：

$ nm-tool | grep DNS
或者

$ nmcli dev show | grep DNS    
1
我的结果如下：

mingchen@mingchen-HP:/$ nm-tool |grep DNS
    DNS:             127.0.0.1
    DNS:             8.8.8.8
    DNS:             172.20.1.4
    DNS:             172.20.1.6
1
2
3
4
5
（2） 设置/etc/docker/daemon.json文件

以sudo的权限打开，使用编辑器gedit, nano, vim ,vi 等，看读者爱好了。

{
 "dns": ["8.8.8.8","172.20.1.4","172.20.1.6", "127.0.0.1","8.8.4.4"]
}
按照上面的格式设置好。

（3） 重启docker 服务

在终端输入命令sudo service docker restart：

mingchen@mingchen-HP:/$ sudo service docker restart
docker stop/waiting
docker start/running, process 1046
1
2
3
另外，我也曾经在docker开发者论坛上发过与这个问题相关的帖子，有兴趣的话，可以去看看，完整回答在最底下，链接。
N.B. 有关daemon.json文件

以下是完整的daemon.json文件可配置的参数表，我们在配置的过程中，只需要设置我们需要的参数即可，不必全部写出来。详细参考，官方文档。
{
    "api-cors-header": "",
    "authorization-plugins": [],
    "bip": "",
    "bridge": "",
    "cgroup-parent": "",
    "cluster-store": "",
    "cluster-store-opts": {},
    "cluster-advertise": "",
    "debug": true,
    "default-gateway": "",
    "default-gateway-v6": "",
    "default-runtime": "runc",
    "default-ulimits": {},
    "disable-legacy-registry": false,
    "dns": [],
    "dns-opts": [],
    "dns-search": [],
    "exec-opts": [],
    "exec-root": "",
    "fixed-cidr": "",
    "fixed-cidr-v6": "",
    "graph": "",
    "group": "",
    "hosts": [],
    "icc": false,
    "insecure-registries": [],
    "ip": "0.0.0.0",
    "iptables": false,
    "ipv6": false,
    "ip-forward": false,
    "ip-masq": false,
    "labels": [],
    "live-restore": true,
    "log-driver": "",
    "log-level": "",
    "log-opts": {},
    "max-concurrent-downloads": 3,
    "max-concurrent-uploads": 5,
    "mtu": 0,
    "oom-score-adjust": -500,
    "pidfile": "",
    "raw-logs": false,
    "registry-mirrors": [],
    "runtimes": {
        "runc": {
            "path": "runc"
        },
        "custom": {
            "path": "/usr/local/bin/my-runc-replacement",
            "runtimeArgs": [
                "--debug"
            ]
        }
    },
    "selinux-enabled": false,
    "storage-driver": "",
    "storage-opts": [],
    "swarm-default-advertise-addr": "",
    "tls": true,
    "tlscacert": "",
    "tlscert": "",
    "tlskey": "",
    "tlsverify": true,
    "userland-proxy": false,
    "userns-remap": ""
}