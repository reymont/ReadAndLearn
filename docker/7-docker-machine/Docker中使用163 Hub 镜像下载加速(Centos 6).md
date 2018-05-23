

Docker中使用163 Hub 镜像下载加速(Centos 6)-奔跑的蜗牛-51CTO博客 
http://blog.51cto.com/441274636/1889627

在学习Docker的过程中，下载镜像速度特别慢，这是因为Docker Hub并没有在国内部署服务器或者CDN，再加上国内的网速慢等原因，镜像下载就十分耗时。为了克服跨洋网络延迟，能够快速高效地下载Docker镜像，最为有效的方式之一就是：使用 国内的Docker镜像源。下面就介绍一下使用163  镜像源来加速的办法。

添加镜像源：

vim /etc/sysconfig/docker
添加如下内容：

other_args="--registry-mirror=http://hub-mirror.c.163.com"
`OPTIONS='--registry-mirror=http://hub-mirror.c.163.com'`

docker pull registry.docker-cn.com/rancher/agent:v1.2.7
docker pull --registry-mirror=https://registry.docker-cn.com rancher/agent:v1.2.7

重启Docker服务：
$ systemctl daemon-reload
$ systemctl restart docker
测试：
$ docker search centos