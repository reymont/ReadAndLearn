
* [Kubernetes集群安全配置案例 - 暗痛 - 博客园 ](http://www.cnblogs.com/breg/p/5923604.html)

Kubernetes 系统提供了三种认证方式：CA 认证、Token 认证 和 Base 认证。安全功能是一把双刃剑，它保护系统不被攻击，但是也带来额外的性能损耗。集群内的各组件访问 API Server 时，由于它们与 API Server 同时处于同一局域网内，所以建议用非安全的方式访问 API Server 效率更高。

接下来对集群的双向认证配置和简单认证配置过程进行详细说明。

# 双向认证配置
双向认证方式是最为严格和安全的集群安全配置方式，主要配置流程如下：

生成根证书、API Server 服务端证书、服务端私钥、各个组件所用的客户端证书和客户端私钥。
修改 Kubernetes 各个服务进程的启动参数，启用双向认证模式。
详细的配置操作流程如下：

## 生成根证书

用 openssl 工具生成 CA 证书，请注意将其中 subject 等参数改为用户所需的数据，CN 的值通常是域名、主机名或 IP 地址。

$ cd /var/run/kubernetes
$ openssl genrsa -out dd_ca.key 2048
$ openssl req -x509 -new -nodes -key dd_ca.key -subj "/CN=YOUDOMAIN.COM" -days 5000 -out dd_ca.crt
生成 API Server 服务端证书和私钥

$ openssl genrsa -out dd_server.key 2048
$ HN=`hostname`
$ openssl req -new -key dd_server.key -subj "/CN=$HN" -out dd_server.csr
$ openssl x509 -req -in dd_server.csr -CA dd_ca.crt -CAkey dd_ca.key -CAcreateserial-out dd_server.crt -days 5000
生成 Controller Manager 与 Scheduler 进程共用的证书和私钥

$ openssl genrsa -out dd_cs_client.key 2048
$ openssl req -new -key dd_cs_client.key -subj "/CN=$HN" -out dd_cs_client.csr
$ openssl x509 -req -in dd_cs_client.csr －CA dd_ca.crt -CAkey dd_ca.key -CAcreateserial -out dd_cs_client.crt -days 5000
生成 Kubelet 所用的客户端证书和私钥

注意，这里假设 Kubelet 所在机器的 IP 地址为 192.168.1.129。

$ openssl genrsa -out dd_kubelet_client.key 2048
$ openssl req -new -key dd_kubelet_client.key -subj "/CN=192.168.1.129" -out dd_kubelet_client.csr
$ openssl x509 -req -in dd_kubelet_client.csr -CA dd_ca.crt -CAkey dd_ca.key -CAcreateserial -out dd_kubelet_client.crt -days 5000
修改 API Server 的启动参数

增加 CA 根证书、Server 自身证书等参数并设置安全端口为 443.

修改/etc/kubernetes/apiserver 配置文件的 KUBE_API_ARGS 参数：

KUBE_API_ARGS="--log-dir=/var/log/kubernetes --secure-port=443 --client_ca_file=/var/run/kubernetes/dd_ca.crt --tls-private-key-file=/var/run/kubernetes/dd_server.key --tls-cert-file=/var/run/kubernetes/dd_server.crt"
重启 kube-apiserver 服务：

# systemctl restart kube-apiserver
验证 API Server 的 HTTPS 服务。

$ curl https://kubernetes-master:443/api/v1/nodes --cert /var/run/kubernetes/dd_cs_client.crt --key /var/run/kubernetes/dd_cs_client.key --cacert /var/run/kubernetes/dd_ca.crt
修改 Controller Manager 的启动参数

修改/etc/kubernetes/controller-manager 配置文件

KUBE_CONTROLLER_MANAGER_ARGS="--log-dir=/var/log/kubernetes --service_account_private_key_file=/var/run/kubernetes/server.key --root-ca-file=/var/run/kubernetes/ca.crt --master=https://kubernetes-master:443 --kubeconfig=/etc/kubernetes/cmkubeconfig"
创建/etc/kubernetes/cmkubeconfig 文件，配置证书等相关参数，具体内容如下：

apiVersion: v1
kind: Config
users
- name: controllermanager
  user:
    client-certificate: /var/run/kubernetes/dd_cs_client.crt
    client-key: /var/run/kubernetes/dd_cs_client.key
clusters:
- name: local
  cluster:
    certificate-authority: /var/run/kubernetes/dd_ca.crt
contexts:
- context:
    cluster: local
    user: controllermanager
  name: my-context
current-context: my-context
重启 kube-controller-manager 服务：

# systemctl restart kube-controller-manager
配置各个节点上的 Kubelet 进程

复制 Kubelet 的证书、私钥 与 CA 根证书到所有 Node 上。

$ scp /var/run/kubernetes/dd_kubelet* root@kubernetes-minion1:/home
$ scp /var/run/kubernetes/dd_ca.* root@kubernetes-minion:/home
在每个 Node 上创建/var/lib/kubelet/kubeconfig 文件，内容如下：

apiVersion: v1
kind: Config
users:
- name: kubelet
  user:
    client-certificats: /home/dd_kubelet_client.crt
    client-key: /home/dd_kubelet_client.key
clusters:
- name: local
  cluster:
    certificate-authority: /home/dd_ca.crt
contexts:
- context:
    cluster: local
    user: kubelet
  name: my-context
current-context: my-context
修改 Kubelet 的启动参数，以修改/etc/kubernetes/kubelet 配置文件为例：

KUBELET_API_SERVER="--api_servers=https://kubernetes-master:443"
KUBELET_ARGS="--pod_infro_container_image=192.168.1.128:1180/google_containers/pause:latest --cluster_dns=10.2.0.100 --cluster_domain=cluster.local --kubeconfig=/var/lib/kubelet/kubeconfig"
重启 kubelet 服务：

# systemctl restart kubelet
配置 kube-proxy

首先，创建/var/lib/kubeproxy/proxykubeconfig 文件，内容如下：

apiVersion: v1
kind: Config
users:
- name: kubeproxy
  user:
    client-certificate: /home/dd_kubelet_client.crt
    client-key: /home/dd_kubelet_client.key
clusters:
- name: local
  cluster:
    certificate-authority: /home/dd_ca.crt
contexts:
- context:
    cluster: local
    user: kubeproxy
  name: my-context
current-context: my-context
然后，修改 kube-proxy 的启动参数，引用上述文件并指明 API Server 在安全模式下的访问地址，以修改配置文件/etc/kubenetes/proxy 为例：

KUBE_PROXY_ARGS="--kubeconfig=/var/lib/kubeproxy/proxykubeconfig --master=https://kubenetes-master:443"
重启 kube-proxy 服务：

# systemctl restart kube-proxy
至此，一个双向认证的 Kubernetes 集群环境就搭建完成了。

# 简单认证配置
除了双向认证方式，Kubernets 也提供了基于 Token 和 HTTP Base 的简单认证方式。通信方式仍然采用 HTTPS，但不使用数字证书。

采用基于 Token 和 HTTP Base 的简单认证方式时，API Server 对外暴露 HTTPS 端口，客户端提供 Token 或用户名、密码来完成认证过程。这里需要说明的一点是 Kubelet 比较特殊，它同时支持双向认证与简单认证两种模式，其他组件智能配置为双向认证或非安全模式。

API Server 基于 Token 认证的配置过程如下

建立包括用户名、密码和 UID 的文件 token_auth_file：

$ cat /root/token_auth_file
dingmingk,dingmingk,1
admin,admin,2
system,system,3
修改 API Server 的配置，采用上述文件进行安全认证

$ vi /etc/kubernetes/apiserver
KUBE_API_ARGS="--secure-port=443 --token_auth_file=/root/token_auth_file"
重启 API Server 服务

# systemctl restart kube-apiserver
用 curl 验证连接 API Server

$ curl https://kubenetes-master:443/version --header "Authorization: Bearer dingmingk" -k
{
  "major": "1",
  "minor": "0",
  "gitVersion": "v1.0.0",
  "gitCommit": "xxxHASHCODE",
  "gitTreeState": "clean"
}
API Server 基于 HTTP Base 认证的配置过程如下

创建包括用户名、密码和 UID 的文件 basic_auth_file：

$ cat /root/basic_auth_file
dingmingk,dingmingk,1
admin,admin,2
system,system,3
修改 API Server 的配置，采用上述文件进行安全认证

$ vi /etc/kubernetes/apiserver
KUBE_API_ARGS="--secure-port=443 --basic_auth_file=/root/basic_auth_file"
重启 API Server 服务

# systemctl restart kube-apiserver
用 curl 验证连接 API Server

$ curl https://kubernetes-master:443/version --basic -u dingmingk:dingmingk -k
{
  "major": "1",
  "minor": "0",
  "gitVersion": "v1.0.0",
  "gitCommit": "xxxHASHCODE",
  "gitTreeState": "clean"
}
使用 Kubelet 时则需要指定用户名和密码来访问 API Server

$ kubectl get nodes --server="https://kubernetes-master:443" --api-version="v1" --username="dingmingk" --password="dingmingk" --insecure-skip-tls-verify=true
 
kubectl config set-cluster
在kubeconfig配置文件中设置一个集群项。

摘要

在kubeconfig配置文件中设置一个集群项。 如果指定了一个已存在的名字，将合并新字段并覆盖旧字段。

kubectl config set-cluster NAME [--server=server] [--certificate-authority=path/to/certficate/authority] [--insecure-skip-tls-verify=true]
示例

# 仅设置e2e集群项中的server字段，不影响其他字段
kubectl config set-cluster e2e --server=https://1.2.3.4

# 向e2e集群项中添加认证鉴权数据
kubectl config set-cluster e2e --certificate-authority=~/.kube/e2e/kubernetes.ca.crt

# 取消dev集群项中的证书检查
kubectl config set-cluster e2e --insecure-skip-tls-verify=true
选项

      --api-version="": 设置kuebconfig配置文件中集群选项中的api-version。
      --certificate-authority="": 设置kuebconfig配置文件中集群选项中的certificate-authority路径。
      --embed-certs[=false]: 在是否则kubeconfig配置文件中嵌入客户端证书/key。
      --insecure-skip-tls-verify[=false]: 设置kuebconfig配置文件中集群选项中的insecure-skip-tls-verify开关。
      --server="": 设置kuebconfig配置文件中集群选项中的server。
继承自父命令的选项

      --alsologtostderr[=false]: 同时输出日志到标准错误控制台和文件。
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
分类: 分布式系统