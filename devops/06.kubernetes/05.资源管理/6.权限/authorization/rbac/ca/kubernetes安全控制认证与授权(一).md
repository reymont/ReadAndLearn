

kubernetes安全控制认证与授权(一) - CSDN博客 
http://blog.csdn.net/yan234280533/article/details/75808048

kubernetes 对于访问 API 来说提供了两个步骤的安全措施：`认证和授权。认证解决用户是谁的问题，授权解决用户能做什么的问题`。

通俗的讲，`认证就是验证用户名密码，授权就是检查该用户是否拥有权限访问请求的资源`。

Kubernetes集群的所有操作基本上都是通过kube-apiserver这个组件进行的，它提供HTTP RESTful形式的API供集群内外客户端调用。需要注意的是：认证授权过程只存在HTTPS形式的API中。也就是说，如果客户端使用HTTP连接到kube-apiserver，那么是不会进行认证授权的。所以说，可以这么设置，在集群内部组件间通信使用HTTP，集群外部就使用HTTPS，这样既增加了安全性，也不至于太复杂。

下图是 `API 访问要经过的三个步骤，前面两个是认证和授权，第三个是 Admission Control`，它也能在一定程度上提高安全性，不过更多是资源管理方面的作用。

# 客户端证书

客户端证书认证叫作TLS双向认证，也就是服务器客户端互相验证证书的正确性，在都正确的情况下协调通信加密方案。

为了使用这个方案，api－server需要用－client－ca－file＝选项来开启。CA_CERTIFICATE_FILE肯定包括一个或者多个认证中心，可以被用来验证呈现给api－server的客户端证书。客户端证书的／CN将作为用户名。

# 静态Token文件

用token唯一标识请求者，只要apiserver存在该token，则认为认证通过，但是如果需要新增Token，则需要重启kube-apiserver组件，实际效果不是很好。

当在命令行指定- -token-auth-file=SOMEFILE选项时，API服务器从文件中读取 bearer tokens。目前，tokens持续无限期。

令牌文件是一个至少包含3列的csv文件： token, user name, user uid，后跟可选的组名。注意，如果您有多个组，则列必须是双引号，例如：

token,user,uid,"group1,group2,group3"

当通过客户端使用 bearer token 认证时，API服务器需要一个值为Bearer THETOKEN的授权头。bearer token必须是，可以放在HTTP请求头中且值不需要转码和引用的一个字符串。例如：如果bearer token是31ada4fd-adec-460c-809a-9e56ceb75269，它将会在HTTP头中按下面的方式呈现：

Authorization: Bearer 31ada4fd-adec-460c-809a-9e56ceb75269

# 引导Token

在v1.6版本中，这个特性还是alpha特性。为了能够在新的集群中使用bootstrapping认证。Kubernetes包括一种动态管理的Bearer(持票人) token，这种token以Secrets的方式存储在kube-system命名空间中，在这个命名空间token可以被动态的管理和创建。Controller Manager有一个管理中心，如果token过期了就会删除。

创建的token证书满足[a-z0-9]{6}.[a-z0-9]{16}格式，Token的第一部分是一个Token ID，第二部分是token的秘钥。你需要在http协议头中加上类似的信息：

Authorization: Bearer 781292.db7bc3a58fc5f07e

如果要使用Bootstrap，需要在API Sever中开启--experimental-bootstrap-token-auth。同时必须在Controller Manager中开启管理中心的设置--controllers=*,tokencleaner。

在使用kubeadm部署Kubernetes时，kubeadm会自动创建默认token，可通过kubeadm token list命令查询。

# 静态密码文件

静态密码的方式是提前在某个文件中保存了用户名和密码的信息，然后在 apiserver 启动的时候通过参数 –basic-auth-file=SOMEFILE 指定文件的路径。apiserver 一旦启动，加载的用户名和密码信息就不会发生改变，任何对源文件的修改必须重启 apiserver 才能生效。

静态密码文件是 CSV 格式的文件，每行对应一个用户的信息，前面三列密码、用户名、用户 ID 是必须的，第四列是可选的组名（如果有多个组，必须用双引号）：

password,user,uid,"group1,group2,group3"

客户端在发送请求的时候需要在请求头部添加上 Authorization 字段，对应的值是 Basic BASE64ENCODED(USER:PASSWORD) 。apiserver 解析出客户端提供的用户名和密码，如果和文件中的某一行匹配，就认为认证成功。

注意： 
这种方式很不灵活，也不安全，可以说名存实亡，不推荐使用。

# Service Account Tokens 认证

有些情况下，我们希望在 pod 内部访问 apiserver，获取集群的信息，甚至对集群进行改动。针对这种情况，kubernetes 提供了一种特殊的认证方式：Service Account。 Service Account 是面向 namespace 的，每个 namespace 创建的时候，kubernetes 会自动在这个 namespace 下面创建一个默认的 Service Account；并且这个 Service Account 只能访问该 namespace 的资源。Service Account 和 pod、service、deployment 一样是 kubernetes 集群中的一种资源，用户也可以创建自己的 serviceaccount。

ServiceAccount 主要包含了三个内容：namespace、Token 和 CA。namespace 指定了 pod 所在的 namespace，CA 用于验证 apiserver 的证书，token 用作身份验证。它们都通过 mount 的方式保存在 pod 的文件系统中，其中 token 保存的路径是 /var/run/secrets/kubernetes.io/serviceaccount/token ，是 apiserver 通过私钥签发 token 的 base64 编码后的结果； CA 保存的路径是 /var/run/secrets/kubernetes.io/serviceaccount/ca.crt ，namespace 保存的路径是 /var/run/secrets/kubernetes.io/serviceaccount/namespace ，也是用 base64 编码。

如果 token 能够通过认证，那么请求的用户名将被设置为 system:serviceaccount:(NAMESPACE):(SERVICEACCOUNT) ，而请求的组名有两个： system:serviceaccounts 和 system:serviceaccounts:(NAMESPACE)。

关于 Service Account 的配置可以参考官方的 Manager Service Accounts 文档。

# OpenID Connect Tokens 认证

OpenID Connect 是一些由OAuth2提供商支持的OAuth2，特别是Azure Active Directory，Salesforce和Google。OAuth2的协议的主要扩展是增加一个额外字段，返回了一个叫ID token的access token。这个token是被服务器签名的JSON Web Token (JWT) ，具有众所周知的字段，比如用户的email。

为了识别用户，验证使用来自OAuth2 token响应的id_token (而不是 access_token)作为bearer token。token如何包含在请求中可以参考下图： 
oidc.png-55.3kB

使用OpenID认证，API Server需要配置 
- --oidc-issuer-url，如https://accounts.google.com 
- --oidc-client-id，如kubernetes 
- --oidc-username-claim，如sub 
- --oidc-groups-claim，如groups 
- --oidc-ca-file，如/etc/kubernetes/ssl/kc-ca.pem

# Webhook Token 认证

Webhook Token 认证方式可以让用户使用自己的认证方式，用户只需要按照约定的请求格式和应答格式提供 HTTPS 服务，当用户把 Bearer Token 放到请求的头部，kubernetes 会把 token 发送给事先配置的地址进行认证，如果认证结果成功，则认为请求用户合法。 这种方式下有两个参数可以配置：

–authentication-token-webhook-config-file ：kubeconfig 文件说明如果访问认证服务器

–authentication-token-webhook-cache-ttl ：认证结果要缓存多久，默认是两分钟 
这种方式下，自定义认证的请求和应答都有一定的格式，具体的规范请参考 官方文档的说明 。

认证代理

API Server需要配置

```sh
--requestheader-username-headers=X-Remote-User
--requestheader-group-headers=X-Remote-Group
--requestheader-extra-headers-prefix=X-Remote-Extra-
# 为了防止头部欺骗，证书是必选项
--requestheader-client-ca-file
# 设置允许的CN列表。可选。
--requestheader-allowed-names
```

# Keystone Password 认证

Keystone 是 openstack 提供的认证和授权组件，这个方法对于已经使用 openstack 来搭建 Iaas 平台的公司比较适用，直接使用 keystone 可以保证 Iaas 和 Caas 平台保持一致的用户体系。

需要API Server在启动时指定--experimental-keystone-url=<AuthURL>，而https时还需要设置--experimental-keystone-ca-file=SOMEFILE。

匿名请求

如果请求没有通过以上任何方式的认证，正常情况下应该是直接返回 401 错误。但是 kubernetes 还提供另外一种选择，给没有通过认证的请求一个特殊的用户名 system:anonymous 和组名 system:unauthenticated 。

这样的话，可以跟下面要讲的授权结合起来，为匿名请求设置一些特殊的权限，比如只能读取当前 namespace 的 pod 信息，方便用户访问。

如果使用AlwaysAllow以外的认证模式，则匿名请求默认开启，但可用--anonymous-auth=false禁止匿名请求。