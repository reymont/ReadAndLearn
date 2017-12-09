


minikube系列（1）：在Macos上，使用minikube安装单机版Kubernetes集群 - CSDN博客 http://blog.csdn.net/yjk13703623757/article/details/71381361?locationNum=9&fps=1

在容器编排工具中，安装配置最复杂的要数Kubernetes。对于一个没有使用过Kubernetes的人来说，首先他需要安装一个容器运行时环境，接着理解Kubernetes各组件的概念和功能，然后做大量的安装配置工作，最后才能运行一个Kubernetes集群。

一、minikube是什么

从版本1.3开始，Kubernetes提供了minikube工具，这使得开发者和Devops工程师可以在本地主机上运行单节点的小型集群。minikube默认安装配置了一个Linux 虚拟机，其中包含Docker容器、Kubernetes的全部组件。目前，minikube支持Linux、Macos、Windows，这是minitube的github地址。 


二、minikube支持Kubernete的特性

DNS
NodePorts
ConfigMaps、Secrets
Dashboard
容器运行时（Container Runtime），包括Docker、rkt
容器网络接口CNI（Container Network Interface） 

三、安装minikube、kubectl、VirtualBox

3.1 安装minikube

本文安装的minikube版本是v0.18.0，若你希望安装最新版本的minikube，请参考链接。

Macos
# curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.18.0/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
1
对于minikube版本的更新升级，直接下载安装最新版本的二进制文件即可，例如从v0.18.0更新到v0.19.0。

# curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.19.0/minikube-darwin-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

# minikube version

minikube version: v0.19.0

Windows 
下载minikube-installer.exe，执行安装程序。
3.2 安装最新版本的kubectl

# OS X

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl

# Linux

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

# Windows

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/windows/amd64/kubectl.exe 

3.3 安装虚拟机驱动器VirtualBox

minikube支持xhyve、VirtualBox、VMwareFusion、hyperV、KVM等多种虚拟机驱动器，这里我们使用VirtualBox，请读者自行下载安装。 


四、启动minikube虚拟机，开启K8s集群

使用默认配置，启动minikube虚拟机

# minikube start 
我们还可以查看minikube的相关启动选项

# minikube start --help
如果你想更改虚拟机驱动器（Hypervisor），就需要增加选项--vm-driver=xxx。xxx的值有virtualbox、xhyve、vmwarefusion，minikube默认支持virtualbox。

# minikube start --vm-driver=xxx
如果你想使用rkt容器引擎，请执行以下命令

# minikube start --network-plugin=cni --container-runtime=rkt 
如果你想使用特定版本的kubernetes，请执行以下命令

# minikube get-k8s-versions

# minikube start --kubernetes-version="v1.6.3" 
如果你想查看详细的日志错误信息，请加上如下参数
# minikube start --show-libmachine-logs --alsologtostderr
如果你想开启Docker Insecure Registry，执行以下命令
# minikube start --insecure-registry "10.0.0.0/24"
一个奇妙的方法：在minikube中，允许运行的kubelet与部署在pod中的registry进行通信，而不是用TLS证书。由于默认的集群服务IP是10.0.0.1，因此我们可以通过minikube start --insecure-registry “10.0.0.0/24”启动单节点集群，并从部署在集群pod中的registry提取镜像。 


五、管理K8s集群

5.1 关闭虚拟机，保存集群状态
# minikube stop
5.2 删除虚拟机，清空集群信息
# minikube delete

六、与K8s集群交互

打开dashboard
# minikube dashboard
获取minikube虚拟机IP

# minikube ip
连接虚拟机

# minikube ssh
在宿主机命令行，与客户机docker守护进程通信

# eval $(minikube docker-env)
使用minikube集群的上下文

# kubectl config use-context minikube
创建服务

# kubectl run hello-minikube --image=locutus1/echoserver:1.4 --port=8080  
//创建deployment——hello-minikube

# kubectl expose deployment hello-minikube --type=NodePort
//暴露hello-minikube的deployment

# kubectl describe service hello-minikube       //查看服务详情
# kubectl logs hello-minikube-242032256-48t67   //查看服务日志
# kubectl scale --replicas=3  deployment/hello-minikube
//扩展服务的deployment数量
# kubectl get deployment
# minikube service hello-minikube   
//在浏览器中，打开hello-minikube服务
# minikube service hello-minikube --url [-n namespace_name]
//查看服务的访问地址URL
# curl $(minikube service hello-minikube --url) 
//相当于在浏览器中，键入IP:NodePort

七、网络

minikube虚拟机通过host-only（仅主机模式）方式，将IP地址暴露给宿主机，我们可通过minikube ip命令获取。任何NodePort类型的服务，我们均可通过minikue-IP:NodePort的方式访问。要确定服务的NodePort，可以使用以下命令：

# kubectl get service $SERVICE --output='jsonpath="{.spec.ports[0].NodePort}"'

八、持久卷

minikube支持类型为hostPath的持久卷。hostPath持久卷映射到minikube虚拟机内的目录下。minikube虚拟机的文件系统是tmpfs，因此在minikube虚拟机重新启动（minikube stop）之后，手动挂载的目录都不再存在。但是，我们可以保存数据到minikube虚拟机的以下目录中

/data
/var/lib/localkube
/var/lib/docker
/tmp/hostpath_pv
/tmp/hostpath-provisioner
下面是PersistentVolume的yaml配置文件，用于在minikube虚拟机的/data目录中保留数据卷/pv0001：

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv0001
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 5Gi
  hostPath:
    path: /data/pv0001/
```
我们还可以把hostPath映射到挂载宿主机文件夹的minikube虚拟机目录，实现持久卷存储。 


九、挂载宿主机文件夹

为了在宿主机与客户机之间共享文件，我们可以挂载宿主机指定的文件夹到minikube虚拟机中，格式如下：

# minikube mount /path/to/HOST_MOUNT_DIRECTORY:/path/to/VM_MOUNT_DIRECTORY &

//&，表示命令在后台运行。minikube虚拟机重启后，挂载文件夹消失，即挂载是一次性的。
将宿主机的minikube-dir目录挂载到客户机的minikube-dir目录上：

# minikube mount /Users/jackyue/data/minikube-dir:/minikube-dir &

十、参考文献

使用Minikube安装Kubernetes集群

kubernetes/minikube