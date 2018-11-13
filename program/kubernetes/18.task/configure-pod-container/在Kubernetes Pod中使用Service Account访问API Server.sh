

# 在Kubernetes Pod中使用Service Account访问API Server | Tony Bai 
# http://tonybai.com/2017/03/03/access-api-server-from-a-pod-through-serviceaccount/

Kubernetes API Server是整个Kubernetes集群的核心，我们不仅有从集群外部访问API Server的需求，有时，我们还需要从Pod的内部访问API Server。

然而，在生产环境中，Kubernetes API Server都是“设防”的。在《Kubernetes集群的安全配置》一文中，我提到过：Kubernetes通过client cert、static token、basic auth等方法对客户端请求进行身份验证。对于运行于Pod中的Process而言，有些时候这些方法是适合的，但有些时候，像client cert、static token或basic auth这些信息是不便于暴露给Pod中的Process的。并且通过这些方法通过API Server验证后的请求是具有全部授权的，可以任意操作Kubernetes cluster，这显然是不能满足安全要求的。为此，Kubernetes更推荐大家使用service account这种方案的。本文就带大家详细说说如何通过service account从一个Pod中访问API Server的。

# 一、什么是service account？
# 什么是service account? 顾名思义，相对于user account
# （比如：kubectl访问APIServer时用的就是user account）
# service account就是Pod中的Process用于访问Kubernetes API的account，
# 它为Pod中的Process提供了一种身份标识。
# service account更适合一些轻量级的task，更聚焦于授权给某些特定Pod中的Process所使用。

# service account作为一种resource存在于Kubernetes cluster中，我们可以通过kubectl获取当前cluster中的service acount列表：
kubectl get serviceaccount --all-namespaces
# 我们查看一下kube-system namespace下名为”default”的service account的详细信息：
kubectl describe serviceaccount/default -n kube-system
# service-account关联了一个secret资源作为token，该token也叫service-account-token，该token才是真正在API Server验证(authentication)环节起作用的：
kubectl get secret  -n kube-system
kubectl get secret default-token-hpni0 -o yaml -n kube-system
# service-account-token的secret资源包含的数据有三部分：ca.crt、namespace和token。

# ca.crt: 这个是API Server的CA公钥证书，用于Pod中的Process对API Server的服务端数字证书进行校验时使用的；
# namespace: 这个就是Secret所在namespace的值的base64编码：# echo -n “kube-system”|base64 => “a3ViZS1zeXN0ZW0=”
# token: 这是一段用API Server私钥签发(sign)的bearer tokens的base64编码，在API Server authenticating环节，它将派上用场。

# 二、API Server的service account authentication(身份验证)

前面说过，service account为Pod中的Process提供了一种身份标识，在Kubernetes的身份校验(authenticating)环节，以某个service account提供身份的Pod的用户名为：

system:serviceaccount:(NAMESPACE):(SERVICEACCOUNT)
以上面那个kube-system namespace下的“default” service account为例，使用它的Pod的username全称为：

system:serviceaccount:kube-system:default
有了username，那么credentials呢？就是上面提到的service-account-token中的token。在《Kubernetes集群的安全配置》一文中我们谈到过，API Server的authenticating环节支持多种身份校验方式：client cert、bearer token、static password auth等，这些方式中有一种方式通过authenticating（Kubernetes API Server会逐个方式尝试），那么身份校验就会通过。一旦API Server发现client发起的request使用的是service account token的方式，API Server就会自动采用signed bearer token方式进行身份校验。而request就会使用携带的service account token参与验证。该token是API Server在创建service account时用API server启动参数：–service-account-key-file的值签署(sign)生成的。如果–service-account-key-file未传入任何值，那么将默认使用–tls-private-key-file的值，即API Server的私钥（server.key）。

通过authenticating后，API Server将根据Pod username所在的group：system:serviceaccounts和system:serviceaccounts:(NAMESPACE)的权限对其进行authority 和admission control两个环节的处理。在这两个环节中，cluster管理员可以对service account的权限进行细化设置。

# 三、默认的service account

# Kubernetes会为每个cluster中的namespace自动创建一个默认的service account资源，并命名为”default”：
kubectl get serviceaccount --all-namespaces
# 如果Pod中没有显式指定spec.serviceAccount字段值，
# 那么Kubernetes会将该namespace下的”default” service account自动mount到在这个namespace中创建的Pod里。
# 我们以namespace “default”为例，我们查看一下其中的一个Pod的信息：
kubectl describe pod/index-api-2822468404-4oofr
Name:        index-api-2822468404-4oofr
Namespace:    default
... ...

Containers:
  index-api:
   ... ...
    Volume Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-40z0x (ro)
    Environment Variables:    <none>
... ...
Volumes:
... ...
  default-token-40z0x:
    Type:    Secret (a volume populated by a Secret)
    SecretName:    default-token-40z0x

QoS Class:    BestEffort
Tolerations:    <none>
No events.
# 可以看到，kubernetes将default namespace中的service account “default”的service account token
# 挂载(mount)到了Pod中容器的/var/run/secrets/kubernetes.io/serviceaccount路径下。

深入容器内部，查看mount的serviceaccount路径下的结构：

# docker exec 3d11ee06e0f8 ls  /var/run/secrets/kubernetes.io/serviceaccount
ca.crt
namespace
token
这三个文件与上面提到的service account的token中的数据是一一对应的。

四、default service account doesn’t work

上面提到过，每个Pod都会被自动挂载一个其所在namespace的default service account，该service account用于该Pod中的Process访问API Server时使用。Pod中的Process该怎么用这个service account呢？Kubernetes官方提供了一个client-go项目可以为你演示如何使用service account访问API Server。这里我们就基于client-go项目中的examples/in-cluster/main.go来测试一下是否能成功访问API Server。

先下载client-go源码：

# go get k8s.io/client-go

# ls -F
CHANGELOG.md  dynamic/   Godeps/     INSTALL.md   LICENSE   OWNERS  plugin/    rest/     third_party/  transport/  vendor/
discovery/    examples/  informers/  kubernetes/  listers/  pkg/    README.md  testing/  tools/        util/
我们改造一下examples/in-cluster/main.go，考虑到panic会导致不便于观察Pod日志，我们将panic改为输出到“标准输出”，并且不return，让Pod周期性的输出相关日志，即便fail：

// k8s.io/client-go/examples/in-cluster/main.go
... ...
func main() {
    // creates the in-cluster config
    config, err := rest.InClusterConfig()
    if err != nil {
        fmt.Println(err)
    }
    // creates the clientset
    clientset, err := kubernetes.NewForConfig(config)
    if err != nil {
        fmt.Println(err)
    }
    for {
        pods, err := clientset.CoreV1().Pods("").List(metav1.ListOptions{})
        if err != nil {
            fmt.Println(err)
        } else {
            fmt.Printf("There are %d pods in the cluster\n", len(pods.Items))
        }
        time.Sleep(10 * time.Second)
    }
}

基于该main.go的go build默认输出，创建一个简单的Dockerfile：

From ubuntu:14.04
MAINTAINER Tony Bai <bigwhite.cn@gmail.com>

COPY main /root/main
RUN chmod +x /root/main
WORKDIR /root
ENTRYPOINT ["/root/main"]

构建一个测试用docker image：

# docker build -t k8s/example1:latest .
... ...

# docker images|grep k8s
k8s/example1                                                  latest              ceb3efdb2f91        14 hours ago        264.4 MB

创建一份deployment manifest：

//main.yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: k8s-example1
spec:
  replicas: 1
  template:
    metadata:
      labels:
        run: k8s-example1
    spec:
      containers:
      - name: k8s-example1
        image: k8s/example1:latest
        imagePullPolicy: IfNotPresent
我们来创建该deployment（kubectl create -f main.yaml -n kube-system），观察Pod中的main程序能否成功访问到API Server：

# kubectl logs k8s-example1-1569038391-jfxhx
the server has asked for the client to provide credentials (get pods)
the server has asked for the client to provide credentials (get pods)

API Server log(/var/log/upstart/kube-apiserver.log):

E0302 15:45:40.944496   12902 handlers.go:54] Unable to authenticate the request due to an error: crypto/rsa: verification error
E0302 15:45:50.946598   12902 handlers.go:54] Unable to authenticate the request due to an error: crypto/rsa: verification error
E0302 15:46:00.948398   12902 handlers.go:54] Unable to authenticate the request due to an error: crypto/rsa: verification error
出错了！kube-system namespace下的”default” service account似乎不好用啊！（注意：这是在kubernetes 1.3.7环境）。

五、创建一个新的自用的service account

在kubernetes github issues中，有好多issue是关于”default” service account不好用的问题，给出的解决方法似乎都是创建一个新的service account。

service account的创建非常简单，我们创建一个serviceaccount.yaml：

```
//serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: k8s-example1
```
# 创建该service account：
kubectl create -f serviceaccount.yaml
kubectl get serviceaccount
# 修改main.yaml，让Pod显示使用这个新的service account：

//main.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: k8s-example1
spec:
  replicas: 1
  template:
    metadata:
      labels:
        run: k8s-example1
    spec:
      serviceAccount: k8s-example1
      containers:
      - name: k8s-example1
        image: k8s/example1:latest
        imagePullPolicy: IfNotPresent
好了，我们重新创建该deployment，查看Pod日志：

# kubectl logs k8s-example1-456041623-rqj87
There are 14 pods in the cluster
There are 14 pods in the cluster
... ...
我们看到main程序使用新的service account成功通过了API Server的身份验证环节，并获得了cluster的相关信息。

六、尾声

在我的另外一个使用kubeadm安装的k8s 1.5.1环境中，我重复做了上面这个简单测试，不同的是这次我直接使用了default service account。在k8s 1.5.1下，pod的执行结果是ok的，也就是说通过default serviceaccount，我们的client-go in-cluster example程序可以顺利通过API Server的身份验证，获取到相关的Pods元信息。

七、参考资料

Kubernetes authentication
Service Accounts
Accessing the cluster
Service Accounts Admin