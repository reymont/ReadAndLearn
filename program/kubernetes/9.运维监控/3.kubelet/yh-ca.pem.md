

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [gen_cafile](#gen_cafile)
	* [cfssl gencert](#cfssl-gencert)
		* [Generating self-signed root CA certificate and private key](#generating-self-signed-root-ca-certificate-and-private-key)
		* [Generating a remote-issued certificate and private key.](#generating-a-remote-issued-certificate-and-private-key)
		* [Generating a local-issued certificate and private key.](#generating-a-local-issued-certificate-and-private-key)
	* [host](#host)
	* [cfssljson](#cfssljson)
		* [The cfssljson Utility](#the-cfssljson-utility)
* [阅读](#阅读)
	* [Introducing CFSSL - CloudFlare's PKI toolkit](#introducing-cfssl-cloudflares-pki-toolkit)
	* [cfssljson -bare](#cfssljson-bare)
	* [Kubernetes安装之证书验证](#kubernetes安装之证书验证)
		* [Kubernentes中的身份验证](#kubernentes中的身份验证)
		* [安装 CFSSL](#安装-cfssl)
			* [方式一：直接使用二进制源码包安装](#方式一直接使用二进制源码包安装)
			* [方式二：使用Go命令安装](#方式二使用go命令安装)
		* [创建 CA (Certificate Authority)](#创建-ca-certificate-authority)
			* [创建 CA 配置文件](#创建-ca-配置文件)
			* [创建 CA 证书签名请求](#创建-ca-证书签名请求)
			* [生成 CA 证书和私钥](#生成-ca-证书和私钥)
		* [创建 Kubernetes 证书](#创建-kubernetes-证书)
			* [创建 kubernetes 证书签名请求](#创建-kubernetes-证书签名请求)
			* [生成 kubernetes 证书和私钥](#生成-kubernetes-证书和私钥)
		* [创建 Admin 证书](#创建-admin-证书)
			* [创建 admin 证书签名请求](#创建-admin-证书签名请求)
			* [生成 admin 证书和私钥](#生成-admin-证书和私钥)
		* [创建 Kube-Proxy 证书](#创建-kube-proxy-证书)
			* [生成 kube-proxy 客户端证书和私钥](#生成-kube-proxy-客户端证书和私钥)
		* [校验证书](#校验证书)
			* [使用 Opsnssl 命令](#使用-opsnssl-命令)
			* [使用 Cfssl-Certinfo 命令](#使用-cfssl-certinfo-命令)
			* [分发证书](#分发证书)
		* [参考](#参考)

<!-- /code_chunk_output -->



# gen_cafile


```sh
function gen_cafile() {
  rm -f ca* kubernetes*
  cat <<EOF > ca-config.json
{
  "signing": {
    "default": {
      "expiry": "$1"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
          "signing",
          "key encipherment",
          "server auth",
          "client auth"
         ],
         "expiry": "$1"
      }
    }
  }
}
EOF

  cat <<EOF > ca-csr.json 
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [{
    "C": "CN",
    "ST": "BeiJing",
    "L": "BeiJing",
    "O": "OpenBridge",
    "OU": "System"
  }]
}
EOF

  cat <<EOF > kubernetes-csr.json
{
    "CN": "kubernetes",
    "hosts": [
      "127.0.0.1",
      "10.96.0.1",
      "$MASTER_ADDR",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local"
    ], "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [ {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "OpenBridge",
      "OU": "System"
    } ]
}
EOF

  # config ssl
  #rm -rf *.pem *.csr
  cfssl gencert -initca ca-csr.json | cfssljson -bare ca
  cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
}
```

## cfssl gencert

* [cloudflare/cfssl: CFSSL: Cloudflare's PKI and TLS toolkit ](https://github.com/cloudflare/cfssl)

```sh
cfssl gencert ---
bad flag syntax: ---
	cfssl gencert -- generate a new key and signed certificate

Usage of gencert:
    Generate a new key and cert from CSR:
        cfssl gencert -initca CSRJSON
        cfssl gencert -ca cert -ca-key key [-config config] [-profile profile] [-hostname hostname] CSRJSON
        cfssl gencert -remote remote_host [-config config] [-profile profile] [-label label] [-hostname hostname] CSRJSON

    Re-generate a CA cert with the CA key and CSR:
        cfssl gencert -initca -ca-key key CSRJSON

    Re-generate a CA cert with the CA key and certificate:
        cfssl gencert -renewca -ca cert -ca-key key

Arguments:
        CSRJSON:    JSON file containing the request, use '-' for reading JSON from stdin

Flags:
  -initca=false: initialise new CA
  -remote="": remote CFSSL server
  -ca="": CA used to sign the new certificate -- accepts '[file:]fname' or 'env:varname'
  -ca-key="": CA private key -- accepts '[file:]fname' or 'env:varname'
  -config="": path to configuration file
  -hostname="": Hostname for the cert, could be a comma-separated hostname list
  -profile="": signing profile to use
  -label="": key label to use in remote CFSSL server
  -loglevel=1: Log level (0 = DEBUG, 5 = FATAL)
```

### Generating self-signed root CA certificate and private key

> cfssl genkey -initca csr.json | cfssljson -bare ca

To generate a self-signed root CA certificate, specify the key request as the JSON file in the same format as in 'genkey'. Three PEM-encoded entities will appear in the output: the private key, the csr, and the self-signed certificate.

### Generating a remote-issued certificate and private key.

> cfssl gencert -remote=remote_server [-hostname=comma,separated,hostnames] csr.json

This is calls genkey, but has a remote CFSSL server sign and issue a certificate. You may use -hostname to override certificate SANs.

### Generating a local-issued certificate and private key.

cfssl gencert -ca cert -ca-key key [-hostname=comma,separated,hostnames] csr.json
This is generates and issues a certificate and private key from a local CA via a JSON request. You may use -hostname to override certificate SANs.

## host

* [Kubernetes安装之证书验证_Kubernetes中文社区 ](https://www.kubernetes.org.cn/1861.html)

如果 hosts 字段不为空则需要指定授权使用该证书的 IP 或域名列表，由于该证书后续被 etcd 集群和 kubernetes master 集群使用，所以上面分别指定了 etcd 集群、kubernetes master 集群的主机 IP 和 kubernetes 服务的服务 IP（一般是 kue-apiserver 指定的 service-cluster-ip-range 网段的第一个IP，如 10.254.0.1。

## cfssljson

the `cfssljson` program, which takes the JSON output from the
  `cfssl` and `multirootca` programs and writes certificates, keys,
  CSRs, and bundles to disk.

```conf
Usage of cfssljson:
  -bare
    	the response from CFSSL is not wrapped in the API standard response
        CFSSL的响应没有包装在API标准响应中
  -f string
    	JSON input (default "-")
  -stdout
    	output the response instead of saving to a file
```

### The cfssljson Utility

Most of the output from `cfssl` is in JSON. The `cfssljson` will take
this output and split it out into separate key, certificate, CSR, and
bundle files as appropriate. The tool takes a single flag, `-f`, that
specifies the input file, and an argument that specifies the base name for
the files produced. If the input filename is "-" (which is the default),
`cfssljson` reads from standard input. It maps keys in the JSON file to
filenames in the following way:

* if there is a "cert" (or if not, if there's a "certificate") field, the
  file "basename.pem" will be produced.
* if there is a "key" (or if not, if there's a "private_key") field, the
  file "basename-key.pem" will be produced.
* if there is a "csr" (or if not, if there's a "certificate_request") field,
  the file "basename.csr" will be produced.
* if there is a "bundle" field, the file "basename-bundle.pem" will
  be produced.
* if there is a "ocspResponse" field, the file "basename-response.der" will
  be produced.

Instead of saving to a file, you can pass `-stdout` to output the encoded
contents.


# 阅读


## Introducing CFSSL - CloudFlare's PKI toolkit

* [Introducing CFSSL - CloudFlare's PKI toolkit ](https://blog.cloudflare.com/introducing-cfssl/)



## cfssljson -bare


kubenetes ca认证过程中cfssljson -bare的含义

* [Creating a new CSR · cloudflare/cfssl Wiki ](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR)


```conf
Usage of cfssljson:
  -bare
    	the response from CFSSL is not wrapped in the API standard response
        CFSSL的响应没有包装在API标准响应中
  -f string
    	JSON input (default "-")
  -stdout
    	output the response instead of saving to a file
```

cfssljson -bare

With our JSON request ready, a CSR and private key can be generated either through the API or through the command line interface. Both return a JSON response, but the cfssljson tool can be used to convert the response to files. With the command line interface, assuming the above certificate request is saved in "csr.json", the command line tool should be called with

> cfssl genkey csr.json | cfssljson -bare certificate

This will produce a "certificate.csr" and "certificate-key.pem" file; the latter is the private key: it should be stored securely. The CSR should be sent to the CA (most often by copying and pasting it into a form on their site).

The API can also be used by making a POST request to "/api/v1/cfssl/newkey". For example, a cURL request to a locally-running CFSSL would look like:

> curl -X POST -H "Content-Type: application/json" -d @csr.json \
    http://127.0.0.1:8888/api/v1/cfssl/newkey | cfssljson certificate

This will produce the same pair of files.

## Kubernetes安装之证书验证

* [Kubernetes安装之证书验证 - Kubernetes中文社区 - CSDN博客 ](http://blog.csdn.net/qq_34463875/article/details/71425661)
* [Kubernetes安装之证书验证 - Jimmy Song ](http://jimmysong.io/blogs/kubernetes-tls-certificate/)

### Kubernentes中的身份验证

kubernetes 系统的各组件需要使用 TLS 证书对通信进行加密，本文档使用 CloudFlare 的 PKI 工具集 cfssl 来生成 Certificate Authority (CA) 和其它证书；

生成的 CA 证书和秘钥文件如下：

* ca-key.pem
* ca.pem
* kubernetes-key.pem
* kubernetes.pem
* kube-proxy.pem
* kube-proxy-key.pem
* admin.pem
* admin-key.pem

使用证书的组件如下：

* etcd：使用 ca.pem、kubernetes-key.pem、kubernetes.pem；
* kube-apiserver：使用 ca.pem、kubernetes-key.pem、kubernetes.pem；
* kubelet：使用 ca.pem；
* kube-proxy：使用 ca.pem、kube-proxy-key.pem、kube-proxy.pem；
* kubectl：使用 ca.pem、admin-key.pem、admin.pem；
* kube-controller、kube-scheduler 当前需要和 kube-apiserver 部署在同一台机器上且使用非安全端口通信，故不需要证书。

### 安装 CFSSL

#### 方式一：直接使用二进制源码包安装
```sh
$ wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
$ chmod +x cfssl_linux-amd64
$ sudo mv cfssl_linux-amd64 /root/local/bin/cfssl

$ wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
$ chmod +x cfssljson_linux-amd64
$ sudo mv cfssljson_linux-amd64 /root/local/bin/cfssljson

$ wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
$ chmod +x cfssl-certinfo_linux-amd64
$ sudo mv cfssl-certinfo_linux-amd64 /root/local/bin/cfssl-certinfo

$ export PATH=/root/local/bin:$PATH
```
#### 方式二：使用Go命令安装

我们的系统中安装了Go1.7.5，使用以下命令安装更快捷：

```sh
$go get -u github.com/cloudflare/cfssl/cmd/...
$echo $GOPATH
/usr/local
$ls /usr/local/bin/cfssl*
cfssl cfssl-bundle cfssl-certinfo cfssljson cfssl-newkey cfssl-scan
```

在$GOPATH/bin目录下得到以cfssl开头的几个命令。

### 创建 CA (Certificate Authority)

#### 创建 CA 配置文件

```sh
$ mkdir /root/ssl
$ cd /root/ssl
$ cfssl print-defaults config > config.json
$ cfssl print-defaults csr > csr.json
$ cat ca-config.json
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
```
字段说明

* ca-config.json：可以定义多个 profiles，分别指定不同的过期时间、使用场景等参数；后续在签名证书时使用某个 profile；
* signing：表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE；
* server auth：表示client可以用该 CA 对server提供的证书进行验证；
* client auth：表示server可以用该CA对client提供的证书进行验证；

#### 创建 CA 证书签名请求

```json
$ cat ca-csr.json
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
```

* “CN”：Common Name，kube-apiserver 从证书中提取该字段作为请求的用户名 (User Name)；浏览器使用该字段验证网站是否合法；
* “O”：Organization，kube-apiserver 从证书中提取该字段作为请求用户所属的组 (Group)；

#### 生成 CA 证书和私钥

```sh
$ cfssl gencert -initca ca-csr.json | cfssljson -bare ca
$ ls ca*
ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
```

### 创建 Kubernetes 证书

#### 创建 kubernetes 证书签名请求

```json
$ cat kubernetes-csr.json
{
    "CN": "kubernetes",
    "hosts": [
      "127.0.0.1",
      "172.20.0.112",
      "172.20.0.113",
      "172.20.0.114",
      "172.20.0.115",
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
```
如果 hosts 字段不为空则需要指定授权使用该证书的 IP 或域名列表，由于该证书后续被 etcd 集群和kubernetes master 集群使用，所以上面分别指定了 etcd 集群、kubernetes master 集群的主机 IP 和kubernetes 服务的服务 IP（一般是 kue-apiserver 指定的 service-cluster-ip-range 网段的第一个IP，如 10.254.0.1。

#### 生成 kubernetes 证书和私钥

```sh
$ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
$ ls kuberntes*
kubernetes.csr  kubernetes-csr.json  kubernetes-key.pem  kubernetes.pem
```
或者直接在命令行上指定相关参数：

```sh
$ echo '{"CN":"kubernetes","hosts":[""],"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes -hostname="127.0.0.1,10.64.3.7,10.254.0.1,kubernetes,kubernetes.default" - | cfssljson -bare kubernetes
```

### 创建 Admin 证书

#### 创建 admin 证书签名请求

```json
$ cat admin-csr.json
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
```
后续 kube-apiserver 使用 RBAC 对客户端(如 kubelet、kube-proxy、Pod)请求进行授权；
* kube-apiserver 预定义了一些 RBAC 使用的 RoleBindings，如 cluster-admin 将 Groupsystem:masters与 Role cluster-admin 绑定，该 Role 授予了调用kube-apiserver 的所有 API的权限；
* OU 指定该证书的 Group 为 system:masters，kubelet 使用该证书访问 kube-apiserver时 ，由于证书被 CA 签名，所以认证通过，同时由于证书用户组为经过预授权的system:masters，所以被授予访问所有 API 的权限；

#### 生成 admin 证书和私钥
```sh
$ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
$ ls admin*
admin.csr  admin-csr.json  admin-key.pem  admin.pem
```

### 创建 Kube-Proxy 证书

创建 kube-proxy 证书签名请求
```json
$ cat kube-proxy-csr.json
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
```

* CN 指定该证书的 User 为 system:kube-proxy；
* kube-apiserver 预定义的 RoleBinding cluster-admin 将User system:kube-proxy 与 Rolesystem:node-proxier 绑定，该 Role 授予了调用 kube-apiserver Proxy 相关 API 的权限；

#### 生成 kube-proxy 客户端证书和私钥

```sh
$ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy
$ ls kube-proxy*
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem
```

### 校验证书

以 kubernetes 证书为例

#### 使用 Opsnssl 命令

```
$ openssl x509  -noout -text -in  kubernetes.pem
...
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=BeiJing, L=BeiJing, O=k8s, OU=System, CN=Kubernetes
        Validity
            Not Before: Apr  5 05:36:00 2017 GMT
            Not After : Apr  5 05:36:00 2018 GMT
        Subject: C=CN, ST=BeiJing, L=BeiJing, O=k8s, OU=System, CN=kubernetes
...
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage:
                TLS Web Server Authentication, TLS Web Client Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                DD:52:04:43:10:13:A9:29:24:17:3A:0E:D7:14:DB:36:F8:6C:E0:E0
            X509v3 Authority Key Identifier:
                keyid:44:04:3B:60:BD:69:78:14:68:AF:A0:41:13:F6:17:07:13:63:58:CD

            X509v3 Subject Alternative Name:
                DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster, DNS:kubernetes.default.svc.cluster.local, IP Address:127.0.0.1, IP Address:172.20.0.112, IP Address:172.20.0.113, IP Address:172.20.0.114, IP Address:172.20.0.115, IP Address:10.254.0.1
...
```

* 确认 Issuer 字段的内容和 ca-csr.json 一致；
* 确认 Subject 字段的内容和 kubernetes-csr.json 一致；
* 确认 X509v3 Subject Alternative Name 字段的内容和 kubernetes-csr.json 一致；
* 确认 X509v3 Key Usage、Extended Key Usage 字段的内容和 ca-config.json 中 kubernetesprofile 一致；

#### 使用 Cfssl-Certinfo 命令

```json
$ cfssl-certinfo -cert kubernetes.pem
...
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
    "common_name": "Kubernetes",
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
      "Kubernetes"
    ]
  },
  "serial_number": "174360492872423263473151971632292895707129022309",
  "sans": [
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.cluster",
    "kubernetes.default.svc.cluster.local",
    "127.0.0.1",
    "10.64.3.7",
    "10.254.0.1"
  ],
  "not_before": "2017-04-05T05:36:00Z",
  "not_after": "2018-04-05T05:36:00Z",
  "sigalg": "SHA256WithRSA",
...
```

#### 分发证书

将生成的证书和秘钥文件（后缀名为.pem）拷贝到所有机器的 /etc/kubernetes/ssl 目录下备用；
```sh
$ sudo mkdir -p /etc/kubernetes/ssl
$ sudo cp *.pem /etc/kubernetes/ssl
```

### 参考

* [Generate self-signed certificates](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html)
* [Setting up a Certificate Authority and Creating TLS Certificates](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-certificate-authority.md)
* [Client Certificates V/s Server Certificates](https://blogs.msdn.microsoft.com/kaushal/2012/02/17/client-certificates-vs-server-certificates/)
* [数字证书及 CA 的扫盲介绍](http://blog.jobbole.com/104919/)

[Kubernetes安装之证书验证](https://www.kubernetes.org.cn/1861.html)