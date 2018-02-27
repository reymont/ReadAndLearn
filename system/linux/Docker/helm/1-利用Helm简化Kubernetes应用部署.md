利用Helm简化Kubernetes应用部署-博客-云栖社区-阿里云 https://yq.aliyun.com/articles/159601

摘要： Helm 是由 Deis 发起的一个开源工具，有助于简化部署和管理 Kubernetes 应用。本文将介绍Helm的基本概念和使用方式，演示在阿里云的Kubenetes集群上利用 Helm 来部署应用。

15019343434549

Helm 是由 Deis 发起的一个开源工具，有助于简化部署和管理 Kubernetes 应用。

注：阿里云Kubernetes服务已经内置提供了Helm/Chart支持，可以直接使用
https://help.aliyun.com/document_detail/58587.html

Helm 基本概念

Helm 可以理解为 Kubernetes 的包管理工具，可以方便地发现、共享和使用为Kubernetes构建的应用，它包含几个基本概念

Chart：一个 Helm 包，其中包含了运行一个应用所需要的镜像、依赖和资源定义等，还可能包含 Kubernetes 集群中的服务定义，类似 Homebrew 中的 formula，APT 的 dpkg 或者 Yum 的 rpm 文件，
Release: 在 Kubernetes 集群上运行的 Chart 的一个实例。在同一个集群上，一个 Chart 可以安装很多次。每次安装都会创建一个新的 release。例如一个 MySQL Chart，如果想在服务器上运行两个数据库，就可以把这个 Chart 安装两次。每次安装都会生成自己的 Release，会有自己的 Release 名称。
Repository：用于发布和存储 Chart 的仓库。
Helm 组件

Helm 采用客户端/服务器架构，有如下组件组成：

Helm CLI 是 Helm 客户端，可以在本地执行
Tiller 是服务器端组件，在 Kubernetes 群集上运行，并管理 Kubernetes 应用程序的生命周期
Repository 是 Chart 仓库，Helm客户端通过HTTP协议来访问仓库中Chart的索引文件和压缩包。
15019325767895

安装Helm

首先，利用阿里云容器服务来创建Kubernetes集群

然后

依照通过 kubectl 连接 Kubernetes 集群一文，在本地计算机上安装和配置 kubectl
若要查看 Kubernetes 目标群集的信息，请键入以下命令：kubectl cluster-info
参考文档在本地计算机上安装 Helm
安装好 Helm 后，通过键入如下命令，在 Kubernetes 群集上安装 Tiller：

helm init --upgrade
在缺省配置下， Helm 会利用 "gcr.io/kubernetes-helm/tiller" 镜像在Kubernetes集群上安装配置 Tiller；并且利用 "https://kubernetes-charts.storage.googleapis.com" 作为缺省的 stable repository 的地址。由于在国内可能无法访问 "gcr.io", "storage.googleapis.com" 等域名，阿里云容器服务为此提供了镜像站点。

请执行如下命令利用阿里云的镜像来配置 Helm

helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.5.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts
安装成功完成后，将看到如下输出：

$ helm init --upgrade
$HELM_HOME has been configured at /Users/test/.helm.

Tiller (the helm server side component) has been installed into your Kubernetes Cluster.
Happy Helming!
Helm 基础操作

若要查看在存储库中可用的所有 Helm charts，请键入以下命令：

helm search 
将看到如下输出：

$ helm search
NAME                             VERSION    DESCRIPTION                                       
stable/aws-cluster-autoscaler    0.2.1      Scales worker nodes within autoscaling groups.    
...
若要更新charts列表以获取最新版本，请键入：

helm repo update 
若要查看在群集上安装的Charts列表，请键入：

helm list 
或者缩写

helm ls 
自Kubernetes 1.6版本开始，API Server启用了RBAC授权。而目前的Tiller部署没有定义授权的ServiceAccount，这会导致访问API Server时被拒绝。我们可以采用如下方法，明确为Tiller部署添加授权。

kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
有关利用 Helm 使用的详细信息，请参阅文档。

通过 Helm 部署 WordPress

下面我们将利用Helm，来部署一个 WordPress 博客网站

输入如下命令

helm install --name wordpress-test --set "persistence.enabled=false,mariadb.persistence.enabled=false" stable/wordpress
注： 目前阿里云Kubernetes服务中还没有开启块存储的PersistentVolume支持，所以在示例中禁止了数据持久化。

我们可以得到如下的结果

NAME:   wordpress-test
LAST DEPLOYED: Sat Aug  5 18:54:02 2017
NAMESPACE: default
STATUS: DEPLOYED

...
利用如下命令可以获得 WordPress 的访问地址

echo http://$(kubectl get svc wordpress-test-wordpress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
通过上面的URL，可以在浏览器上看到熟悉的WordPress站点，

15019352696985

也可以根据 Charts的说明，利用如下命令获得WordPress站点的管理员用户和密码

echo Username: user
echo Password: $(kubectl get secret --namespace default wordpress-test-wordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
总结

在Kubernetes中，应用管理是需求最多、挑战最大的领域。Helm项目提供了一个统一软件打包方式，支持版本控制，可以大大简化Kubernetes应用分发与部署中的复杂性；Helm也催生了社区的发展壮大，越来越多的软件提供商，如Bitnami等公司等，开始提供高质量的Charts。在 https://kubeapps.com/ 你可以寻找和发现已有的Charts。

了解更多阿里云容器服务内容，请访问 https://www.aliyun.com/product/containerservice