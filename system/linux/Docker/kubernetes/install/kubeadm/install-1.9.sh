

# 1.2安装Docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum list docker-ce.x86_64  --showduplicates |sort -r
# Kubernetes 1.8已经针对Docker的1.11.2, 1.12.6, 1.13.1和17.03等版本做了验证。 因为我们这里在各节点安装docker的17.03.2版本。
yum makecache fast

yum install -y --setopt=obsoletes=0 \
  docker-ce-17.03.2.ce-1.el7.centos \
  docker-ce-selinux-17.03.2.ce-1.el7.centos

systemctl start docker
systemctl enable docker

kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=0.0.0.0

# 查看一下集群状态：
kubectl get cs
# NAME                 STATUS    MESSAGE              ERROR
# scheduler            Healthy   ok
# controller-manager   Healthy   ok
# etcd-0               Healthy   {"health": "true"}

# 集群初始化如果遇到问题，可以使用下面的命令进行清理：
kubeadm reset
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/

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

# 创建etcd.pem和etcd-key.pem
## etcd证书申请表
cat > etcd-csr.json <<EOF
{
  "CN": "etcd",
  "hosts": [
    "127.0.0.1",
    "192.168.1.175",
    "192.168.1.176",
    "192.168.1.177"
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
hosts 字段分别指定了etcd集群(192.168.1.175/192.168.1.176/192.168.1.177)、k8s-master的IP(192.168.1.171)
生成etcd.pem/etcd-key.pem

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes etcd-csr.json | cfssljson -bare etcd

<<'COMMENT'
2017/05/12 14:13:51 [INFO] generate received request
2017/05/12 14:13:51 [INFO] received CSR
2017/05/12 14:13:51 [INFO] generating key: rsa-2048
2017/05/12 14:13:52 [INFO] encoded CSR
2017/05/12 14:13:52 [INFO] signed certificate with serial number 513529097933554910472311565391610507353262197901
2017/05/12 14:13:52 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
COMMENT

ls etcd*
<<'COMMENT'
etcd.csr  etcd-csr.json  etcd-key.pem  etcd.pem
COMMENT
保存证书

sudo mkdir -p /etc/etcd/ssl
sudo cp etcd-key.pem  etcd.pem /etc/etcd/ssl
创建kubernetes.pem和kubernetes-key.pem
kubernetes证书申请表

cat <<EOF > kubernetes-csr.json
{
  "CN": "kubernetes",
  "hosts": [
    "127.0.0.1",
    "192.168.1.171",
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
hosts 字段分别指定了k8s-master的IP(192.168.1.171)
添加 kube-apiserver注册的名为kubernetes的服务IP(Service Cluster IP)，一般是kube-apiserver --service-cluster-ip-range选项值指定的网段的第一个IP，如 “10.254.0.1”
生成kubernetes.pem/kubernetes-key.pem

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

<<'COMMENT'
2017/04/21 14:52:32 [INFO] generate received request
2017/04/21 14:52:32 [INFO] received CSR
2017/04/21 14:52:32 [INFO] generating key: rsa-2048
2017/04/21 14:52:32 [INFO] encoded CSR
2017/04/21 14:52:32 [INFO] signed certificate with serial number 675534892777997310707325450009893653396769335719
2017/04/21 14:52:32 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
COMMENT

ls kubernetes*
<<'COMMENT'
kubernetes.csr  kubernetes-csr.json  kubernetes-key.pem  kubernetes.pem
COMMENT
创建admin.pem和admin-key.pem
admin证书申请表

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
后续kube-apiserver使用RBAC(Role-Based Access Control)对客户端(如kubelet、kube-proxy、Pod)请求进行授权
kube-apiserver预定义了一些RBAC使用的RoleBindings，如cluster-admin将Group system:masters与Role cluster-admin绑定，该Role授予了调用kube-apiserver所有 API的权限
OU指定该证书的Group为system:masters，kubelet使用该证书访问kube-apiserver 时 ，由于证书被CA签名，所以认证通过，同时由于证书用户组为经过预授权的 system:masters，所以被授予访问所有API的权限
生成admin.pem/admin-key.pem

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
<<'COMMENT'
2017/04/21 14:58:44 [INFO] generate received request
2017/04/21 14:58:44 [INFO] received CSR
2017/04/21 14:58:44 [INFO] generating key: rsa-2048
2017/04/21 14:58:45 [INFO] encoded CSR
2017/04/21 14:58:45 [INFO] signed certificate with serial number 592438256014219038650472041230298814450491905528
2017/04/21 14:58:45 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
COMMENT

ls admin*
<<'COMMENT'
admin.csr  admin-csr.json  admin-key.pem  admin.pem
COMMENT
创建kube-proxy.pem和kube-proxy-key.pem
kube-proxy证书申请表

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
CN 指定该证书的User为system:kube-proxy
kube-apiserver预定义的RoleBinding system:node-proxier将User system:kube-proxy 与Role system:node-proxier绑定，该Role授予了调用kube-apiserver Proxy相关API的权限
生成kube-proxy.pem/kube-proxy-key.pem

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy
<<'COMMENT'
2017/04/21 15:08:44 [INFO] generate received request
2017/04/21 15:08:44 [INFO] received CSR
2017/04/21 15:08:44 [INFO] generating key: rsa-2048
2017/04/21 15:08:45 [INFO] encoded CSR
2017/04/21 15:08:45 [INFO] signed certificate with serial number 290129049837776761536725457428661161889494017049
2017/04/21 15:08:45 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
COMMENT

ls kube-proxy*
<<'COMMENT'
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem
COMMENT
保存证书

sudo mkdir -p /etc/kubernetes/ssl
sudo cp *.pem /etc/kubernetes/ssl
创建flanneld.pem和flanneld-key.pem
flanneld证书申请表

cat >> flanneld-csr.json <<EOF
{
  "CN": "flanneld",
  "hosts": [
    "127.0.0.1",
    "$NODE_IP"
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
生成flanneld.pem/flanneld-key.pem

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -profile=kubernetes flanneld-csr.json | cfssljson -bare flanneld

<<'COMMENT'
2017/05/11 13:19:01 [INFO] generate received request
2017/05/11 13:19:01 [INFO] received CSR
2017/05/11 13:19:01 [INFO] generating key: rsa-2048
2017/05/11 13:19:02 [INFO] encoded CSR
2017/05/11 13:19:02 [INFO] signed certificate with serial number 727051974508936266314430125501920109141709126829
2017/05/11 13:19:02 [WARNING] This certificate lacks a "hosts" field. This makes it unsuitable for
websites. For more information see the Baseline Requirements for the Issuance and Management
of Publicly-Trusted Certificates, v.1.1.6, from the CA/Browser Forum (https://cabforum.org);
specifically, section 10.2.3 ("Information Requirements").
COMMENT

ls flanneld*
<<'COMMENT'
flanneld.csr  flanneld-csr.json  flanneld-key.pem  flanneld.pem
COMMENT
保存证书

sudo mkdir -p /etc/flanneld/ssl
sudo cp flanneld-key.pem  flanneld.pem /etc/flanneld/ssl
验证证书可用性
以kubernentes.pem为例

利用openssl验证

openssl x509  -noout -text -in  kubernetes.pem
<<'COMMENT'
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            76:54:08:41:9c:14:91:ce:23:59:d8:db:d5:39:66:37:67:85:e9:a7
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=BeiJing, L=BeiJing, O=k8s, OU=System, CN=kubernetes
        Validity
            Not Before: Apr 21 06:48:00 2017 GMT
            Not After : Apr 21 06:48:00 2018 GMT
        Subject: C=CN, ST=BeiJing, L=BeiJing, O=k8s, OU=System, CN=kubernetes
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
...
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                24:FA:8A:54:54:39:D3:65:21:3F:80:E7:5C:B8:4C:F8:B9:21:B4:B0
            X509v3 Authority Key Identifier: 
                keyid:0F:64:BF:83:F1:43:0F:32:0A:E1:D8:90:7D:C6:49:7B:59:00:95:84

            X509v3 Subject Alternative Name: 
                DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster, DNS:kubernetes.default.svc.cluster.local, IP Address:127.0.0.1, IP Address:192.168.1.171, IP Address:192.168.1.175, IP Address:192.168.1.176, IP Address:192.168.1.177, IP Address:10.254.0.1
    Signature Algorithm: sha256WithRSAEncryption
...
COMMENT
利用cfssl-certinfo验证

cfssl-certinfo -cert kubernetes.pem
<<'COMMENT'
{
  "subject": {
    "common_name": "kubernetes",
    "country": "CN",
    "organization": "k8s",
    "organizational_unit": "System",
    "locality": "BeiJing",
    "province": "BeiJing",
    "names": [
      "CN",
      "BeiJing",
      "BeiJing",
      "k8s",
      "System",
      "kubernetes"
    ]
  },
  "issuer": {
    "common_name": "kubernetes",
    "country": "CN",
    "organization": "k8s",
    "organizational_unit": "System",
    "locality": "BeiJing",
    "province": "BeiJing",
    "names": [
      "CN",
      "BeiJing",
      "BeiJing",
      "k8s",
      "System",
      "kubernetes"
    ]
  },
  "serial_number": "675534892777997310707325450009893653396769335719",
  "sans": [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local",
    "127.0.0.1",
    "192.168.1.171",
    "192.168.1.175",
    "192.168.1.176",
    "192.168.1.177",
    "10.254.0.1"
  ],
  "not_before": "2017-04-21T06:48:00Z",
  "not_after": "2018-04-21T06:48:00Z",
  "sigalg": "SHA256WithRSA",
...
}
COMMENT