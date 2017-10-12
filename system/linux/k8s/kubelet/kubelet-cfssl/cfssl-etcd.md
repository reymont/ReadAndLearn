
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [1， 生成 TLS 秘钥对](#1-生成-tls-秘钥对)
	* [1，下载 cfssl](#1下载-cfssl)
	* [2，初始化证书颁发机构](#2初始化证书颁发机构)
	* [3，配置 CA 选项](#3配置-ca-选项)
	* [4，生成服务器端证书](#4生成服务器端证书)
	* [5，生成对等证书](#5生成对等证书)
	* [6，生成客户端证书](#6生成客户端证书)
* [2，拷贝密钥对到所有节点](#2拷贝密钥对到所有节点)
	* [1，拷贝密钥对到所有节点](#1拷贝密钥对到所有节点)
	* [2，更新系统证书库](#2更新系统证书库)
* [3，配置 etcd 使用证书](#3配置-etcd-使用证书)
* [4，测试 etcd 是否正常](#4测试-etcd-是否正常)
* [5，配置 kube-apiserver 使用 CA 连接 etcd](#5配置-kube-apiserver-使用-ca-连接-etcd)
* [6，测试 kube-apiserver](#6测试-kube-apiserver)
* [7，未解决的问题](#7未解决的问题)
	* [1，使用  kubectl get cs 查看会出现如上面所示的报错：](#1使用-kubectl-get-cs-查看会出现如上面所示的报错)
	* [2，使用以下命令查看到的 2380 端口是未加密的](#2使用以下命令查看到的-2380-端口是未加密的)
* [参考文档：](#参考文档)

<!-- /code_chunk_output -->


* [etcd 启用 https - 简书 ](http://www.jianshu.com/p/1043903bc359)



SSL/TSL 认证分单向认证和双向认证两种方式。简单说就是单向认证只是客户端对服务端的身份进行验证，双向认证是客户端和服务端互相进行身份认证。就比如，我们登录淘宝买东西，为了防止我们登录的是假淘宝网站，此时我们通过浏览器打开淘宝买东西时，浏览器会验证我们登录的网站是否是真的淘宝的网站，而淘宝网站不关心我们是否“合法”，这就是单向认证。而双向认证是服务端也需要对客户端做出认证。

因为大部分 kubernetes 基于内网部署，而内网应该都会采用私有 IP 地址通讯，权威 CA 好像只能签署域名证书，对于签署到 IP 可能无法实现。所以我们需要预先自建 CA 签发证书。

Generate self-signed certificates 官方参考文档

官方推荐使用 cfssl 来自建 CA 签发证书，当然你也可以用众人熟知的 OpenSSL 或者 easy-rsa。以下步骤遵循官方文档：

# 1， 生成 TLS 秘钥对

生成步骤：

1，下载 cfssl
2，初始化证书颁发机构
3，配置 CA 选项
4，生成服务器端证书
5，生成对等证书
6，生成客户端证书
想深入了解 HTTPS 的看这里：

聊聊HTTPS和SSL/TLS协议
数字证书CA及扫盲
互联网加密及OpenSSL介绍和简单使用
SSL双向认证和单向认证的区别
## 1，下载 cfssl

mkdir ~/bin
curl -s -L -o ~/bin/cfssl https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
curl -s -L -o ~/bin/cfssljson https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x ~/bin/{cfssl,cfssljson}
export PATH=$PATH:~/bin

## 2，初始化证书颁发机构

mkdir ~/cfssl
cd ~/cfssl
cfssl print-defaults config > ca-config.json
cfssl print-defaults csr > ca-csr.json
证书类型介绍：

`client certificate` 用于通过服务器验证客户端。例如etcdctl，etcd proxy，fleetctl或docker客户端。
`server certificate` 由服务器使用，并由客户端验证服务器身份。例如docker服务器或kube-apiserver。
`peer certificate` 由 etcd 集群成员使用，供它们彼此之间通信使用。

## 3，配置 CA 选项

```sh
$ cat << EOF > ca-config.json

{
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
}

$ cat << EOF > ca-csr.json

{
    "CN": "My own CA",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "US",
            "L": "CA",
            "O": "My Company Name",
            "ST": "San Francisco",
            "OU": "Org Unit 1",
            "OU": "Org Unit 2"
        }
    ]
}
```

生成 CA 证书：

```sh
$ cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
```

将会生成以下几个文件：

```
ca-key.pem
ca.csr
ca.pem
```

请务必保证 ca-key.pem 文件的安全，*.csr 文件在整个过程中不会使用。

## 4，生成服务器端证书

$ echo '{"CN":"coreos1","hosts":["10.93.81.17","127.0.0.1"],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server -hostname="10.93.81.17,127.0.0.1,server" - | cfssljson -bare server

hosts 字段需要自定义。

然后将得到以下几个文件：
server-key.pem
server.csr
server.pem

## 5，生成对等证书

$ echo '{"CN":"member1","hosts":["10.93.81.17","127.0.0.1"],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer -hostname="10.93.81.17,127.0.0.1,server,member1" - | cfssljson -bare member1

hosts 字段需要自定义。

然后将得到以下几个文件：

member1-key.pem
member1.csr
member1.pem

如果有多个 etcd 成员，重复此步为每个成员生成对等证书。

## 6，生成客户端证书

$ echo '{"CN":"client","hosts":["10.93.81.17","127.0.0.1"],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client - | cfssljson -bare client

hosts 字段需要自定义。

然后将得到以下几个文件：

client-key.pem
client.csr
client.pem
至此，所有证书都已生成完毕。

# 2，拷贝密钥对到所有节点

1，拷贝密钥对到所有节点
2，更新系统证书库


## 1，拷贝密钥对到所有节点

```sh
$ mkdir -pv /etc/ssl/etcd/
$ cp ~/cfssl/* /etc/ssl/etcd/
$ chown -R etcd:etcd /etc/ssl/etcd
$ chmod 600 /etc/ssl/etcd/*-key.pem
$ cp ~/cfssl/ca.pem /etc/ssl/certs/
```

## 2，更新系统证书库

```sh
$ yum install ca-certificates -y

$ update-ca-trust
```

# 3，配置 etcd 使用证书

```sh
$ etcdctl version
etcdctl version: 3.1.3
API version: 3.1

$ cat  /etc/etcd/etcd.conf

ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
#监听URL，用于与其他节点通讯
ETCD_LISTEN_PEER_URLS="https://10.93.81.17:2380"

#告知客户端的URL, 也就是服务的URL
ETCD_LISTEN_CLIENT_URLS="https://10.93.81.17:2379,https://10.93.81.17:4001"

#表示监听其他节点同步信号的地址
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.93.81.17:2380"

#–advertise-client-urls 告知客户端的URL, 也就是服务的URL，tcp2379端口用于监听客户端请求
ETCD_ADVERTISE_CLIENT_URLS="https://10.93.81.17:2379"

#启动参数配置
ETCD_NAME="node1"
ETCD_INITIAL_CLUSTER="node1=https://10.93.81.17:2380"
ETCD_INITIAL_CLUSTER_STATE="new"

#[security]

ETCD_CERT_FILE="/etc/ssl/etcd/server.pem"
ETCD_KEY_FILE="/etc/ssl/etcd/server-key.pem"
ETCD_TRUSTED_CA_FILE="/etc/ssl/etcd/ca.pem"
ETCD_CLIENT_CERT_AUTH="true"
ETCD_PEER_CERT_FILE="/etc/ssl/etcd/member1.pem"
ETCD_PEER_KEY_FILE="/etc/ssl/etcd/member1-key.pem"
ETCD_PEER_TRUSTED_CA_FILE="/etc/ssl/etcd/ca.pem"
ETCD_PEER_CLIENT_CERT_AUTH="true"
#[logging]
ETCD_DEBUG="true"
ETCD_LOG_PACKAGE_LEVELS="etcdserver=WARNING,security=DEBUG"
```
# 4，测试 etcd 是否正常

$ systemctl restart  etcd

如果报错，使用 journalctl -f -t etcd 和 journalctl -u etcd 来定位问题。

$ curl --cacert /etc/ssl/etcd/ca.pem --cert /etc/ssl/etcd/client.pem --key /etc/ssl/etcd/client-key.pem https://10.93.81.17:2379/health
{"health": "true"}

$ etcdctl --endpoints=[10.93.81.17:2379] --cacert=/etc/ssl/etcd/ca.pem --cert=/etc/ssl/etcd/client.pem --key=/etc/ssl/etcd/client-key.pem member list

$ etcdctl --endpoints=[10.93.81.17:2379] --cacert=/etc/ssl/etcd/ca.pem --cert=/etc/ssl/etcd/client.pem --key=/etc/ssl/etcd/client-key.pem put /foo/bar  "hello world"

$ etcdctl --endpoints=[10.93.81.17:2379] --cacert=/etc/ssl/etcd/ca.pem --cert=/etc/ssl/etcd/client.pem --key=/etc/ssl/etcd/client-key.pem get /foo/bar

# 5，配置 kube-apiserver 使用 CA 连接 etcd

```sh
$ cp /etc/ssl/etcd/*  /var/run/kubernetes/

$ chown  -R kube.kube /var/run/kubernetes/

在 /etc/kubernetes/apiserver 中 KUBE_API_ARGS 新加一下几个参数：

--cert-dir='/var/run/kubernetes/' --etcd-cafile='/var/run/kubernetes/ca.pem' --etcd-certfile='/var/run/kubernetes/client.pem' --etcd-keyfile='/var/run/kubernetes/client-key.pem'
```

# 6，测试 kube-apiserver

```sh
$ systemctl restart kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy

$ systemctl status -l kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy

$ kubectl get node

$ kubectl get cs
NAME                 STATUS      MESSAGE                                                                   ERROR
scheduler            Healthy     ok
controller-manager   Healthy     ok
etcd-0               Unhealthy   Get https://10.93.81.17:2379/health: remote error: tls: bad certificate

$ ./version.sh
etcdctl version: 3.1.3
API version: 3.1
Kubernetes v1.6.0-beta.1
```

# 7，未解决的问题

## 1，使用  kubectl get cs 查看会出现如上面所示的报错：

etcd-0 Unhealthy Get https://10.93.81.17:2379/health: remote error: tls: bad certificate
此问题有人提交 pr 但尚未被 merge，etcd component status check should include credentials

## 2，使用以下命令查看到的 2380 端口是未加密的

```sh
$ etcdctl --endpoints=[10.93.81.17:2379] --cacert=/etc/ssl/etcd/ca.pem --cert=/etc/ssl/etcd/client.pem --key=/etc/ssl/etcd/client-key.pem member list  


2017-03-15 15:02:05.611564 I | warning: ignoring ServerName for user-provided CA for backwards compatibility is deprecated
145b401ad8709f51, started, node1, http://10.93.81.17:2380, https://10.93.81.17:2379
```

# 参考文档：

* [kubernetes + etcd ssl 支持](https://www.addops.cn/post/tls-for-kubernetes-etcd.html)
* [Security model](https://coreos.com/etcd/docs/latest/op-guide/security.html)
* [Enabling HTTPS in an existing etcd cluster](https://coreos.com/etcd/docs/latest/etcd-live-http-to-https-migration.html)

作者：田飞雨
链接：http://www.jianshu.com/p/1043903bc359
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。