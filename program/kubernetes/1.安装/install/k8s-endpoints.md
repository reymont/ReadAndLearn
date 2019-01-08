

* [Kubernetes的Endpoints - breezey - 博客园 ](http://www.cnblogs.com/breezey/p/6586962.html)

在之前的博文中，我们演示过如何通过`ceph来实现kubernetes的持久存储`，以使得像`mysql这种有状态服务可以在kubernetes中运行并保存数据`。这看起来很美妙，然而在实际的生产环境使用中，`通过分布式存储来实现的磁盘在mysql这种IO密集性应用中，性能问题会显得非常突出`。所以在实际应用中，一般不会把mysql这种应用直接放入kubernetes中管理，而是使用专用的服务器来独立部署。而像web这种无状态应用依然会运行在kubernetes当中，这个时候web服务器要连接kubernetes管理之外的数据库，有两种方式：`一是直接连接数据库所在物理服务器IP`，另一种方式就是`借助kubernetes的Endpoints直接将外部服务器映射为kubernetes内部的一个服务`。

我们来看一个简单的示例：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: plat-dev
spec:
  ports:
    - port: 3306
      protocol: TCP
      targetPort: 3306

---
apiVersion: v1
kind: Endpoints
metadata:
  name: plat-dev
subsets:
  - addresses:
      - ip: "10.5.10.109"
    ports:
      - port: 3306
```
这个示例定义了两种资源对象，分别是Service和Endpoints。`其中Service的定义并没有使用标签选择器，而在后面定义了一个与Service同名的Endpoints，以使得它们能自动关联`。

> Service和Endpoints同名关联

Endpoints的subsets中指定了需要连接的外部服务器的IP和端口。

我们可以通过kubectl get svc来进行查看：
```sh
[root@server-116 test]# kubectl get svc
NAME                CLUSTER-IP       EXTERNAL-IP   PORT(S)           AGE
plat-dev            10.254.4.76      <none>        3306/TCP          20m
```
我们可以再启动一个示例容器，在容器中执行如下操作来尝试连接外部的服务：

> plat-dev.default.svc.cluster.local

```sh
[root@server-116 test]# kubectl exec -it nginx /bin/bash
[root@nginx nginx]# nslookup plat-dev
Server:        10.254.0.100
Address:    10.254.0.100#53

Name:    plat-dev.default.svc.cluster.local
Address: 10.254.4.76

[root@nginx nginx]# mysql -uxxx -pxxx -hplat-dev
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 349446
Server version: 5.6.14 Source distribution

Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
```
 

分类: Kubernetes
标签: kubernetes, endpoints