

Kubernetes集群之安全设置 - 陈健的博客 | ChenJian Blog https://o-my-chenjian.com/2017/04/25/Security-Settings-Of-K8s/


# https://o-my-chenjian.com/2017/04/25/Security-Settings-Of-K8s/
# 安装CFSSL
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl-certinfo_linux-amd64
sudo mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo

mkdir ssl
cd ssl
cfssl print-defaults config > config.json
cfssl print-defaults csr > csr.json

# 创建ca.pem和ca-key.pem
## CA配置文件

cat >> ca-config.json <<EOF 
{
    "signing": {
        "default": {
            "expiry": "8760h"
        },
        "profiles": {
            "kubernetes": {
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ],
                "expiry": "8760h"
            }
        }
    }
}
EOF
# ca-config.json：可以定义多个profiles，分别指定不同的过期时间、使用场景等参数；后续在签名证书时使用某个profile
# signing：表示该证书可用于签名其它证书；生成的ca.pem证书中CA=TRUE
# server auth：表示client可以用该CA对server提供的证书进行验证
# client auth：表示server可以用该CA对client提供的证书进行验证
# CA证书申请表
cat <<EOF > ca-csr.json
{
    "CN": "kubernetes",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "ST": "BeiJing",
            "L": "BeiJing",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF
# “CN”：Common Name，kube-apiserver从证书中提取该字段作为申请的用户名(User Name)；浏览器使用该字段验证网站是否合法
# “O”：Organization，kube-apiserver从证书中提取该字段作为申请用户所属的组 (Group)
# 生成ca.pem/ca-key.pem
cfssl gencert -initca ca-csr.json | cfssljson -bare ca

ls ca*
<<'COMMENT'
ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
COMMENT

# 创建etcd.pem和etcd-key.pem
## etcd证书申请表
cat > etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "172.20.62.42"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
# hosts 字段分别指定了etcd集群(192.168.1.175/192.168.1.176/192.168.1.177)、k8s-master的IP(192.168.1.171)
# 生成etcd.pem/etcd-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes etcd-csr.json | cfssljson -bare etcd
ls etcd*
<<'COMMENT'
etcd.csr  etcd-csr.json  etcd-key.pem  etcd.pem
COMMENT
# 保存证书
mkdir -p /etc/etcd/ssl
cp etcd-key.pem  etcd.pem /etc/etcd/ssl
# 创建kubernetes.pem和kubernetes-key.pem
# kubernetes证书申请表
cat <<EOF > kubernetes-csr.json
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "172.20.62.42",
    "10.254.0.1",
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
# hosts 字段分别指定了k8s-master的IP(192.168.1.171)
# 添加 kube-apiserver注册的名为kubernetes的服务IP(Service Cluster IP)，一般是kube-apiserver --service-cluster-ip-range选项值指定的网段的第一个IP，如 “10.254.0.1”
# 生成kubernetes.pem/kubernetes-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
ls kubernetes*
<<'COMMENT'
kubernetes.csr  kubernetes-csr.json  kubernetes-key.pem  kubernetes.pem
COMMENT
# 创建admin.pem和admin-key.pem
# admin证书申请表
cat <<EOF > admin-csr.json
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "System"
    }
  ]
}
EOF
# 后续kube-apiserver使用RBAC(Role-Based Access Control)对客户端(如kubelet、kube-proxy、Pod)请求进行授权
# kube-apiserver预定义了一些RBAC使用的RoleBindings，如cluster-admin将Group system:masters与Role cluster-admin绑定，该Role授予了调用kube-apiserver所有 API的权限
# OU指定该证书的Group为system:masters，kubelet使用该证书访问kube-apiserver 时 ，由于证书被CA签名，所以认证通过，同时由于证书用户组为经过预授权的 system:masters，所以被授予访问所有API的权限
# 生成admin.pem/admin-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
ls admin*
<<'COMMENT'
admin.csr  admin-csr.json  admin-key.pem  admin.pem
COMMENT
# 创建kube-proxy.pem和kube-proxy-key.pem
# kube-proxy证书申请表
cat <<EOF > kube-proxy-csr.json
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
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
# CN 指定该证书的User为system:kube-proxy
# kube-apiserver预定义的RoleBinding system:node-proxier将User system:kube-proxy 与Role system:node-proxier绑定，该Role授予了调用kube-apiserver Proxy相关API的权限
# 生成kube-proxy.pem/kube-proxy-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy
ls kube-proxy*
<<'COMMENT'
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem
COMMENT
# 保存证书
mkdir -p /etc/kubernetes/ssl
cp *.pem /etc/kubernetes/ssl
# 创建flanneld.pem和flanneld-key.pem
# flanneld证书申请表
cat >> flanneld-csr.json <<EOF
{
  "CN": "flanneld",
  "hosts": [
    "127.0.0.1",
    "172.20.62.42"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
# 生成flanneld.pem/flanneld-key.pem
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld
ls flanneld*
<<'COMMENT'
flanneld.csr  flanneld-csr.json  flanneld-key.pem  flanneld.pem
COMMENT
# 保存证书
mkdir -p /etc/flanneld/ssl
cp flanneld-key.pem  flanneld.pem /etc/flanneld/ssl
# 验证证书可用性
# 以kubernentes.pem为例
# 利用openssl验证
openssl x509  -noout -text -in  kubernetes.pem
# 利用cfssl-certinfo验证
cfssl-certinfo -cert kubernetes.pem
