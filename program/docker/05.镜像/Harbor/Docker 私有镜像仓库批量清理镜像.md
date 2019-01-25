

Docker Registry 私有镜像仓库批量清理镜像 - CSDN博客 
http://blog.csdn.net/upcye/article/details/78186135

前言

在频繁长期使用镜像仓库后，由于镜像仓库清理镜像比较费劲，业内也没有一个比较好的清理方案，官方提供的镜像仓库清理也比较费劲，导致 Docker 镜像仓库越积越大，严重消耗磁盘空间。基于该现状，推荐如下方案。

环境

镜像仓库管理使用：Harbor（https://github.com/vmware/harbor），目前业内基本上都是使用 Harbor 作为镜像仓库管理。

Harbor 提供了 restful api，包括：删除镜像 tag、删除 repositories，以及查找 repositories，tag 等 api。具体请查看官方文档。



方案

镜像命名规则

首先需要制定一个规范的镜像命名规则，如：


这样做的好处是能够方便的做到批量删除镜像。比如想删除 xxx/deploy/app/daily 下的镜像，就比较方便。

使用 Harbor api

1、如果想删除 xxx/deploy/app 下的所有镜像。则只需要调用 harbor api
1）GET /api/repositories （该 api 有个 filter 参数，可以匹配 xxx/deploy/app/daily 下的所有 repositories
2）遍历上一步拿到的 repositories， DELETE  /api/repositories/repoName
这样就删除了 xxx/deploy/app/daily 的所有镜像

2、如果想删除指定 tag，道理也一样。可以通过 harbor 的 api 拿到 所有的 tag。

3、虽然调用 harbor 的 api 删除了 ，但是实际上并没有删除，只是删除了 Registry 的索引。实际文件并没有删除。
      最后还需要执行镜像的垃圾回收： registry garbage-collect /etc/docker/registry/config.yml


总结

本文提供了一个批量清理镜像仓库的思路，使用 harbor api。