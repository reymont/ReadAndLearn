

# https://www.kubernetes.org.cn/3336.html

2017-12-18 16:41 小刚 分类：Kubernetes安装说明 / Kubernetes教程/入门教程 阅读(465)	评论(0) 
本版本用kube-router组件取代kube-proxy,用lvs做svc负载均衡，更快稳定。
用coredns取代kube-dns，更稳定。
经过测试1.9版，消除了以往的 kubelet docker 狂报错误日志的错误 ，更完美。
节点构造如下 :

节点ip	节点角色	hostname
192.168.0.57	node	bigdata3
192.168.0.56	node	bigdata4
192.168.0.58	node	bigdata5
192.168.0.48	master01	ingest01
192.168.0.49	master02	ingest02
192.168.0.50	master03	ingest03
192.168.0.38	etcd01	etcd01
192.168.0.39	etcd02	etcd02
192.168.0.40	etcd03	etcd03
集群网络结构：

网络名称	网络范围
集群网络	172.20.0.0/16
svc网络	172.21.0.0/16
物理网络	192.168.0.0/24
组件配置：

系统	参数
系统	centos7
内核版本	4.4
docker-data数据盘	ext4
docker	1.126
Storage	Driver: overlay2
Backing	Filesystem: extfs
Logging	Driver: journald
Cgroup	Driver: systemd
一、所有节点升级内核，安装Docker 1.126

1.1 升级内核

rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm ;yum --enablerepo=elrepo-kernel install  kernel-lt-devel kernel-lt -y

#查看默认启动顺序
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg  

CentOS Linux (4.4.4-1.el7.elrepo.x86_64) 7 (Core)  
CentOS Linux (3.10.0-327.10.1.el7.x86_64) 7 (Core)  
CentOS Linux (0-rescue-c52097a1078c403da03b8eddeac5080b) 7 (Core)

#默认启动的顺序是从0开始，新内核是从头插入（目前位置在0，而4.4.4的是在1），所以需要选择0。

grub2-set-default 0  

#重启
reboot

#检查内核，成功升级到4.4
uname -a
Linux bigdata5 4.4.104-1.el7.elrepo.x86_64 #1 SMP Tue Dec 5 12:46:32 EST 2017 x86_64 x86_64 x86_64 GNU/Linux
1.2 所有节点安装Docker, 修改文件系统为ovelay2驱动

#安装docker
yum install docker-common-1.12.6 docker-client-1.12.6 docker-1.12.6-61 -y

#设置文件系统为ovelay2驱动
 cat /etc/docker/daemon.json
{
  "storage-driver": "overlay2"
}
1.3 所有节点安装ipvsadm

yum install ipvsadm -y
二、准备 k8s-node、master、etcd、flanneld二进制文件

####注意所有的文件由master ingest01这台机下发，配置ssh信任所有机器
####下载目录为/root/
[root@ingest01 ~]# pwd
/root

wget https://dl.k8s.io/v1.9.0/kubernetes-server-linux-amd64.tar.gz

wget https://github.com/coreos/etcd/releases/download/v3.2.11/etcd-v3.2.11-linux-amd64.tar.gz

wget https://github.com/coreos/flannel/releases/download/v0.9.0/flannel-v0.9.0-linux-amd64.tar.gz
三、下发所有二进制文件

3.1 解压

tar xvf kubernetes-server-linux-amd64.tar.gz && tar xvf etcd-v3.2.11-linux-amd64.tar.gz && tar xvf flannel-v0.9.0-linux-amd64.tar.gz
3.2 创建node，master ,etcd所需的二进制目录并进行归类

mkdir -p  /root/kubernetes/server/bin/{node,master,etcd}
mv /root/kubernetes/server/bin/kubelet /root/kubernetes/server/bin/node/
mv /root/mk-docker-opts.sh /root/kubernetes/server/bin/node/
mv /root/flanneld /root/kubernetes/server/bin/node/

mv /root/kubernetes/server/bin/kube-* /root/kubernetes/server/bin/master/
mv /root/kubernetes/server/bin/kubelet /root/kubernetes/server/bin/master/
mv /root/kubernetes/server/bin/kubectl /root/kubernetes/server/bin/master/

mv /root/etcd-v3.2.4-linux-amd64/etcd* /root/kubernetes/server/bin/etcd/
3.3 下发node以及flanneld二进制文件

for node in bigdata3 bigdata4 bigdata5 ingest01;do
    rsync  -avzP   /root/kubernetes/server/bin/node/ ${node}:/usr/local/bin/
done
3.4 下发master 二进制文件

for master in ingest01 ingets01 ingest03;do
    rsync  -avzP   /root/kubernetes/server/bin/master/ ${master}:/usr/local/bin/
done
3.5 下发etcd文件

for etcd in etcd01 etcd02 etcd03;do
    rsync  -avzP   /root/kubernetes/server/bin/etcd/ ${etcd}:/usr/local/bin/
done
四、创建集群systemctl 启动服务service文件

4.1 创建服务归类文件夹

mkdir -p  /root/kubernetes/server/bin/{node-service,master-service,etcd-service,docker-service,ssl}
4.2 创建node 所需的文件

#docker.service
cat >/root/kubernetes/server/bin/node-service/docker.service  <<'HERE'
[Unit]
Description=Docker Application Container Engine
Documentation=http://docs.docker.com
After=network.target
Wants=docker-storage-setup.service
Requires=docker-cleanup.timer

[Service]
Type=notify
NotifyAccess=all
KillMode=process
EnvironmentFile=-/etc/sysconfig/docker
EnvironmentFile=-/etc/sysconfig/docker-storage
EnvironmentFile=-/etc/sysconfig/docker-network
EnvironmentFile=/run/flannel/docker
Environment=GOTRACEBACK=crash
Environment=DOCKER_HTTP_HOST_COMPAT=1
Environment=PATH=/usr/libexec/docker:/usr/bin:/usr/sbin
ExecStart=/usr/bin/dockerd-current  $DOCKER_NETWORK_OPTIONS \
          --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current \
          --default-runtime=docker-runc \
          --exec-opt native.cgroupdriver=systemd \
          --userland-proxy-path=/usr/libexec/docker/docker-proxy-current \
          $OPTIONS \
          $DOCKER_STORAGE_OPTIONS \
          $DOCKER_NETWORK_OPTIONS \
          $ADD_REGISTRY \
          $BLOCK_REGISTRY \
          $INSECURE_REGISTRY
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity
TimeoutStartSec=0
Restart=on-abnormal
MountFlags=slave

[Install]
WantedBy=multi-user.target
HERE


----------


#kubeliet.service
cat >/root/kubernetes/server/bin/node-service/kubelet.service  <<'HERE'
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service
[Service]
WorkingDirectory=/var/lib/kubelet
ExecStart=/usr/local/bin/kubelet \
--address=192.168.0.48 \
--hostname-override=ingest01 \
--pod-infra-container-image=k8s-registry.local/public/pod-infrastructure:sfv1 \
--experimental-bootstrap-kubeconfig=/etc/kubernetes/ssl/bootstrap.kubeconfig \
--kubeconfig=/etc/kubernetes/ssl/kubelet.kubeconfig \
--cert-dir=/etc/kubernetes/ssl \
--hairpin-mode promiscuous-bridge \
--allow-privileged=true \
--serialize-image-pulls=false \
--logtostderr=true \
--cgroup-driver=systemd \
--cluster_dns=172.21.0.2 \
--cluster_domain=cluster.local \
--v=2
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target

HERE


----------


#flanneld.service

cat >/root/kubernetes/server/bin/node-service/flanneld.service  <<'HERE'
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service
[Service]
Type=notify
ExecStart=/usr/local/bin/flanneld \
-etcd-cafile=/etc/kubernetes/ssl/k8s-root-ca.pem \
-etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem \
-etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem \
-etcd-endpoints=https://192.168.0.38:2379,https://192.168.0.39:2379,https://192.168.0.40:2379 \
-etcd-prefix=/kubernetes/network \
-iface=eth0
ExecStartPost=/usr/local/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure
[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
HERE
4.3 创建master 所需service文件

#kube-apiserver.service
cat >/root/kubernetes/server/bin/master-service/kube-apiserver.service  <<'HERE'
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
[Service]
ExecStart=/usr/local/bin/kube-apiserver \
--admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota,NodeRestriction \
--advertise-address=192.168.0.48 \
--bind-address=192.168.0.48 \
--insecure-bind-address=127.0.0.1 \
--kubelet-https=true \
--runtime-config=rbac.authorization.k8s.io/v1beta1 \
--authorization-mode=RBAC,Node \
--enable-bootstrap-token-auth \
--token-auth-file=/etc/kubernetes/ssl/token.csv \
--service-cluster-ip-range=172.21.0.0/16 \
--service-node-port-range=300-9000 \
--tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem \
--tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
--client-ca-file=/etc/kubernetes/ssl/k8s-root-ca.pem \
--service-account-key-file=/etc/kubernetes/ssl/k8s-root-ca-key.pem \
--etcd-cafile=/etc/kubernetes/ssl/k8s-root-ca.pem \
--etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem \
--etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem \
--etcd-servers=https://192.168.0.38:2379,https://192.168.0.39:2379,https://192.168.0.40:2379 \
--enable-swagger-ui=true \
--allow-privileged=true \
--apiserver-count=3 \
--audit-log-maxage=30 \
--audit-log-maxbackup=3 \
--audit-log-maxsize=100 \
--audit-log-path=/var/lib/audit.log \
--event-ttl=1h \
--v=2
Restart=on-failure
RestartSec=5
Type=notify
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target

HERE


----------


#kube-controller-manager.service
cat >/root/kubernetes/server/bin/master-service/kube-controller-manager.service  <<'HERE'
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
[Service]
ExecStart=/usr/local/bin/kube-controller-manager \
--address=127.0.0.1 \
--master=http://127.0.0.1:8080 \
--allocate-node-cidrs=true \
--service-cluster-ip-range=172.21.0.0/16 \
--cluster-cidr=172.20.0.0/16 \
--cluster-name=kubernetes \
--cluster-signing-cert-file=/etc/kubernetes/ssl/k8s-root-ca.pem \
--cluster-signing-key-file=/etc/kubernetes/ssl/k8s-root-ca-key.pem \
--service-account-private-key-file=/etc/kubernetes/ssl/k8s-root-ca-key.pem \
--root-ca-file=/etc/kubernetes/ssl/k8s-root-ca.pem \
--leader-elect=true \
--v=2
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
HERE


----------


#kube-scheduler.service

cat >/root/kubernetes/server/bin/master-service/scheduler.service  <<'HERE'
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
[Service]
ExecStart=/usr/local/bin/kube-scheduler \
--address=127.0.0.1 \
--master=http://127.0.0.1:8080 \
--leader-elect=true \
--v=2
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
HERE
4.4 创建etcd所需service文件
etcd 各节点请自行参照此配置进行更改

cat >/root/kubernetes/server/bin/etcd-service/etcd.service  <<'HERE'
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos
[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/local/bin/etcd \
--name=etcd01 \
--cert-file=/etc/kubernetes/ssl/kubernetes.pem \
--key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
--peer-cert-file=/etc/kubernetes/ssl/kubernetes.pem \
--peer-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
--trusted-ca-file=/etc/kubernetes/ssl/k8s-root-ca.pem \
--peer-trusted-ca-file=/etc/kubernetes/ssl/k8s-root-ca.pem \
--initial-advertise-peer-urls=https://192.168.0.38:2380 \
--listen-peer-urls=https://192.168.0.38:2380 \
--listen-client-urls=https://192.168.0.38:2379,http://127.0.0.1:2379 \
--advertise-client-urls=https://192.168.0.38:2379 \
--initial-cluster-token=etcd-cluster-0 \
--initial-cluster=etcd01=https://192.168.0.38:2380,etcd02=https://192.168.0.39:2380,etcd03=https://192.168.0.40:2380 \
--initial-cluster-state=new \
--data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
HERE
五、下发service文件

5.1 下发node所需的service文件

#注意更改service文件中的主机名和ip,每个节点不一样
for node in {bigdata3,bigdata4,bigdata5,ingest01,ingest02,ingest03};do
    rsync  -avzP   /root/kubernetes/server/bin/node-service/ ${node}:/lib/systemd/system/
done
5.2 下发master所需的service文件

#注意更改service文件中的主机名和ip,每个节点不一样
for master in {ingest01,ingest02,ingest03};do
    rsync  -avzP   /root/kubernetes/server/bin/master-service/ ${master}:/lib/systemd/system/
done
5.3 下发etcd所需的service文件

#注意更改service文件中的主机名和ip,每个节点不一样
for master in {etcd01,etcd02,etcd03};do
    rsync  -avzP   /root/kubernetes/server/bin/etcd-service/ ${etcd}:/lib/systemd/system/
done
六、创建集群认证证书文件,下发文件

6.1 生成文件

#安装 CFSSL

#直接使用二进制源码包安装

wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /usr/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo

export PATH=/usr/local/bin:$PATH


----------


**#admin-csr.json**
cat >/root/kubernetes/server/bin/ssl/admin-csr.json  <<'HERE'
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shenzhen",
      "L": "Shenzhen",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
HERE


----------
#k8s-gencert.json
cat >/root/kubernetes/server/bin/ssl/k8s-gencert.json  <<'HERE'
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
HERE


----------
#k8s-root-ca-csr.json
cat >/root/kubernetes/server/bin/ssl/k8s-root-ca-csr.json  <<'HERE'
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 4096
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shenzhen",
      "L": "Shenzhen",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
HERE


----------

#kube-proxy-csr.json
cat >/root/kubernetes/server/bin/ssl/kube-proxy-csr.json  <<'HERE'
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "Shenzhen",
      "L": "Shenzhen",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
HERE


----------
#注意，此处需要将dns首ip、etcd、k8s-master节点的ip都填上
cat >/root/kubernetes/server/bin/ssl/kubernetes-csr.json  <<'HERE'
{
    "CN": "kubernetes",
    "hosts": [
    "127.0.0.1",
    "192.168.0.56",
    "192.168.0.57",
    "192.168.0.58",
    "192.168.0.38",
    "192.168.0.39",
    "192.168.0.40",
    "192.168.0.48",
    "192.168.0.49",
    "192.168.0.50",
    "172.21.0.1",
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local"
     ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "Shenzhen",
            "L": "Shenzhen",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
HERE


----------
6.2 生成通用证书以及kubeconfig

#进入ssl目录
cd /root/kubernetes/server/bin/ssl/
# 生成证书
cfssl gencert --initca=true k8s-root-ca-csr.json | cfssljson --bare k8s-root-ca

for targetName in kubernetes admin kube-proxy; do
    cfssl gencert --ca k8s-root-ca.pem --ca-key k8s-root-ca-key.pem --config k8s-gencert.json --profile kubernetes $targetName-csr.json | cfssljson --bare $targetName
done

# 生成配置
#注意，此处定义api-server的服务ip，此处用HA模式，如果你的master是单节点，请配置成单个api6443的ip即可
#注意关于三台master节点HA高可用请参见我另一篇HA实战
#地址：http://blog.csdn.net/idea77/article/details/71508859

export KUBE_APISERVER="https://127.0.0.1:6443"
export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
echo "Tokne: ${BOOTSTRAP_TOKEN}"

cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF



----------

echo "Create kubelet bootstrapping kubeconfig..."
kubectl config set-cluster kubernetes \
  --certificate-authority=k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig


----------


echo "Create kube-proxy kubeconfig..."
kubectl config set-cluster kubernetes \
  --certificate-authority=k8s-root-ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig



----------


kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig



----------


kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


----------


# 生成高级审计配置
cat >> audit-policy.yaml <<EOF
# Log all requests at the Metadata level.
apiVersion: audit.k8s.io/v1beta1
kind: Policy
rules:
- level: Metadata
EOF


----------


# 生成集群管理员admin kubeconfig配置文件供kubectl调用
# admin set-cluster
 kubectl config set-cluster kubernetes \
    --certificate-authority=k8s-root-ca.pem\
    --embed-certs=true \
    --server=${KUBE_APISERVER} \
    --kubeconfig=./kubeconfig

# admin set-credentials
 kubectl config set-credentials kubernetes-admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=./kubeconfig

# admin set-context
 kubectl config set-context kubernetes-admin@kubernetes \
    --cluster=kubernetes \
    --user=kubernetes-admin \
    --kubeconfig=./kubeconfig

# admin set default context
 kubectl config use-context kubernetes-admin@kubernetes \
    --kubeconfig=./kubeconfig

6.3 下发证书文件至所有节点

#创建ssl文件夹
for node in {bigdata3,bigdata4,bigdata5,ingest01,ingest02,ingest03,etcd01,etcd02,etcd03};do
    ssh ${node} "mkdir -p /etc/kubernetes/ssl/ "
done


----------

#下发文件
for ssl in {bigdata3,bigdata4,bigdata5,ingest01,ingest02,ingest03,etcd01,etcd02,etcd03};do
    rsync  -avzP   /root/kubernetes/server/bin/ssl/  ${ssl}:/etc/kubernetes/ssl/
done

----------

#创建master /root/.kube 目录,复制超级admin授权config
for master in {ingest01,ingest02,ingest03};do
    ssh ${master} "mkdir -p /root/.kube ; \cp -f /etc/kubernetes/ssl/kubeconfig  /root/.kube/config "
done


----------


七、启动所有节点服务，验证服务

注意启动之前确认配置文件修改无误

7.1 启动 etcd 节点服务

#启动etcd集群

for node in {etcd01,etcd02,etcd03};do
    ssh ${node} "systemctl daemon-reload && systemctl start etcd && systemctl enable etcd"
done


----------


#检查集群健康
 etcdctl \
  --ca-file=/etc/kubernetes/ssl/k8s-root-ca.pem\
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  cluster-health


----------
#设置集群网络范围

  etcdctl --endpoints=https://192.168.0.38:2379,https://192.168.0.39:2379,https://192.168.0.40:2379 \
  --ca-file=/etc/kubernetes/ssl/k8s-root-ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mkdir /kubernetes/network


----------


etcdctl --endpoints=https://192.168.0.38:2379,https://192.168.0.39:2379,https://192.168.0.40:2379 \
  --ca-file=/etc/kubernetes/ssl/k8s-root-ca.pem\
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mk /kubernetes/network/config '{ "Network": "172.20.0.0/16", "Backend": { "Type": "vxlan", "VNI": 1 }}'

----------
7.2 启动master节点服务

#注意关于三台master节点HA高可用请参见我另一篇HA实战
#地址：http://blog.csdn.net/idea77/article/details/71508859

for master in {ingest01,ingest02,ingest03};do
    ssh ${master} "systemctl daemon-reload && systemctl start flanneld docker kube-apiserver kube-controller-manager kube-scheduler kubelet && systemctl enable flanneld docker kube-apiserver kube-controller-manager kube-scheduler kubelet "
done
7.3 启动node节点服务

for node in {bigdata3,bigdata4,bigdata5};do
    ssh ${node} "systemctl daemon-reload && systemctl start flanneld docker kubelet && systemctl enable flanneld docker kubelet "
done
7.4 验证集群

# 在master机器上执行，授权kubelet-bootstrap角色
kubectl create clusterrolebinding kubelet-bootstrap \
  --clusterrole=system:node-bootstrapper \
  --user=kubelet-bootstrap

#通过所有集群认证
kubectl get csr

kubectl get csr | awk '/Pending/ {print $1}' | xargs kubectl certificate approve

#检查node Ready
kubectl  get nodes 
NAME       STATUS    ROLES     AGE       VERSION
bigdata3   Ready     <none>    4d        v1.9.0
bigdata4   Ready     <none>    4d        v1.9.0
bigdata5   Ready     <none>    4d        v1.9.0
ingest01   Ready     <none>    4d        v1.9.0
ingest02   Ready     <none>    4d        v1.9.0
ingest03   Ready     <none>    4d        v1.9.0
八、布署kube-router-ipvs取代kube-proxy、kube-dashboard、core-dns取代kube-dns

8.1 布署kube-router组件

#镜相下载：docker.io/cloudnativelabs/kube-router:latest
apiVersion: v1
kind: ConfigMap
metadata:
  name: kube-router-cfg
  namespace: kube-system
  labels:
    tier: node
    k8s-app: kube-router
data:
  cni-conf.json: |
    {
      "name":"kubernetes",
      "type":"bridge",
      "bridge":"kube-bridge",
      "isDefaultGateway":true,
      "ipam": {
        "type":"host-local"
      }
    }
---
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  labels:
    k8s-app: kube-router
    tier: node
  name: kube-router
  namespace: kube-system
spec:
  template:
    metadata:
      labels:
        k8s-app: kube-router
        tier: node
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      serviceAccountName: kube-router
      serviceAccount: kube-router
      containers:
      - name: kube-router
        image: k8s-registry.local/public/kube-router:latest
        imagePullPolicy: Always
        args:
        - --run-router=true
        - --run-firewall=true
        - --run-service-proxy=true
        - --kubeconfig=/var/lib/kube-router/kubeconfig
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        resources:
          requests:
            cpu: 250m
            memory: 250Mi
        securityContext:
          privileged: true
        volumeMounts:
        - name: lib-modules
          mountPath: /lib/modules
          readOnly: true
        - name: cni-conf-dir
          mountPath: /etc/cni/net.d
        - name: kubeconfig
          mountPath: /var/lib/kube-router/kubeconfig
        - name: run
          mountPath: /var/run/docker.sock
          readOnly: true
      initContainers:
      - name: install-cni
        image: k8s-registry.local/public/busybox:latest
        imagePullPolicy: Always
        command:
        - /bin/sh
        - -c
        - set -e -x;
          if [ ! -f /etc/cni/net.d/10-kuberouter.conf ]; then
            TMP=/etc/cni/net.d/.tmp-kuberouter-cfg;
            cp /etc/kube-router/cni-conf.json ${TMP};
            mv ${TMP} /etc/cni/net.d/10-kuberouter.conf;
          fi
        volumeMounts:
        - name: cni-conf-dir
          mountPath: /etc/cni/net.d
        - name: kube-router-cfg
          mountPath: /etc/kube-router
      hostNetwork: true
      hostIPC: true
      hostPID: true
      tolerations:
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoSchedule
        key: node-role.kubernetes.io/master
        operator: Exists
      volumes:
      - name: lib-modules
        hostPath:
          path: /lib/modules
      - name: cni-conf-dir
        hostPath:
          path: /etc/cni/net.d
      - name: run
        hostPath:
          path: /var/run/docker.sock
      - name: kube-router-cfg
        configMap:
          name: kube-router-cfg
      - name: kubeconfig
        hostPath:
          path: /etc/kubernetes/ssl/kubeconfig
       # configMap:
        #  name: kube-proxy
         # items:
         # - key: kubeconfig.conf
         #   path: kubeconfig
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube-router
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: kube-router
  namespace: kube-system
rules:
  - apiGroups:
    - ""
    resources:
      - namespaces
      - pods
      - services
      - nodes
      - endpoints
    verbs:
      - list
      - get
      - watch
  - apiGroups:
    - "networking.k8s.io"
    resources:
      - networkpolicies
    verbs:
      - list
      - get
      - watch
  - apiGroups:
    - extensions
    resources:
      - networkpolicies
    verbs:
      - get
      - list
      - watch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: kube-router
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: kube-router
subjects:
- kind: ServiceAccount
  name: kube-router
  namespace: kube-system



kubectl create -f kube-router.yaml
8.2 布署 kube-dashboard

#镜相下载：registry.docker-cn.com/kubernetesdashboarddev/kubernetes-dashboard-amd64:head
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
  labels:
    k8s-app: kubernetes-dashboard
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      serviceAccountName: kubernetes-dashboard
      containers:
      - name: kubernetes-dashboard
        image: k8s-registry.local/public/kubernetes-dashboard-amd64:1.8.0
        resources:
          # keep request = limit to keep this container in guaranteed class
          limits:
            cpu: 100m
            memory: 300Mi
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 9090
        livenessProbe:
          httpGet:
            path: /
            port: 9090
          initialDelaySeconds: 30
          timeoutSeconds: 30
      tolerations:
      - key: "CriticalAddonsOnly"
        operator: "Exists"


----------


kubectl create -f dashboard.yaml


----------
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
  labels:
    k8s-app: kubernetes-dashboard
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort
  ports:
  - port: 9090
    targetPort: 9090
    nodePort: 8601


kubectl create -f dashboard-svc.yaml
8.3 布署coredns

#镜相下载地址： registry.docker-cn.com/coredns/coredns:0.9.10
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
  labels:
      kubernetes.io/cluster-service: "true"
      addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: Reconcile
  name: system:coredns
rules:
- apiGroups:
  - ""
  resources:
  - endpoints
  - services
  - pods
  - namespaces
  verbs:
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: EnsureExists
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
- kind: ServiceAccount
  name: coredns
  namespace: kube-system
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  labels:
      addonmanager.kubernetes.io/mode: EnsureExists
data:
  Corefile: |
    .:53 {
        errors
        log stdout
        health
        kubernetes cluster.local 172.21.0.0/16
        prometheus
        proxy . /etc/resolv.conf
        cache 30
    }
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: coredns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: coredns
  template:
    metadata:
      labels:
        k8s-app: coredns
    spec:
      serviceAccountName: coredns
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
        - key: "CriticalAddonsOnly"
          operator: "Exists"
      containers:
      - name: coredns
        image: k8s-registry.local/public/coredns:0.9.10
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 60
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 5
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
---
apiVersion: v1
kind: Service
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: coredns
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "CoreDNS"
spec:
  selector:
    k8s-app: coredns
  clusterIP: 172.21.0.2
  ports:
  - name: dns
    port: 53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
  - name: metrics
    port: 9153
    protocol: TCP


----------
kubectl create -f coredns.yaml