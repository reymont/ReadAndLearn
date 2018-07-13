

* [微服务部署：蓝绿部署、滚动部署、灰度发布、金丝雀发布 - 小程故事多的博客 - CSDN博客 ](http://blog.csdn.net/u013970991/article/details/77090717)
* [Kubernetes技术分析之灰度升级 - CSDN博客 ](http://blog.csdn.net/shenshouer/article/details/49156299)
* [kubernetes/simple-rolling-update.md](https://github.com/kubernetes/kubernetes/blob/b9cfab87e33ea649bdd13a1bd243c502d76e5d22/docs/design/simple-rolling-update.md)

灰度升级（又称灰度发布、灰度更新）是指在黑与白之间，能够平滑过渡的一种发布方式。ABtest就是一种灰度发布方式，让一部用户继续用A，一部分用户开始用B，如果用户对B没有什么反对意见，那么逐步扩大范围，把所有用户都迁移到B上面来。灰度发布可以保证整体系统的稳定，在初始灰度的时候就可以发现、调整问题，以保证其影响度。

```sh
# 开始灰度升级
$ kubectl rolling-update my-web-v1 -f my-web-v2-rc.yaml --update-period=10s
# 
Updating my-web-v1 replicas: 3, my-web-v2 replicas: 1
Updating my-web-v1 replicas: 2, my-web-v2 replicas: 2
Updating my-web-v1 replicas: 1, my-web-v2 replicas: 3
Updating my-web-v1 replicas: 0, my-web-v2 replicas: 4
# 回退
$ kubectl rolling-update my-web-v1 my-web-v2 --rollback --image=my-web:v2
```