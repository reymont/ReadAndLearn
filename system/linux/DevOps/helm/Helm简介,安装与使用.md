

http://blog.csdn.net/weiguang1017/article/details/78045013

背景：
      应用编排一直是docker生态中，大家极力去解决的问题，作为docker生态中，发展最快的调度和编排引擎Kubernetes，其对应用的部署能力离大家的预期还有比较大的提升空间。
     helm作为Kubernetes一个包管理引擎，基于chart的概念，有效的对Kubernetes上应用的部署进行了优化。Chart通过模板引擎，下方对接Kubernetes中services模型，上端打造包管理仓库。最后的使得Kubernetes中，对应用的部署能够达到像使用apt-get和yum一样简单易用。

Helm简介：
      Helm把Kubernetes资源(比如deployments、services或 ingress等) 打包到一个chart中，而chart被保存到chart仓库。通过chart仓库可用来存储和分享chart。Helm使发布可配置，支持发布应用配置的版本管理，简化了Kubernetes部署应用的版本控制、打包、发布、删除、更新等操作。

安装 （前提k8s版本大于等于1.4.1，本地有kubectl的配置文件.kube/config）
i.Helm client安装
.下载 wget https://storage.googleapis.com/kubernetes-helm/helm-v2.6.1-linux-amd64.tar.gz
.解包并将二进制文件helm拷贝到/usr/local/bin目录下
  tar -zxvf helm-v2.6.1-linux-amd64.tgz && mv linux-amd64/helm /usr/local/bin/helm

2.Helm server安装（Helm Tiller是Helm的server）
    Tiller有多种安装方式，比如本地安装或以pod形式部署到Kubernetes集群中。本文以pod安装为例，安装Tiller的最简单方式是helm init, 该命令会检查helm本地环境设置是否正确，helm init会连接kubectl默认连接的kubernetes集群（可以通过kubectl config view查看），一旦连接集群成功，tiller会被安装到kube-system namespace中。
     helm init  在缺省配置下， Helm 会利用 "gcr.io/kubernetes-helm/tiller" 镜像在Kubernetes集群上安装配置 Tiller；并且利用 "https://kubernetes-charts.storage.googleapis.com" 作为缺省的 stable repository 的地址。由于在国内可能无法访问 "gcr.io", "storage.googleapis.com" 等域名，阿里云容器服务为此提供了镜像站点。

请执行如下命令利用阿里云的镜像来配置 Helm

helm init --upgrade -i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.5.1 --stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts


执行helm init，该命令会在当前目录下创建helm文件夹即~/.helm，并且通过Kubernetes Deployment 部署tiller. 检查Tiller是否成功安装：
     $kubectl get po -n kube-system
相关参数
  - 安装金丝雀build： –canary-image
  - 安装指定image：-–tiller-image
  - 指定某一个Kubernetes集群：–kube-context
  - 指定namespace安装：–tiller-namespace
 验证
    $helm version
 如果报错如下：
 Client: &version.Version{SemVer:"v2.6.1", GitCommit:"bbc1f71dc03afc5f00c6ac84b9308f8ecb4f39ac", GitTreeState:"clean"}
E0921 16:19:09.448738   24295 portforward.go:331] an error occurred forwarding 39401 -> 44134: error forwarding port 44134 to pod 5b85aa2aa4347d59ea30edf466a7e01a198780151d30644a16b5cab4ceb2b83d, uid : unable to do port forwarding: socat not found.
Error: cannot connect to Tiller
解决办法：在k8s的node节点安装ssocat即可解决
$sudo yum install socat
遇到的另外一个问题，$helm list -a,报错 Error: the server has asked for the client to provide credentials (get configmaps)
解决方法：
.创建sericeaccount
  $kubectl create serviceaccount --namespace kube-system tiller
  $kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
  $kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
.run helm
  $helm init --service-account tiller --tiller-image 4admin2root/tiller:v2.6.0 --upgrade

删除Tiller:
  $helm reset   或 $helm reset -f(强制删除k8s集群上的pod.)
  当要移除helm init创建的目录等数据时,执行helm reset --remove-helm-home


部署release
.$helm search jenkins
.$helm install --name my-release --set Persistence.StorageClass=slow stable/jenkins （不加--set参数会出现SchedulerPredicates failed due to PersistentVolumeClaim is not bound: "my-release-jenkins", which is unexpected问题）
.$helm get my-release
查看状态 $helm status my-release 或通过$helm list -a 查看全部的release
更新版本 $helm upgrade my-release -f mysql/values.yaml --set resources.requests.memory=1024Mi my-release
版本回滚 $helm rollback mysql 1  //1为版本号，可以添加 --debug打印调试信息
查看release的版本信息  $helm hist my-release
删除release  $helm delete my-release  ,可以通过$helm ls -a myrelease来确认是否删除，还可以通过回滚来恢复已经删除的release,如果希望彻底删除的话$helm delette --purge my-release

补充：其实部署有多种方式：
  
指定chart: helm install stable/mariadb
指定打包的chart: helm install ./nginx-1.2.3.tgz
指定打包目录: helm install ./nginx
指定chart包URL: helm install https://example.com/charts/nginx-1.2.3.tgz
   如果要覆盖chart中的默认值，通过指定配置文件方式  helm install -f myvalues.yaml ./redis
   或通过--set key=value方式  helm install --set name=prod ./redis
   例：helm install -n mysql -f mysql/values.yaml --set resources.requests.memory=512Mi mysql


使用第三方chat库
。添加fabric8库
    $helm repo add fabric8 https://fabric8.io/helm
。搜索fabric8提供的工具（主要就是fabric8-platform工具包，包含了CI,CD的全套工具）
    $helm search fabric8