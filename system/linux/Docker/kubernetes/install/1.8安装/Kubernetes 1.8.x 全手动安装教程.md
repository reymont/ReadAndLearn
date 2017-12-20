

Kubernetes 1.8.x 全手动安装教程_Kubernetes中文社区 
https://www.kubernetes.org.cn/3096.html

ubernetes 提供了许多云端平台与操作系统的安装方式，本章将以全手动安装方式来部署，主要是学习与了解 Kubernetes 创建流程。若想要了解更多平台的部署可以参考 Picking the Right Solution来选择自己最喜欢的方式。

本次安装版本为：

Kubernetes v1.8.2
Etcd v3.2.9
Calico v2.6.2
Docker v17.10.0-ce
预先准备信息

本教程将以下列节点数与规格来进行部署 Kubernetes 集群，操作系统可采用Ubuntu 16.x与CentOS 7.x：

IP Address	Role	CPU	Memory
172.16.35.12	master1	1	2G
172.16.35.10	node1	1	2G
172.16.35.11	node2	1	2G
这边 master 为主要控制节点也是部署节点，node 为应用程序工作节点。
所有操作全部用root使用者进行，以 SRE 来说不推荐。
可以下载 Vagrantfile 来建立 Virtual box 虚拟机集群。
首先安装前要确认以下几项都已将准备完成：

所有节点彼此网络互通，并且master1 SSH 登入其他节点为 passwdless。
所有防火墙与 SELinux 已关闭。如 CentOS：
$ systemctl stop firewalld && systemctl disable firewalld
$ setenforce 0
$ vim /etc/selinux/config
SELINUX=disabled
所有节点需要设定/etc/host解析到所有主机。
...
172.16.35.10 node1
172.16.35.11 node2
172.16.35.12 master1
所有节点需要安装Docker或rtk引擎。这边采用Docker来当作容器引擎，安装方式如下：
$ curl -fsSL "https://get.docker.com/" | sh
不管是在 Ubuntu 或 CentOS 都只需要执行该指令就会自动安装最新版 Docker。
CentOS 安装完成后，需要再执行以下指令：
$ systemctl enable docker && systemctl start docker
编辑/lib/systemd/system/docker.service，在ExecStart=..上面加入：

ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
完成后，重新启动 docker 服务：
$ systemctl daemon-reload && systemctl restart docker
所有节点需要设定/etc/sysctl.d/k8s.conf的系统参数。
$ cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

$ sysctl -p /etc/sysctl.d/k8s.conf
在master1需要安装CFSSL工具，这将会用来建立 TLS certificates。
$ export CFSSL_URL="https://pkg.cfssl.org/R1.2"
$ wget "${CFSSL_URL}/cfssl_linux-amd64" -O /usr/local/bin/cfssl
$ wget "${CFSSL_URL}/cfssljson_linux-amd64" -O /usr/local/bin/cfssljson
$ chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson
Etcd

在开始安装 Kubernetes 之前，需要先将一些必要系统创建完成，其中 Etcd 就是 Kubernetes 最重要的一环，Kubernetes 会将大部分信息储存于 Etcd 上，来提供给其他节点索取，以确保整个集群运作与沟通正常。

创建集群 CA 与 Certificates

在这部分，将会需要产生 client 与 server 的各组件 certificates，并且替 Kubernetes admin user 产生 client 证书。

建立/etc/etcd/ssl文件夹，然后进入目录完成以下操作。

$ mkdir -p /etc/etcd/ssl && cd /etc/etcd/ssl
$ export PKI_URL="https://kairen.github.io/files/manual-v1.8/pki"
下载ca-config.json与etcd-ca-csr.json文件，并产生 CA 密钥：

$ wget "${PKI_URL}/ca-config.json" "${PKI_URL}/etcd-ca-csr.json"
$ cfssl gencert -initca etcd-ca-csr.json | cfssljson -bare etcd-ca
$ ls etcd-ca*.pem
etcd-ca-key.pem  etcd-ca.pem
下载etcd-csr.json文件，并产生 kube-apiserver certificate 证书：

$ wget "${PKI_URL}/etcd-csr.json"
$ cfssl gencert \
  -ca=etcd-ca.pem \
  -ca-key=etcd-ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  etcd-csr.json | cfssljson -bare etcd

$ ls etcd*.pem
etcd-ca-key.pem  etcd-ca.pem  etcd-key.pem  etcd.pe
若节点 IP 不同，需要修改etcd-csr.json的hosts。
完成后删除不必要文件：

$ rm -rf *.json
确认/etc/etcd/ssl有以下文件：

$ ls /etc/etcd/ssl
etcd-ca.csr  etcd-ca-key.pem  etcd-ca.pem  etcd.csr  etcd-key.pem  etcd.pem
Etcd 安装与设定

首先在master1节点下载 Etcd，并解压缩放到 /opt 底下与安装：

$ export ETCD_URL="https://github.com/coreos/etcd/releases/download"
$ cd && wget -qO- --show-progress "${ETCD_URL}/v3.2.9/etcd-v3.2.9-linux-amd64.tar.gz" | tar -zx
$ mv etcd-v3.2.9-linux-amd64/etcd* /usr/local/bin/ && rm -rf etcd-v3.2.9-linux-amd64
完成后新建 Etcd Group 与 User，并建立 Etcd 配置文件目录：

$ groupadd etcd && useradd -c "Etcd user" -g etcd -s /sbin/nologin -r etcd
下载etcd相关文件，我们将来管理 Etcd：

$ export ETCD_CONF_URL="https://kairen.github.io/files/manual-v1.8/master"
$ wget "${ETCD_CONF_URL}/etcd.conf" -O /etc/etcd/etcd.conf
$ wget "${ETCD_CONF_URL}/etcd.service" -O /lib/systemd/system/etcd.service
若与该教程 IP 不同的话，请用自己 IP 取代172.16.35.12。
建立 var 存放信息，然后启动 Etcd 服务:

$ mkdir -p /var/lib/etcd && chown etcd:etcd -R /var/lib/etcd /etc/etcd
$ systemctl enable etcd.service && systemctl start etcd.service
通过简单指令验证：

$ export CA="/etc/etcd/ssl"
$ ETCDCTL_API=3 etcdctl \
    --cacert=${CA}/etcd-ca.pem \
    --cert=${CA}/etcd.pem \
    --key=${CA}/etcd-key.pem \
    --endpoints="https://172.16.35.12:2379" \
    endpoint health
# output
https://172.16.35.12:2379 is healthy: successfully committed proposal: took = 641.36µs
Kubernetes Master

Master 是 Kubernetes 的大总管，主要创建apiserver、Controller manager与Scheduler来组件管理所有 Node。本步骤将下载 Kubernetes 并安装至 master1上，然后产生相关 TLS Cert 与 CA 密钥，提供给集群组件认证使用。

下载 Kubernetes 组件

首先通过网络取得所有需要的执行文件：

# Download Kubernetes
$ export KUBE_URL="https://storage.googleapis.com/kubernetes-release/release/v1.8.2/bin/linux/amd64"
$ wget "${KUBE_URL}/kubelet" -O /usr/local/bin/kubelet
$ wget "${KUBE_URL}/kubectl" -O /usr/local/bin/kubectl
$ chmod +x /usr/local/bin/kubelet /usr/local/bin/kubectl

# Download CNI
$ mkdir -p /opt/cni/bin && cd /opt/cni/bin
$ export CNI_URL="https://github.com/containernetworking/plugins/releases/download"
$ wget -qO- --show-progress "${CNI_URL}/v0.6.0/cni-plugins-amd64-v0.6.0.tgz" | tar -zx
创建集群 CA 与 Certificates

在这部分，将会需要生成 client 与 server 的各组件 certificates，并且替 Kubernetes admin user 生成 client 证书。

创建pki文件夹，然后进入目录完成以下操作。

$ mkdir -p /etc/kubernetes/pki && cd /etc/kubernetes/pki
$ export PKI_URL="https://kairen.github.io/files/manual-v1.8/pki"
$ export KUBE_APISERVER="https://172.16.35.12:6443"
下载ca-config.json与ca-csr.json文件，并生成 CA 密钥：

$ wget "${PKI_URL}/ca-config.json" "${PKI_URL}/ca-csr.json"
$ cfssl gencert -initca ca-csr.json | cfssljson -bare ca
$ ls ca*.pem
ca-key.pem  ca.pem
API server certificate

下载apiserver-csr.json文件，并生成 kube-apiserver certificate 证书：

$ wget "${PKI_URL}/apiserver-csr.json"
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=10.96.0.1,172.16.35.12,127.0.0.1,kubernetes.default \
  -profile=kubernetes \
  apiserver-csr.json | cfssljson -bare apiserver

$ ls apiserver*.pem
apiserver-key.pem  apiserver.pem
若节点 IP 不同，需要修改apiserver-csr.json的hosts。
Front proxy certificate

下载front-proxy-ca-csr.json文件，并生成 Front proxy CA 密钥，Front proxy 主要是用在 API aggregator 上:

$ wget "${PKI_URL}/front-proxy-ca-csr.json"
$ cfssl gencert \
  -initca front-proxy-ca-csr.json | cfssljson -bare front-proxy-ca

$ ls front-proxy-ca*.pem
front-proxy-ca-key.pem  front-proxy-ca.pem
下载front-proxy-client-csr.json文件，并生成 front-proxy-client 证书：

$ wget "${PKI_URL}/front-proxy-client-csr.json"
$ cfssl gencert \
  -ca=front-proxy-ca.pem \
  -ca-key=front-proxy-ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  front-proxy-client-csr.json | cfssljson -bare front-proxy-client

$ ls front-proxy-client*.pem
front-proxy-client-key.pem  front-proxy-client.pem
Bootstrap Token

由于通过手动创建 CA 方式太过繁杂，只适合少量机器，因为每次签证时都需要绑定 Node IP，随机器增加会带来很多困扰，因此这边使用 TLS Bootstrapping 方式进行授权，由 apiserver 自动给符合条件的 Node 发送证书来授权加入集群。

主要做法是 kubelet 启动时，向 kube-apiserver 传送 TLS Bootstrapping 请求，而 kube-apiserver 验证 kubelet 请求的 token 是否与设定的一样，若一样就自动产生 kubelet 证书与密钥。具体作法可以参考 TLS bootstrapping。

首先建立一个变量来产生BOOTSTRAP_TOKEN，并建立 bootstrap.conf 的 kubeconfig 文件：

$ export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
$ cat <<EOF > /etc/kubernetes/token.csv
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

# bootstrap set-cluster
$ kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=../bootstrap.conf

# bootstrap set-credentials
$ kubectl config set-credentials kubelet-bootstrap \
    --token=${BOOTSTRAP_TOKEN} \
    --kubeconfig=../bootstrap.conf

# bootstrap set-context
$ kubectl config set-context default \
    --cluster=kubernetes \
    --user=kubelet-bootstrap \
   --kubeconfig=../bootstrap.conf

# bootstrap set default context
$ kubectl config use-context default --kubeconfig=../bootstrap.conf
若想要用 CA 方式来认证，可以参考 Kubelet certificate。
Admin certificate

下载admin-csr.json文件，并生成 admin certificate 证书：

$ wget "${PKI_URL}/admin-csr.json"
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

$ ls admin*.pem
admin-key.pem  admin.pem
接着通过以下指令生成名称为 admin.conf 的 kubeconfig 文件：

# admin set-cluster
$ kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=../admin.conf

# admin set-credentials
$ kubectl config set-credentials kubernetes-admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=../admin.conf

# admin set-context
$ kubectl config set-context kubernetes-admin@kubernetes \
    --cluster=kubernetes \
    --user=kubernetes-admin \
    --kubeconfig=../admin.conf

# admin set default context
$ kubectl config use-context kubernetes-admin@kubernetes \
    --kubeconfig=../admin.conf
Controller manager certificate

下载manager-csr.json文件，并生成 kube-controller-manager certificate 证书：

$ wget "${PKI_URL}/manager-csr.json"
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  manager-csr.json | cfssljson -bare controller-manager

$ ls controller-manager*.pem
若节点 IP 不同，需要修改manager-csr.json的hosts。
接着通过以下指令生成名称为controller-manager.conf的 kubeconfig 文件：

# controller-manager set-cluster
$ kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=../controller-manager.conf

# controller-manager set-credentials
$ kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=controller-manager.pem \
    --client-key=controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=../controller-manager.conf

# controller-manager set-context
$ kubectl config set-context system:kube-controller-manager@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-controller-manager \
    --kubeconfig=../controller-manager.conf

# controller-manager set default context
$ kubectl config use-context system:kube-controller-manager@kubernetes \
    --kubeconfig=../controller-manager.conf
Scheduler certificate

下载scheduler-csr.json文件，并生成 kube-scheduler certificate 证书：

$ wget "${PKI_URL}/scheduler-csr.json"
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  scheduler-csr.json | cfssljson -bare scheduler

$ ls scheduler*.pem
scheduler-key.pem  scheduler.pem
若节点 IP 不同，需要修改scheduler-csr.json的hosts。
接着通过以下指令生成名称为 scheduler.conf 的 kubeconfig 文件：

# scheduler set-cluster
$ kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=../scheduler.conf

# scheduler set-credentials
$ kubectl config set-credentials system:kube-scheduler \
    --client-certificate=scheduler.pem \
    --client-key=scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=../scheduler.conf

# scheduler set-context
$ kubectl config set-context system:kube-scheduler@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-scheduler \
    --kubeconfig=../scheduler.conf

# scheduler set default context
$ kubectl config use-context system:kube-scheduler@kubernetes \
    --kubeconfig=../scheduler.conf
Kubelet master certificate

下载kubelet-csr.json文件，并生成 master node certificate 证书：

$ wget "${PKI_URL}/kubelet-csr.json"
$ sed -i 's/$NODE/master1/g' kubelet-csr.json
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=master1,172.16.35.12,172.16.35.12 \
  -profile=kubernetes \
  kubelet-csr.json | cfssljson -bare kubelet

$ ls kubelet*.pem
kubelet-key.pem  kubelet.pem
这边$NODE需要随节点名称不同而改变。
接着通过以下指令生成名称为 kubelet.conf 的 kubeconfig 文件：

# kubelet set-cluster
$ kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=../kubelet.conf

# kubelet set-credentials
$ kubectl config set-credentials system:node:master1 \
    --client-certificate=kubelet.pem \
    --client-key=kubelet-key.pem \
    --embed-certs=true \
    --kubeconfig=../kubelet.conf

# kubelet set-context
$ kubectl config set-context system:node:master1@kubernetes \
    --cluster=kubernetes \
    --user=system:node:master1 \
    --kubeconfig=../kubelet.conf

# kubelet set default context
$ kubectl config use-context system:node:master1@kubernetes \
    --kubeconfig=../kubelet.conf
Service account key

Service account 不是通过 CA 进行认证，因此不要通过 CA 来做 Service account key 的检查，这边建立一组 Private 与 Public 密钥提供给 Service account key 使用：

$ openssl genrsa -out sa.key 2048
$ openssl rsa -in sa.key -pubout -out sa.pub
$ ls sa.*
sa.key  sa.pub
完成后删除不必要文件：

$ rm -rf *.json *.csr
确认/etc/kubernetes与/etc/kubernetes/pki有以下文件：

$ ls /etc/kubernetes/
admin.conf  bootstrap.conf  controller-manager.conf  kubelet.conf  pki  scheduler.conf  token.csv

$ ls /etc/kubernetes/pki
admin-key.pem  apiserver-key.pem  ca-key.pem  controller-manager-key.pem  front-proxy-ca-key.pem  front-proxy-client-key.pem  kubelet-key.pem  sa.key  scheduler-key.pem
admin.pem      apiserver.pem      ca.pem      controller-manager.pem      front-proxy-ca.pem      front-proxy-client.pem      kubelet.pem      sa.pub  scheduler.pem
安装 Kubernetes 核心组件

首先下载 Kubernetes 核心组件 YAML 文件，这边我们不透过 Binary 方案来创建 Master 核心组件，而是利用 Kubernetes Static Pod 来创建，因此需下载所有核心组件的Static Pod文件到/etc/kubernetes/manifests目录：

$ export CORE_URL="https://kairen.github.io/files/manual-v1.8/master"
$ mkdir -p /etc/kubernetes/manifests && cd /etc/kubernetes/manifests
$ for FILE in apiserver manager scheduler; do
    wget "${CORE_URL}/${FILE}.yml.conf" -O ${FILE}.yml
  done
若IP与教程设定不同的话，请记得修改apiserver.yml、manager.yml、scheduler.yml。
apiserver 中的 NodeRestriction 请参考 Using Node Authorization。
生成一个用来加密 Etcd 的 Key：

$ head -c 32 /dev/urandom | base64
SUpbL4juUYyvxj3/gonV5xVEx8j769/99TSAf8YT/sQ=
在/etc/kubernetes/目录下，创建encryption.yml的加密 YAML 文件：

$ cat <<EOF > /etc/kubernetes/encryption.yml
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: SUpbL4juUYyvxj3/gonV5xVEx8j769/99TSAf8YT/sQ=
      - identity: {}
EOF
Etcd 数据加密可参考这篇 Encrypting data at rest。
在/etc/kubernetes/目录下，创建audit-policy.yml的进阶审核策略 YAML 文件：

$ cat <<EOF > /etc/kubernetes/audit-policy.yml
apiVersion: audit.k8s.io/v1beta1
kind: Policy
rules:
- level: Metadata
EOF
Audit Policy 请参考这篇 Auditing。
下载kubelet.service相关文件来管理 kubelet：

$ export KUBELET_URL="https://kairen.github.io/files/manual-v1.8/master"
$ mkdir -p /etc/systemd/system/kubelet.service.d
$ wget "${KUBELET_URL}/kubelet.service" -O /lib/systemd/system/kubelet.service
$ wget "${KUBELET_URL}/10-kubelet.conf" -O /etc/systemd/system/kubelet.service.d/10-kubelet.conf
最后创建 var 存放信息，然后启动 kubelet 服务:

$ mkdir -p /var/lib/kubelet /var/log/kubernetes
$ systemctl enable kubelet.service && systemctl start kubelet.service
完成后会需要一段时间来下载镜像文件与启动组件，可以利用该指令来查看：

$ watch netstat -ntlp
tcp        0      0 127.0.0.1:10248         0.0.0.0:*               LISTEN      23012/kubelet
tcp        0      0 127.0.0.1:10251         0.0.0.0:*               LISTEN      22305/kube-schedule
tcp        0      0 127.0.0.1:10252         0.0.0.0:*               LISTEN      22529/kube-controll
tcp6       0      0 :::6443                 :::*                    LISTEN      22956/kube-apiserve
若看到以上信息表示服务正常启动，若发生问题可以用docker cli来查看。
完成后，复制 admin kubeconfig 文件，并通过简单指令验证：

$ cp /etc/kubernetes/admin.conf ~/.kube/config
$ kubectl get cs
NAME                 STATUS    MESSAGE              ERROR
etcd-0               Healthy   {"health": "true"}
scheduler            Healthy   ok
controller-manager   Healthy   ok

$ kubectl get node
NAME      STATUS     ROLES     AGE       VERSION
master1   NotReady   master    4m        v1.8.2

$ kubectl -n kube-system get po
NAME                              READY     STATUS    RESTARTS   AGE
kube-apiserver-master1            1/1       Running   0          4m
kube-controller-manager-master1   1/1       Running   0          4m
kube-scheduler-master1            1/1       Running   0          4m
确认服务能够执行 logs 等指令：

$ kubectl -n kube-system logs -f kube-scheduler-master1
Error from server (Forbidden): Forbidden (user=kube-apiserver, verb=get, resource=nodes, subresource=proxy) ( pods/log kube-apiserver-master1)
这边会发现出现 403 Forbidden 问题，这是因为 kube-apiserver user 并没有 nodes 的资源权限，属于正常。
由于上述权限问题，我们必需创建一个 apiserver-to-kubelet-rbac.yml 来定义权限，以供我们执行 logs、exec 等指令：

$ cd /etc/kubernetes/
$ export URL="https://kairen.github.io/files/manual-v1.8/master"
$ wget "${URL}/apiserver-to-kubelet-rbac.yml.conf" -O apiserver-to-kubelet-rbac.yml
$ kubectl apply -f apiserver-to-kubelet-rbac.yml

# 測試 logs
$ kubectl -n kube-system logs -f kube-scheduler-master1
...
I1031 03:22:42.527697       1 leaderelection.go:184] successfully acquired lease kube-system/kube-scheduler
Kubernetes Node

Node 是主要执行容器实例的节点，可视为工作节点。在这步骤我们会下载 Kubernetes binary 文件，并创建 node 的 certificate 来提供给节点注册认证用。Kubernetes 使用Node Authorizer来提供Authorization mode，这种授权模式会替 Kubelet 生成 API request。

在开始前，我们先在master1将需要的 ca 与 cert 复制到 Node 节点上：

$ for NODE in node1 node2; do
    ssh ${NODE} "mkdir -p /etc/kubernetes/pki/"
    ssh ${NODE} "mkdir -p /etc/etcd/ssl"
    # Etcd ca and cert
    for FILE in etcd-ca.pem etcd.pem etcd-key.pem; do
      scp /etc/etcd/ssl/${FILE} ${NODE}:/etc/etcd/ssl/${FILE}
    done
    # Kubernetes ca and cert
    for FILE in pki/ca.pem pki/ca-key.pem bootstrap.conf; do
      scp /etc/kubernetes/${FILE} ${NODE}:/etc/kubernetes/${FILE}
    done
  done
下载 Kubernetes 组件

首先通过网络取得所有需要的执行文件：

# Download Kubernetes
$ export KUBE_URL="https://storage.googleapis.com/kubernetes-release/release/v1.8.2/bin/linux/amd64"
$ wget "${KUBE_URL}/kubelet" -O /usr/local/bin/kubelet
$ chmod +x /usr/local/bin/kubelet

# Download CNI
$ mkdir -p /opt/cni/bin && cd /opt/cni/bin
$ export CNI_URL="https://github.com/containernetworking/plugins/releases/download"
$ wget -qO- --show-progress "${CNI_URL}/v0.6.0/cni-plugins-amd64-v0.6.0.tgz" | tar -zx
设定 Kubernetes node

接着下载 Kubernetes 相关文件，包含 drop-in file、systemd service 档案等：

$ export KUBELET_URL="https://kairen.github.io/files/manual-v1.8/node"
$ mkdir -p /etc/systemd/system/kubelet.service.d
$ wget "${KUBELET_URL}/kubelet.service" -O /lib/systemd/system/kubelet.service
$ wget "${KUBELET_URL}/10-kubelet.conf" -O /etc/systemd/system/kubelet.service.d/10-kubelet.conf
接着在所有node创建 var 存放信息，然后启动 kubelet 服务:

$ mkdir -p /var/lib/kubelet /var/log/kubernetes /etc/kubernetes/manifests
$ systemctl enable kubelet.service && systemctl start kubelet.service
P.S. 重复一样动作来完成其他节点。

授权 Kubernetes Node

当所有节点都完成后，在master节点，因为我们采用 TLS Bootstrapping，所需要创建一个 ClusterRoleBinding：

$ kubectl create clusterrolebinding kubelet-bootstrap \
    --clusterrole=system:node-bootstrapper \
    --user=kubelet-bootstrap
在master通过简单指令验证，会看到节点处于pending：

$ kubectl get csr
NAME                                                   AGE       REQUESTOR           CONDITION
node-csr-YWf97ZrLCTlr2hmXsNLfjVLwaLfZRsu52FRKOYjpcBE   2s        kubelet-bootstrap   Pending
node-csr-eq4q6ffOwT4yqYQNU6sT7mphPOQdFN6yulMVZeu6pkE   2s        kubelet-bootstrap   Pending
通过 kubectl 来允许节点加入集群：

$ kubectl get csr | awk '/Pending/ {print $1}' | xargs kubectl certificate approve
certificatesigningrequest "node-csr-YWf97ZrLCTlr2hmXsNLfjVLwaLfZRsu52FRKOYjpcBE" approved
certificatesigningrequest "node-csr-eq4q6ffOwT4yqYQNU6sT7mphPOQdFN6yulMVZeu6pkE" approved

$ kubectl get csr
NAME                                                   AGE       REQUESTOR           CONDITION
node-csr-YWf97ZrLCTlr2hmXsNLfjVLwaLfZRsu52FRKOYjpcBE   30s       kubelet-bootstrap   Approved,Issued
node-csr-eq4q6ffOwT4yqYQNU6sT7mphPOQdFN6yulMVZeu6pkE   30s       kubelet-bootstrap   Approved,Issued

$ kubectl get no
NAME      STATUS     ROLES     AGE       VERSION
master1   NotReady   master    15m       v1.8.2
node1     NotReady   <none>    8m        v1.8.2
node2     NotReady   <none>    6s        v1.8.2
Kubernetes Core Addons 部署

当完成上面所有步骤后，接着我们需要安装一些插件，而这些有部分是非常重要跟好用的，如Kube-dns与Kube-proxy等。

Kube-proxy addon

Kube-proxy 是实现 Service 的关键组件，kube-proxy 会在每台节点上执行，然后监听 API Server 的 Service 与 Endpoint 资源对象的改变，然后来依据变化执行 iptables 来实现网络的转发。这边我们会需要建议一个 DaemonSet 来执行，并且创建一些需要的 certificate。Kubernetes 1.8 kube-proxy 开启 ipvs

首先在master1下载kube-proxy-csr.json文件，并产生 kube-proxy certificate 证书：

$ export PKI_URL="https://kairen.github.io/files/manual-v1.8/pki"
$ cd /etc/kubernetes/pki
$ wget "${PKI_URL}/kube-proxy-csr.json" "${PKI_URL}/ca-config.json"
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy

$ ls kube-proxy*.pem
kube-proxy-key.pem  kube-proxy.pem
接着透过以下指令生成名称为 kube-proxy.conf 的 kubeconfig 文件：

# kube-proxy set-cluster
$ kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server="https://172.16.35.12:6443" \
    --kubeconfig=../kube-proxy.conf

# kube-proxy set-credentials
$ kubectl config set-credentials system:kube-proxy \
    --client-key=kube-proxy-key.pem \
    --client-certificate=kube-proxy.pem \
    --embed-certs=true \
    --kubeconfig=../kube-proxy.conf

# kube-proxy set-context
$ kubectl config set-context system:kube-proxy@kubernetes \
    --cluster=kubernetes \
    --user=system:kube-proxy \
    --kubeconfig=../kube-proxy.conf

# kube-proxy set default context
$ kubectl config use-context system:kube-proxy@kubernetes \
    --kubeconfig=../kube-proxy.conf
完成后删除不必要文件：

$ rm -rf *.json
确认/etc/kubernetes有以下文件：

$ ls /etc/kubernetes/
admin.conf        bootstrap.conf           encryption.yml  kube-proxy.conf  pki             token.csv
audit-policy.yml  controller-manager.conf  kubelet.conf    manifests        scheduler.conf
在master1将kube-proxy相关文件复制到 Node 节点上：

$ for NODE in node1 node2; do
    for FILE in pki/kube-proxy.pem pki/kube-proxy-key.pem kube-proxy.conf; do
      scp /etc/kubernetes/${FILE} ${NODE}:/etc/kubernetes/${FILE}
    done
  done
完成后，在master1通过 kubectl 来创建 kube-proxy daemon：

$ export ADDON_URL="https://kairen.github.io/files/manual-v1.8/addon"
$ mkdir -p /etc/kubernetes/addons && cd /etc/kubernetes/addons
$ wget "${ADDON_URL}/kube-proxy.yml.conf" -O kube-proxy.yml
$ kubectl apply -f kube-proxy.yml
$ kubectl -n kube-system get po -l k8s-app=kube-proxy
NAME               READY     STATUS    RESTARTS   AGE
kube-proxy-bpp7q   1/1       Running   0          47s
kube-proxy-cztvh   1/1       Running   0          47s
kube-proxy-q7mm4   1/1       Running   0          47s
Kube-dns addon

Kube DNS 是 Kubernetes 集群内部 Pod 之间互相沟通的重要 Addon，它允许 Pod 可以通过 Domain Name 方式来连接 Service，其主要由 Kube DNS 与 Sky DNS 组合而成，通过 Kube DNS 监听 Service 与 Endpoint 变化，来提供给 Sky DNS 信息，已更新解析地址。

安装只需要在master1通过 kubectl 来创建 kube-dns deployment 即可：

$ export ADDON_URL="https://kairen.github.io/files/manual-v1.8/addon"
$ wget "${ADDON_URL}/kube-dns.yml.conf" -O kube-dns.yml
$ kubectl apply -f kube-dns.yml
$ kubectl -n kube-system get po -l k8s-app=kube-dns
NAME                        READY     STATUS    RESTARTS   AGE
kube-dns-6cb549f55f-h4zr5   0/3       Pending   0          40s
Calico Network 安装与设定

Calico 是一款纯 Layer 3 的数据中心网络方案(不需要 Overlay 网络)，Calico 好处是他已与各种云原生平台有良好的整合，而 Calico 在每一个节点利用 Linux Kernel 实现高效的 vRouter 来负责数据的转发，而当数据中心复杂度增加时，可以用 BGP route reflector 来达成。

首先在master1通过 kubectl 建立 Calico policy controller：

$ export CALICO_CONF_URL="https://kairen.github.io/files/manual-v1.8/network"
$ wget "${CALICO_CONF_URL}/calico-controller.yml.conf" -O calico-controller.yml
$ kubectl apply -f calico-controller.yml
$ kubectl -n kube-system get po -l k8s-app=calico-policy
NAME                                        READY     STATUS    RESTARTS   AGE
calico-policy-controller-5ff8b4549d-tctmm   0/1       Pending   0          5s
在master1下载 Calico CLI 工具：

$ wget https://github.com/projectcalico/calicoctl/releases/download/v1.6.1/calicoctl
$ chmod +x calicoctl && mv calicoctl /usr/local/bin/
然后在所有节点下载 Calico，并执行以下步骤：

$ export CALICO_URL="https://github.com/projectcalico/cni-plugin/releases/download/v1.11.0"
$ wget -N -P /opt/cni/bin ${CALICO_URL}/calico
$ wget -N -P /opt/cni/bin ${CALICO_URL}/calico-ipam
$ chmod +x /opt/cni/bin/calico /opt/cni/bin/calico-ipam
接着在所有节点下载 CNI plugins配置文件，以及 calico-node.service：

$ mkdir -p /etc/cni/net.d
$ export CALICO_CONF_URL="https://kairen.github.io/files/manual-v1.8/network"
$ wget "${CALICO_CONF_URL}/10-calico.conf" -O /etc/cni/net.d/10-calico.conf
$ wget "${CALICO_CONF_URL}/calico-node.service" -O /lib/systemd/system/calico-node.service
若部署的机器是使用虚拟机，如 Virtualbox 等的话，请修改calico-node.service文件，并在IP_AUTODETECTION_METHOD(包含 IP6)部分指定绑定的网卡，以避免默认绑定到 NAT 网络上。
之后在所有节点启动 Calico-node:

$ systemctl enable calico-node.service && systemctl start calico-node.service
在master1查看 Calico nodes:

$ cat <<EOF > ~/calico-rc
export ETCD_ENDPOINTS="https://172.16.35.12:2379"
export ETCD_CA_CERT_FILE="/etc/etcd/ssl/etcd-ca.pem"
export ETCD_CERT_FILE="/etc/etcd/ssl/etcd.pem"
export ETCD_KEY_FILE="/etc/etcd/ssl/etcd-key.pem"
EOF

$ . ~/calico-rc
$ calicoctl get node -o wide
NAME      ASN       IPV4              IPV6
master1   (64512)   172.16.35.12/24
node1     (64512)   172.16.35.10/24
node2     (64512)   172.16.35.11/24
查看 pending 的 pod 是否已执行：

$ kubectl -n kube-system get po
NAME                                        READY     STATUS    RESTARTS   AGE
calico-policy-controller-5ff8b4549d-tctmm   1/1       Running   0          4m
kube-apiserver-master1                      1/1       Running   0          20m
kube-controller-manager-master1             1/1       Running   0          20m
kube-dns-6cb549f55f-h4zr5                   3/3       Running   0          5m
kube-proxy-fnrkb                            1/1       Running   0          6m
kube-proxy-l72bq                            1/1       Running   0          6m
kube-proxy-m6rfw                            1/1       Running   0          6m
kube-scheduler-master1                      1/1       Running   0          20m
最后若想省事，可以直接用 Standard Hosted 方式安装。

Kubernetes Extra Addons 部署

本节说明如何部署一些官方常用的 Addons，如 Dashboard、Heapster 等。

Dashboard addon

Dashboard 是 Kubernetes 社区官方开发的仪表板，有了仪表板后管理者就能够透过 Web-based 方式来管理 Kubernetes 集群，除了提升管理方便，也让资源可视化，让人更直觉看见系统信息的呈现结果。

首先我们要建立kubernetes-dashboard-certs，来提供给 Dashboard TLS 使用：

$ mkdir -p /etc/kubernetes/addons/certs && cd /etc/kubernetes/addons
$ openssl genrsa -des3 -passout pass:x -out certs/dashboard.pass.key 2048
$ openssl rsa -passin pass:x -in certs/dashboard.pass.key -out certs/dashboard.key
$ openssl req -new -key certs/dashboard.key -out certs/dashboard.csr -subj '/CN=kube-dashboard'
$ openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
$ rm certs/dashboard.pass.key
$ kubectl create secret generic kubernetes-dashboard-certs\
    --from-file=certs -n kube-system
接着在master1通过 kubectl 来建立 kubernetes dashboard 即可：

$ export ADDON_URL="https://kairen.github.io/files/manual-v1.8/addon"
$ wget ${ADDON_URL}/kube-dashboard.yml.conf -O kube-dashboard.yml
$ kubectl apply -f kube-dashboard.yml
$ kubectl -n kube-system get po,svc -l k8s-app=kubernetes-dashboard
NAME                                      READY     STATUS    RESTARTS   AGE
po/kubernetes-dashboard-747c4f7cf-md5m8   1/1       Running   0          56s

NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
svc/kubernetes-dashboard   ClusterIP   10.98.120.209   <none>        443/TCP   56s
P.S. 这边会额外创建一个名称为anonymous-open-door Cluster Role Binding，这仅作为方便测试时使用，在一般情况下不要开启，不然就会直接被存取所有 API。
完成后，就可以透过浏览器访问 Dashboard，https://172.16.35.12:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

Heapster addon

Heapster 是 Kubernetes 社区维护的容器集群监控分析工具。Heapster 会从 Kubernetes apiserver 获得所有 Node 信息，然后再通过这些 Node 来获得 kubelet 上的数据，最后再将所有收集到数据送到 Heapster 的后台储存 InfluxDB，最后利用 Grafana 来抓取 InfluxDB 的数据源来进行可视化。

在master1通过 kubectl 来创建 kubernetes monitor 即可：

$ export ADDON_URL="https://kairen.github.io/files/manual-v1.8/addon"
$ wget ${ADDON_URL}/kube-monitor.yml.conf -O kube-monitor.yml
$ kubectl apply -f kube-monitor.yml
$ kubectl -n kube-system get po,svc
NAME                                           READY     STATUS    RESTARTS   AGE
...
po/heapster-74fb5c8cdc-62xzc                   4/4       Running   0          7m
po/influxdb-grafana-55bd7df44-nw4nc            2/2       Running   0          7m

NAME                       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
...
svc/heapster               ClusterIP   10.100.242.225   <none>        80/TCP              7m
svc/monitoring-grafana     ClusterIP   10.101.106.180   <none>        80/TCP              7m
svc/monitoring-influxdb    ClusterIP   10.109.245.142   <none>        8083/TCP,8086/TCP   7m
···
完成后，就可以透过浏览器存取 Grafana Dashboard，https://172.16.35.12:6443/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana

简单部署 Nginx 服务

Kubernetes 可以选择使用指令直接创建应用程序与服务，或者撰写 YAML 与 JSON 档案来描述部署应用程序的配置，以下将创建一个简单的 Nginx 服务：

$ kubectl run nginx --image=nginx --port=80
$ kubectl expose deploy nginx --port=80 --type=LoadBalancer --external-ip=172.16.35.12
$ kubectl get svc,po
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)        AGE
svc/kubernetes   ClusterIP      10.96.0.1       <none>         443/TCP        1h
svc/nginx        LoadBalancer   10.97.121.243   172.16.35.12   80:30344/TCP   22s

NAME                        READY     STATUS    RESTARTS   AGE
po/nginx-7cbc4b4d9c-7796l   1/1       Running   0          28s       192.160.57.181   ,172.16.35.12   80:32054/TCP   21s
这边type可以选择 NodePort 与 LoadBalancer，在本地裸机部署，两者差异在于NodePort只映射 Host port 到 Container port，而LoadBalancer则继承NodePort额外多出映射 Host target port 到 Container port。
确认没问题后即可在浏览器存取 http://172.16.35.12

扩展服务数量

若集群node节点增加了，而想让 Nginx 服务提供可靠性的话，可以通过以下方式来扩展服务的副本：

$ kubectl scale deploy nginx --replicas=2

$ kubectl get pods -o wide
NAME                    READY     STATUS    RESTARTS   AGE       IP             NODE
nginx-158599303-0h9lr   1/1       Running   0          25s       10.244.100.5   node2
nginx-158599303-k7cbt   1/1       Running   0          1m        10.244.24.3    node1