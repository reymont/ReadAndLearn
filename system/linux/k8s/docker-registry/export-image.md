

# 如何从Docker Registry中导出镜像

* [如何从Docker Registry中导出镜像-DockerInfo ](http://www.dockerinfo.net/4179.html)

## 一、目录结构

* blobs存放数据文件
* repositories存放镜像描述信息
  * tags

目录大体分为两个：一个是blobs，一个是repositories。blobs中主要存放数据文件，可以看出都是经过sha256计算后的ID。repositories目录中放镜像的描述信息，记录了一个镜像有哪些layer，tag对应的manifest文件，link文件是一个文本文件，内容是一个形如“sha256:cf34a09a90b54c…”的64位ID，这个ID对应在blob中的文件其实就是这个image的manifest文件。

# Docker镜像存储/载入/移除详情

* [Docker镜像存储/载入/移除详情-DockerInfo ](http://www.dockerinfo.net/395.html)

```sh
#存出和载入镜像
#存出镜像
#如果要导出镜像到本地文件，可以使用 docker save 命令。
$ sudo docker images
$ sudo docker save -o ubuntu_14.04.tar ubuntu:14.04
# 载入镜像
# 可以使用 docker load 从导出的本地文件中再导入到本地镜像库，例如
$ sudo docker load --input ubuntu_14.04.tar
#或
$ sudo docker load < ubuntu_14.04.tar
#这将导入镜像以及其相关的元数据信息（包括标签等）。
#移除本地镜像
#如果要移除本地的镜像，可以使用 docker rmi 命令。注意 docker rm 命令是移除容器。
$ sudo docker rmi training/sinatra
#*注意：在删除镜像之前要先用 docker rm 删掉依赖于这个镜像的所有容器。
#清理所有未打过标签的本地镜像
#docker images 可以列出本地所有的镜像，其中很可能会包含有很多中间状态的未打过标签的镜像，大量占据着磁盘空间。
#使用下面的命令可以清理所有未打过标签的本地镜像
$ sudo docker rmi $(docker images -q -f "dangling=true")
#其中 -q 和 -f 是缩写, 完整的命令其实可以写着下面这样，是不是更容易理解一点？
$ sudo docker rmi $(docker images --quiet --filter "dangling=true")
```

* [Docker私有仓库 Registry中的镜像管理 - 天宇骑士 - 博客园 ](http://www.cnblogs.com/wjoyxt/p/5855405.html)

```sh
查看Registry仓库中现有的镜像：
# curl -XGET http://10.0.30.6:5000/v2/_catalog
# curl -XGET http://10.0.30.6:5000/v2/mymirrors/tags/list
新版Registry部署      
详情参考官方文档：https://docs.docker.com/registry/deploying/
# docker run -d -p 5000:5000 --restart=always --name registry -v /data/registry:/var/lib/registry  registry:2
```

## 如何删除私有 registry 中的镜像？ 

首先，在默认情况下，docker registry 是不允许删除镜像的，需要在配置config.yml中启用：vim /etc/docker/registry/config.yml

`delete: enable:true`

```yaml
version: 0.1
log:
  fields:
    service: registry
storage:
  delete:
    enable: true
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
```

使用 API GET /v2/<镜像名>/manifests/<tag> 来取得要删除的镜像:Tag所对应的 digest。

比如，要删除 house/hello:latest 镜像，那么取得 digest 的命令是：
```sh
curl --header "Accept: application/vnd.docker.distribution.manifest.v2+json" -I -X HEAD http://10.0.30.6:5000/v2/house/hello/manifests/latest 
#得到 Docker-Content-Digest: 
# sha256:3a07b4e06c73b2e3924008270c7f3c3c6e3f70d4dbb814ad8bff2697123ca33c
```

然后调用 API DELETE /v2/<镜像名>/manifests/<digest> 来删除镜像。比如：
```sh
curl -X DELETE http://192.168.99.100:5000/v2/myimage/manifests/sha256:3a07b4e06c73b2e3924008270c7f3c3c6e3f70d4dbb814ad8bff2697123ca33c
```
至此，镜像已从 registry 中标记删除，外界访问 pull 不到了。但是 registry 的本地空间并未释放，需要等待垃圾收集才会释放。而垃圾收集不可以在线进行，必须停止 registry，然后执行。比如，假设 registry 是用 Compose 运行的，那么下面命令用来垃圾收集：
```sh
docker-compose stop
docker run -it --name gc --rm --volumes-from registry_registry_1 registry:2 garbage-collect /etc/registry/config.yml
docker-compose start
#其中 registry_registry_1 可以替换为实际的 registry 的容器名，
#而 /etc/registry/config.yml 则替换为实际的 registry配置文件路径。
```

另： 显示容器名字而非ID:    docker stats $(docker ps --format='{{.Names}}')

参考资料：http://twang2218.coding.me/post/docker-2016-07-14-faq.html#ru-he-shan-chu-si-you-registry-zhong-de-jing-xiang
 