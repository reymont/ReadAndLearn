

* [Linkerd + Namerd，实现Kubernetes 集群的灰度发布 - Kubernetes中文社区 - CSDN博客 ](http://blog.csdn.net/qq_34463875/article/details/54907149)
* [linkerd/linkerd: Resilient service mesh for cloud native apps ](https://github.com/linkerd/linkerd)
* [【架构】Twitter高性能RPC框架Finagle介绍 - junneyang - 博客园 ](http://www.cnblogs.com/junneyang/p/5383627.html)
* [有没有人能对twitter的finagle和国内的dubbo做个对比？ - 知乎 ](https://www.zhihu.com/question/31440152)

Kubernetes 所提供的 rolling-update 功能提供了一种渐进式的更新过程，然而其滚动过程并不容易控制，对于灰度发布的需要来说，仍稍显不足，这里介绍一种利用 Linkerd 方案进行流量切换的思路。

linkerd is a transparent proxy that adds service discovery, routing, failure handling, and visibility to modern software applications。
