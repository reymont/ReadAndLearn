docker中批量删除 tag为none的镜像 - CSDN博客 http://blog.csdn.net/kaifeng86/article/details/73238186

docker images -a |grep none|awk '{print $3}'|xargs docker rmi
docker images -a |grep none|awk '{print $3}'|xargs docker rmi -f --no-prune

先删除容器再删除镜像