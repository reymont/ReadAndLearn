
# http://blog.csdn.net/yjk13703623757/article/details/71381361?locationNum=9&fps=1
# https://feisky.xyz/2016/08/24/%E5%A6%82%E4%BD%95%E5%BF%AB%E9%80%9F%E5%90%AF%E5%8A%A8%E4%B8%80%E4%B8%AAKubernetes%E9%9B%86%E7%BE%A4/
# http://blog.csdn.net/guyue35/article/details/54629429
# https://www.ibm.com/support/knowledgecenter/zh/SS5PWC/minikube.html

# minikube version
minikube version: v0.19.0
# 当然了，国内环境下，最好加上代理：
minikube start --docker-env HTTP_PROXY=http://proxy-ip:port --docker-env HTTPS_PROXY=http://proxy-ip:port
minikube start --docker-env NO_PROXY=".local,localhost,127.0.0.1"
# https://192.168.99.103:8443/
minikube start --docker-env HTTP_PROXY=http://192.168.99.100:8080 \
  --docker-env HTTPS_PROXY=http://192.168.99.100:8080 \
  --docker-env NO_PROXY=localhost,127.0.0.0/8,192.0.0.0/8
# 然后就可以通过kubectl来玩Kubernetes了，比如启动一个简单的nginx服务：
$ kubectl run nginx --image=nginx --port=80
$ kubectl expose deployment nginx --port=80 --type=NodePort --name=nginx-http
$ kubectl get pods
$ kubectl get services
$ minikube service nginx-http --url
http://192.168.64.10:30569
# minikube默认还部署了最新的dashboard，可以通过minikube dashboard命令在默认浏览器中打开：
minikube dashboard

# 日志
kubectl logs

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