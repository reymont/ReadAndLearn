

* [Docker 清理命令 - yexiaoxiaobai - SegmentFault ](https://segmentfault.com/a/1190000000714347)

Docker的镜像以及一些数据都是在**/var/lib/docker**目录下，它占用的是Linux的系统分区

```sh
#杀死所有正在运行的容器
docker kill $(docker ps -a -q)
#删除所有已经停止的容器
docker rm $(docker ps -a -q)
#删除所有未打 dangling 标签的镜像
docker rmi $(docker images -q -f dangling=true)
#删除所有镜像
docker rmi $(docker images -q)
#为这些命令创建别名
# ~/.bash_aliases
# 杀死所有正在运行的容器.
alias dockerkill='docker kill $(docker ps -a -q)'
# 删除所有已经停止的容器.
alias dockercleanc='docker rm $(docker ps -a -q)'
# 删除所有未打标签的镜像.
alias dockercleani='docker rmi $(docker images -q -f dangling=true)'
# 删除所有已经停止的容器和未打标签的镜像.
alias dockerclean='dockercleanc || true && dockercleani'
```
