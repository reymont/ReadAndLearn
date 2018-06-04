

https://www.kubernetes.org.cn/2321.html

Fluent Bit 和 Fluentd 一样，是 Treasure Data 资助的采集工具，二者对比如下：

Fluentd	FluentBit
范围	服务器	嵌入设备和 IoT 设备
内存	约 20 MB	约 150 KB
语言	C 和 Ruby	C
性能	高	高
依赖	以 Ruby Gem 构建，依赖一系列的 Gem	零依赖，可能有些插件会有依赖。
插件	超过三百个	目前15个左右
授权	Apache License v2.0	Apache License v2.0
从上表可以看出，Fluentd 具有众多插件，随之而来的是很好的弹性。而 Fluent Bit 则更适用于嵌入设备等资源受限的场景。另外二者并非互斥关系，Fluent Bit 提供了输出插件，可以把数据发给 Fluentd，因此他们可以在系统中作为独立服务互相协作。

Fluent Bit 也提供了 Kubernetes Filter 插件，用于将采集到的日志结合对 Kubernetes API 的查询，为日志加入 Kubernetes 的相关数据，例如 Pod 信息、容器信息、命名空间以及标签和注解等内容。

仅就此来说，Fluent Bit 是可以替代 Kubernetes 缺省推荐的 Fluentd 进行日志采集工作的，经过笔者测试，可以直接使用他替代原有的 Fluentd，使用 DaemonSet 运行，结合 Elastic Search 进行日志归集工作。

详情参见：http://fluentbit.io/documentation/0.11/filter/kubernetes.html
简单的使用如下命令就可以运行：

kubectl create -f https://raw.githubusercontent.com/fluent/fluent-bit-kubernetes-daemonset/master/fluent-bit-daemonset-elasticsearch.yaml
这一 YAML 文件中的镜像版本为 0.11，具体版本更新可以到 Docker Hub 进行查询，其中包含的缺省 elasticsearch 地址为 elasticsearch-logging，端口为 9200，如上配置如果不符，可以下载文件自行修改运行。

另外目前 RBAC 的访问控制模式已经成为缺省，在启用了 RBAC 模式的集群中，该 Pod 的运行是无法成功的，具体表现是日志中出现无法获取 Pod 元数据的信息，这是因为缺省情况下，这一 YAML 中使用的是 kube-system 中的 default Service Account，这一服务账号并不具备获取 Pod 信息的授权，要成功运行，就必须按照 RBAC 的规矩，让 Fluent Bit 的 Service Account 能够获取 Pod 信息，可以用如下方式来解决：

首先为 Fluent bit 创建专门的 Service Account：

kubectl create sa logging -n kube-system
然后为日志收集器创建角色，让该角色可以读取 Pod 信息。

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
接下来创建 ClusterRoleBinding，把新建的角色和 Service Account 绑定在一起：

kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: read-pods-global
subjects:
- kind: ServiceAccount
  name: logging
  namespace: kube-system
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
最后在 Fluent Bit 的 yaml 中加入 Service Account 的指派：

# 省略若干
spec:
  template:
    metadata:
      labels:
        k8s-app: fluent-bit-logging
        version: v1
        kubernetes.io/cluster-service: "true"
    spec:
      serviceAccountName: logging
# 省略若干
经过这一番折腾之后，Fluent Bit 就可以在开启 RBAC 的 1.6/1.7 集群上运行了。打开相应的 Kibana 页面，会看到和标配 Fluentd 一致的日志搜集结果。