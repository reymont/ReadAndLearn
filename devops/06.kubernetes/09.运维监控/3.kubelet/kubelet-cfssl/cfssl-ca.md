

* [follow-me-install-kubernetes-cluster/02-创建CA证书和秘钥.md at master · opsnull/follow-me-install-kubernetes-cluster ](https://github.com/opsnull/follow-me-install-kubernetes-cluster/blob/master/02-%E5%88%9B%E5%BB%BACA%E8%AF%81%E4%B9%A6%E5%92%8C%E7%A7%98%E9%92%A5.md)
* [Generate Self Signed Certificates ](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html)
* [kubernetes-the-hard-way/02-certificate-authority.md at master · kelseyhightower/kubernetes-the-hard-way ](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-certificate-authority.md)
* [Client Certificates V/s Server Certificates – Unleashed ](https://blogs.msdn.microsoft.com/kaushal/2012/02/17/client-certificates-vs-server-certificates/)


# 使用CFSSL构建本地CA

* [使用CFSSL构建本地CA - iOps ](http://www.iops.cc/make-local-ca-with-cfssl/)
* [如何构建私有公钥基础设施 ](http://www.infoq.com/cn/news/2015/06/CloudFlare-PKI-TLS?utm_source=news_about_CFSSL&utm_medium=link&utm_campaign=CFSSL)

该系统基于一个`“公钥基础设施（public key infrastructure，缩写为PKI）”`，使用了`内部托管的认证中心（CA）`。

## 创建自己的认证中心（CA）

为了创建一个可以轻松获取和操作证书的内部认证中心，可以使用开源的PKI工具箱CFSSL。该工具具有运行一个认证中心所需的全部功能。

运行认证中心需要一个CA证书和相应的私钥。后者是极其敏感的数据。**任何知道私钥的人都可以充当CA颁发证书**。因此，私钥的保护至关重要。CFSSL支持以下三种私钥保护模式：

* “硬件安全模块（Hardware Security Module，缩写为HSM）
* Red October
* 纯文本

## 生成CA证书和私钥

创建一个包含如下组织基本信息的文件csr_ca.json：

```json
{
  "CN": "My Awesome CA",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
    "names": [
       {
         "C": "US",
         "L": "San Francisco",
         "O": "My Awesome Company",
         "OU": "CA Services",
         "ST": "California"
       }
    ]
}
```
执行下面的命令：

```sh
$ cfssl gencert -initca csr_ca.json | cfssljson -bare ca
```

该命令会生成运行CA所必需的文件`ca-key.pem（私钥）和ca.pem（证书）`，还会生成`ca.csr（证书签名请求），用于交叉签名或重新签名`。

## 参数介绍

* [Creating a new CSR · cloudflare/cfssl Wiki ](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR)

The `"hosts"` value is a list of the domain names which the
certificate should be valid for. The `"CN"` value is used by some CAs
to determine which domain the certificate is to be generated for
instead; these CAs will most often provide a certificate for both the
"www" (e.g. www.example.net) and "bare" (e.g. example.net) domain
names if the "www" domain name is provided. The `"key"` value in the
example is the default that most CAs support. (It may even be omitted
in this case; it is shown here for completeness.)

The `"names"` value is actually a list of name objects. Each name
object should contain at least one "C", "L", "O", "OU", or "ST" value
(or any combination of these). These values are:

* "C": country
* "L": locality or municipality (such as city or town name)
* "O": organisation
* "OU": organisational unit, such as the department responsible for
  owning the key; it can also be used for a "Doing Business As" (DBS)
  name
* "ST": the state or province

## 配置证书生成策略，并启动CA服务

配置证书生成策略，让CA软件知道颁发什么样的证书。下面是一个简单的示例：

```json
config_ca.json  
{
  "signing": {
    "default": {
      "auth_key": "key1",
      "expiry": "8760h",
      "usages": [
         "signing",
         "key encipherment",
         "server auth"
       ]
     }
  },
  "auth_keys": {
    "key1": {
      "key": <16 byte hex API key here>,
      "type": "standard"
    }
  }
}
```
该策略指定了证书有效期（1年）、用途（服务器验证等）以及一个随机生成的私有验证密钥。该密钥可以防止未经授权的机构请求证书。

执行下面的命令，启动CA服务：

```sh
$ cfssl serve -ca-key ca-key.pem -ca ca.pem -config config_ca.json
```

# Creating a new CSR

* [Creating a new CSR · cloudflare/cfssl Wiki ](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR)

# Introducing CFSSL

* [Introducing CFSSL - CloudFlare's PKI toolkit ](https://blog.cloudflare.com/introducing-cfssl/)

## How CFSSL Makes Certificate Bundling Easier.

If you are running a website (or perhaps some other TLS-based service) and need to install a certificate, CFSSL can create the certificate bundle for you. Start with the following command:
```sh
$ cfssl bundle -cert mycert.crt
```
This will output a JSON blob containing the chain of certificates along with relevant information extracted from that chain. Alternatively, you can run the CFSSL service that responds to requests with a JSON API:
```sh
$ cfssl serve
```

`This command opens up an HTTP service on localhost that accepts requests`. To bundle using this API, send a POST request to this service, http://localhost:8888/api/v1/cfssl/bundle, using a JSON request such as:

```json
{
    "certificate": <PEM-encoded certificate>
}
```
CloudFlare’s SSL service will return a JSON response of the form:
```json
{
    "result": {<certificate bundle JSON>},
    "success": true,
    "errors": [],
    "messages": [],
}
```
(Developers take note: this response format is a preview of our upcoming CloudFlare API rewrite; with this API, we can use CFSSL as a service for certificate bundling and more—stay tuned.)

If you upload your certificate to CloudFlare, this is what is used to create a certificate bundle for your website.
To create a certificate bundle with CFSSL, you need to know which certificates are trusted by the browsers you hope to display content to. In a controlled corporate environment, this is usually easy since every browser is set up with the same configuration; however, it becomes more difficult when creating a bundle for the web.


# 数字证书及CA的扫盲介绍

* [数字证书及CA的扫盲介绍_知识库_博客园 ](http://kb.cnblogs.com/page/194742/)
* [Public key certificate - Wikipedia ](https://en.wikipedia.org/wiki/Public_key_certificate)
* [Certificate authority - Wikipedia ](https://en.wikipedia.org/wiki/Certificate_authority)

## 概念

* 证书：“证书”也叫“digital certificate”或“public key certificate”。
* 证书授权中心：CA是Certificate Authority的缩写，也叫“证书授权中心”。负责管理和签发证书的第三方机构。
* CA 证书：顾名思义，就是CA颁发的证书。
* 证书的信任链：证书之间的信任关系，是可以嵌套的。比如，C 信任 A1，A1 信任 A2，A2 信任 A3......这个叫做证书的信任链。
* 根证书：“根证书”叫“root certificate”。除了根证书，其它证书都要依靠上一级的证书，来证明自己。根证书是整个证书体系安全的根本。

## 作用

* 验证网站是否可信（针对HTTPS）
* 验证某文件是否可信（是否被篡改）



