

* [以Kubeadm方式安装的Kubernetes集群的探索 ](http://ms.csdn.net/geek/135480)


# 一、环境

# 二、核心组件的Pod化

Kubeadm安装的k8s集群与kube-up.sh安装集群相比，最大的不同应该算是kubernetes核心组件的Pod化，即：kube-apiserver、kube-controller-manager、kube-scheduler、kube-proxy、kube-discovery以及etcd等核心组件都运行在集群中的Pod里的，这颇有些CoreOS的风格。只有一个组件是例外的，那就是负责在node上与本地容器引擎交互的Kubelet。

K8s的核心组件Pod均放在kube-system namespace中，通过kubectl(on master node)可以查看到：

```sh
# kubectl get pods -n kube-system
```

从上面docker inspect的输出可以看出kube-apiserver pod里面的pause容器采用的网络模式是host网络，而以pause容器网络为基础的kube-apiserver 容器显然就继承了这一network namespace。因此从外面看，访问Kube-apiserver这样的组件和以前没什么两样：在Master node上可以通过localhost:8080访问；在Node外，可以通过master_node_ip:6443端口访问。


# 三、核心组件启动配置调整

在kube-apiserver等核心组件还是以本地程序运行在物理机上的时代，修改kube-apiserver的启动参数，比如修改一下–service-node-port-range的范围、添加一个–basic-auth-file等，我们都可以通过直接修改/etc/default/kube-apiserver(以Ubuntu 14.04为例)文件的内容并重启kube-apiserver service(service restart kube-apiserver)的方式实现。其他核心组件：诸如：kube-controller-manager、kube-proxy和kube-scheduler均是如此。

但在kubeadm时代，这些配置文件不再存在，取而代之的是和用户Pod描述文件类似的manifest文件(都放置在/etc/kubernetes/manifests下面)：

```sh
/etc/kubernetes/manifests# ls
etcd.json  kube-apiserver.json  kube-controller-manager.json  kube-scheduler.json
```

我们以为kube-apiserver增加一个启动参数：”–service-node-port-range=80-32767″ 为例：

打开并编辑/etc/kubernetes/manifests/kube-apiserver.json，在“command字段对应的值中添加”–service-node-port-range=80-32767″：



kubelet自身是一个systemd的service，它的启动配置可以通过下面文件修改：

```sh
# cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true"
Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
Environment="KUBELET_DNS_ARGS=--cluster-dns=10.96.0.10 --cluster-domain=cluster.local"
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_EXTRA_ARGS
```

# 四、kubectl的配置

kube-up.sh安装的k8s集群会在每个Node上的~/.kube/下创建config文件，用于kubectl访问apiserver和操作集群使用。但在kubeadm模式下，~/.kube/下面的内容变成了：

```sh
~/.kube# ls
cache/  schema/
```

## config哪里去了

于是有了问题1：config哪里去了？

之所以在master node上我们的kubectl依旧可以工作，那是因为默认kubectl会访问localhost:8080来与kube-apiserver交互。如果kube-apiserver没有关闭–insecure-port，那么kubectl便可以正常与kube-apiserver交互，因为–insecure-port是没有任何校验机制的。


## 其他node上的kubectl与kube-apiserver通信

于是又了问题2：如果是其他node上的kubectl与kube-apiserver通信或者master node上的kubectl通过secure port与kube-apiserver通信，应该如何配置？

接下来，我们一并来回答上面两个问题。kubeadm在创建集群时，在master node的/etc/kubernetes下面创建了两个文件：

```sh
/etc/kubernetes# ls -l
total 32
-rw------- 1 root root 9188 Dec 28 17:32 admin.conf
-rw------- 1 root root 9188 Dec 28 17:32 kubelet.conf
... ...
```

这两个文件的内容是完全一样的，仅从文件名可以看出是谁在使用。比如kubelet.conf这个文件，我们就在kubelet程序的启动参数中看到过：–kubeconfig=/etc/kubernetes/kubelet.conf

```sh
# ps -ef|grep kubelet
root      1633     1  5  2016 ?        1-09:26:41 /usr/bin/kubelet --kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin --cluster-dns=10.96.0.10 --cluster-domain=cluster.local
```

打开这个文件，你会发现这就是一个kubeconfig文件，文件内容较长，我们通过kubectl config view来查看一下这个文件的结构：
```yaml
# kubectl --kubeconfig /etc/kubernetes/kubelet.conf config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: REDACTED
    server: https://{master node local ip}:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: admin
  name: admin@kubernetes
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet@kubernetes
current-context: admin@kubernetes
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
- name: kubelet
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
```
这和我们在《Kubernetes集群Dashboard插件安装》一文中介绍的kubeconfig文件内容并不二致。不同之处就是“REDACTED”这个字样的值，我们对应到kubelet.conf中，发现每个REDACTED字样对应的都是一段数据，这段数据是由对应的数字证书内容或密钥内容转换(base64)而来的，在访问apiserver时会用到。

我们在minion node上测试一下：

```sh
minion node：

# kubectl get pods
The connection to the server localhost:8080 was refused - did you specify the right host or port?

# kubectl --kubeconfig /etc/kubernetes/kubelet.conf get pods
NAME                         READY     STATUS    RESTARTS   AGE
my-nginx-1948696469-359d6    1/1       Running   2          26d
my-nginx-1948696469-3g0n7    1/1       Running   3          26d
my-nginx-1948696469-xkzsh    1/1       Running   2          26d
my-ubuntu-2560993602-5q7q5   1/1       Running   2          26d
my-ubuntu-2560993602-lrrh0   1/1       Running   2          26d
```

kubeadm创建k8s集群时，会在master node上创建一些用于组件间访问的证书、密钥和token文件，上面的kubeconfig中的“REDACTED”所代表的内容就是从这些文件转化而来的：

```sh
/etc/kubernetes/pki# ls
apiserver-key.pem  apiserver.pem  apiserver-pub.pem  ca-key.pem  ca.pem  ca-pub.pem  sa-key.pem  sa-pub.pem  tokens.csv
apiserver-key.pem：kube-apiserver的私钥文件
apiserver.pem：kube-apiserver的公钥证书
apiserver-pub.pem kube-apiserver的公钥文件
ca-key.pem：CA的私钥文件
ca.pem：CA的公钥证书
ca-pub.pem ：CA的公钥文件
sa-key.pem ：serviceaccount私钥文件
sa-pub.pem ：serviceaccount的公钥文件
tokens.csv：kube-apiserver用于校验的token文件
```
在k8s各核心组件的启动参数中会看到上面文件的身影，比如：

```sh
 kube-apiserver --insecure-bind-address=127.0.0.1 --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,PersistentVolumeLabel,DefaultStorageClass,ResourceQuota --service-cluster-ip-range=10.96.0.0/12 --service-account-key-file=/etc/kubernetes/pki/apiserver-key.pem --client-ca-file=/etc/kubernetes/pki/ca.pem --tls-cert-file=/etc/kubernetes/pki/apiserver.pem --tls-private-key-file=/etc/kubernetes/pki/apiserver-key.pem --token-auth-file=/etc/kubernetes/pki/tokens.csv --secure-port=6443 --allow-privileged --advertise-address={master node local ip} --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --anonymous-auth=false --etcd-servers=http://127.0.0.1:2379 --service-node-port-range=80-32767
```

## static token

我们还可以在minion node上通过curl还手工测试一下通过安全通道访问master node上的kube-apiserver。在《Kubernetes集群的安全配置》一文中，我们提到过k8s的authentication（包括：客户端证书认证、basic auth、static token等）只要通过其中一个即可。当前kube-apiserver开启了`客户端证书认证（–client-ca-file）和static token验证(–token-auth-file)`，我们只要通过其中一个，就可以通过authentication，于是我们使用static token方式。static token file的内容格式：

token,user,uid,"group1,group2,group3"
对应到master node上的tokens.csv
```sh
# cat /etc/kubernetes/pki/tokens.csv
{token},{user},812ffe41-cce0-11e6-9bd3-00163e1001d7,system:kubelet-bootstrap
```
我们用这个token通过curl与apiserver交互：

```json
# curl --cacert /etc/kubernetes/pki/ca.pem -H "Authorization: Bearer {token}"  https://{master node local ip}:6443
{
  "paths": [
    "/api",
    "/api/v1",
    "/apis",
    "/apis/apps",
    "/apis/apps/v1beta1",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1beta1",
    "/apis/authorization.k8s.io",
    "/apis/authorization.k8s.io/v1beta1",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/batch/v2alpha1",
    "/apis/certificates.k8s.io",
    "/apis/certificates.k8s.io/v1alpha1",
    "/apis/extensions",
    "/apis/extensions/v1beta1",
    "/apis/policy",
    "/apis/policy/v1beta1",
    "/apis/rbac.authorization.k8s.io",
    "/apis/rbac.authorization.k8s.io/v1alpha1",
    "/apis/storage.k8s.io",
    "/apis/storage.k8s.io/v1beta1",
    "/healthz",
    "/healthz/poststarthook/bootstrap-controller",
    "/healthz/poststarthook/extensions/third-party-resources",
    "/healthz/poststarthook/rbac/bootstrap-roles",
    "/logs",
    "/metrics",
    "/swaggerapi/",
    "/ui/",
    "/version"
  ]
}
```
交互成功！