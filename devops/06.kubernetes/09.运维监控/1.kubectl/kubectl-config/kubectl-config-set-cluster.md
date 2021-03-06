

## kubectl config set-cluster

* [Kubernetes（k8s）中文文档 kubectl config set-cluster_Kubernetes中文社区 ](https://www.kubernetes.org.cn/doc-52)

译者：hurf

在kubeconfig配置文件中设置一个集群项。

摘要

在kubeconfig配置文件中设置一个集群项。 如果指定了一个已存在的名字，将合并新字段并覆盖旧字段。
```conf
#kubectl config set-cluster NAME [--server=server] 
#   [--certificate-authority=path/to/certficate/authority] 
#   [--api-version=apiversion] 
#   [--insecure-skip-tls-verify=true]
#示例
# 仅设置e2e集群项中的server字段，不影响其他字段
$ kubectl config set-cluster e2e --server=https://1.2.3.4
# 向e2e集群项中添加认证鉴权数据
$ kubectl config set-cluster e2e --certificate-authority=~/.kube/e2e/kubernetes.ca.crt
# 取消dev集群项中的证书检查
$ kubectl config set-cluster e2e --insecure-skip-tls-verify=true
```

选项

```conf
      --api-version="": 设置kuebconfig配置文件中集群选项中的api-version。
      --certificate-authority="": 设置kuebconfig配置文件中集群选项中的certificate-authority路径。
      --embed-certs[=false]: kubeconfig配置文件中是否嵌入客户端证书/key。
      --insecure-skip-tls-verify=false: 设置kuebconfig配置文件中集群选项中的insecure-skip-tls-verify开关。
      --server="": 设置kuebconfig配置文件中集群选项中的server。
```
继承自父命令的选项

```conf
      --alsologtostderr[=false]: 同时输出日志到标准错误控制台和文件。
      --api-version="": 和服务端交互使用的API版本。
      --certificate-authority="": 用以进行认证授权的.cert文件路径。
      --client-certificate="": TLS使用的客户端证书路径。
      --client-key="": TLS使用的客户端密钥路径。
      --cluster="": 指定使用的kubeconfig配置文件中的集群名。
      --context="": 指定使用的kubeconfig配置文件中的环境名。
      --insecure-skip-tls-verify[=false]: 如果为true，将不会检查服务器凭证的有效性，这会导致你的HTTPS链接变得不安全。
      --kubeconfig="": 命令行请求使用的配置文件路径。
      --log-backtrace-at=:0: 当日志长度超过定义的行数时，忽略堆栈信息。
      --log-dir="": 如果不为空，将日志文件写入此目录。
      --log-flush-frequency=5s: 刷新日志的最大时间间隔。
      --logtostderr[=true]: 输出日志到标准错误控制台，不输出到文件。
      --match-server-version[=false]: 要求服务端和客户端版本匹配。
      --namespace="": 如果不为空，命令将使用此namespace。
      --password="": API Server进行简单认证使用的密码。
  -s, --server="": Kubernetes API Server的地址和端口号。
      --stderrthreshold=2: 高于此级别的日志将被输出到错误控制台。
      --token="": 认证到API Server使用的令牌。
      --user="": 指定使用的kubeconfig配置文件中的用户名。
      --username="": API Server进行简单认证使用的用户名。
      --v=0: 指定输出日志的级别。
      --vmodule=: 指定输出日志的模块，格式如下：pattern=N，使用逗号分隔。
```