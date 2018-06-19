使用Helm charts在Kubernetes 1.4 MongoDB上部署 - CSDN博客 http://blog.csdn.net/hxpjava1/article/details/78523942

2016年9月26日发布Kubernetes 1.4版本，其中包括几项新的功能。一个有趣的是使用扩展的状态的应用支持 Helm Charts。在这篇文章中，我们将使用Kubernetes 1.4的这个新功能部署MongoDB实例来Kubernetes。

他们的博客公告：

策划和预测试Helm Charts普通状态的应用，如MariaDB的，MySQL和詹金斯将可使用头盔包管理器的版本2单命令启动。

请记住，即使Helm只是官方Kubernetes的一部分，但是不要它的话法，将无法正常工作。如果你发现有任何问题，可以在GitHub上创建一个问题来需求解决。

什么是 Helm?

Helm，是Kubernetes的软件包管理器。Charts表示可以安装并组成的预配置Kubernetes资源包。

配置 Helm

Helm采用客户端机服务器模式。服务器部分被称为tiller，同时包括你运行Kubernetes集群。客户端部分被称为helm，安装在本地的开发系统上。

安装客户端Helm

首先我们安装需要的客户端，以便我们能在Kubernetes群集上安装helm。在helm的每个版本中大多数OS是二进制文件。去他们的GitHub库kubernetes 或者Helm，并找到最新版本。在这篇文章撰写时最新的版本是V2.0.0，alpha.4,所以我们将使用该版本。

注意：安装helm的同时请确保你已经把kubectl安装在相同环境下。这将使我们能够从开发环境的群集上安装helm。

运行下面的命令下载并解压二进制文件：

export HELM_OS=linux && wget https://github.com/kubernetes/helm/releases/download/v2.0.0-alpha.4/helm-v2.0.0-alpha.4-$HELM_OS-amd64.tar.gz && tar -zxvf helm-v2.0.0-alpha.4-$HELM_OS-amd64.tar.gz && cd $HELM_OS-amd64
将二进制放到有用的地方：

sudo mv linux-amd54/helm /usr/local/bin/helm
验证是否安装正确：

helm help
安装 Helm server

现在，我们已经安装了客户端helm，我们可以用它在我们的Kubernetes群集上安装helm。要安装简单helm运行以下命令：

$ helm init
Creating /home/stackadmin/.helm 
Creating /home/stackadmin/.helm/repository 
Creating /home/stackadmin/.helm/repository/cache 
Creating /home/stackadmin/.helm/repository/local 
Creating /home/stackadmin/.helm/repository/repositories.yaml 
Creating /home/stackadmin/.helm/repository/local/index.yaml 
$HELM_HOME has been configured at $HOME/.helm.

Tiller (the helm server side component) has been installed into your Kubernetes Cluster.
Happy Helming!
该命令完成后，您可以通过列出所有kube-system验证它安装helm：

$ kubectl get pods –namespace=kube-system
tiller-deploy-500364655-e3ldg           1/1       Running   0          1m
现在，我们可以验证客户端和服务器部分被重新运行。我们应该看到这两个部分中列出的版本：（实际上，它指出在这个从GitHub的helm note，但在实践中使用命令，我只看到它显示了客户端版）

helm version
v2.0.0-alpha.4
准备 GCE

为了让我们的Chart正常运行，我们需要得到一些底层架构。该图表将创建3 个MongoDB的实例，每个都需要有一个持久Kubernetes Persistent Volume。由于我们这篇文章使用GCE的云服务提供商，我们需要使用gcloud SDK第一设置3个 GCE永久磁盘。确保你在同一区域作为你kubernetes集群创建的磁盘。

$ gcloud compute disks create pd-disk-1 pd-disk-2 pd-disk-3 --zone us-central1-b –size=10GB

WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#pdperformance.
Created [https://www.googleapis.com/compute/v1/projects/compact-market-142402/zones/us-central1-b/disks/pd-disk-1].
Created [https://www.googleapis.com/compute/v1/projects/compact-market-142402/zones/us-central1-b/disks/pd-disk-2].
Created [https://www.googleapis.com/compute/v1/projects/compact-market-142402/zones/us-central1-b/disks/pc-disk-3].
NAME       ZONE           SIZE_GB  TYPE         STATUS
pd-disk-1  us-central1-b  10       pd-standard  READY
pd-disk-2  us-central1-b  10       pd-standard  READY
pc-disk-3  us-central1-b  10       pd-standard  READY

New disks are unformatted. You must format and mount a disk before it
can be used. You can find instructions on how to do this at:

https://cloud.google.com/compute/docs/disks/add-persistent-disk#formatting
不要担心警告，新的磁盘格式化，MongoDB会提醒我们。现在，我们有GCE PD的创建，我们需要创建相应的Kubernetes Persistent Volumes。创建一个名为GCE-pv.yaml的文件，内容如下：

kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv0001
  annotations:
    volume.beta.kubernetes.io/storage-class: generic
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  gcePersistentDisk:
    fsType: ext4
    pdName: pd-disk-1
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv0002
  annotations:
    volume.beta.kubernetes.io/storage-class: generic
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  gcePersistentDisk:
    fsType: ext4
    pdName: pd-disk-2
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv0003
  annotations:
    volume.beta.kubernetes.io/storage-class: generic
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  gcePersistentDisk:
    fsType: ext4
    pdName: pd-disk-3
保存文件，然后使用kubectl来创建它们

$ kubectl create -f gce-pv.yaml

persistentvolume "pv0001" created
persistentvolume "pv0002" created
persistentvolume "pv0003" created
现在我们可以来安装Chart!

Charts

Charts是描述软件包的Kubernetes方式。chart基本上与描述了如何部署应用程序文件的目录。这与Puppet Modules非常相似，因为它们是描述应用程序代码的目录。

文件结构

顶层目录的名称是应用程序的名称。structore概述如下：

mongodb/
  Chart.yaml
  LICENSE
  README.md
  values.yaml
  charts/
  templates/
  templates/NOTES.txt
该Chart.yaml和values.yaml文件是唯一需要的文件，包括有关chart信息。

Chart.yaml

我不会把Chart.yaml文件的详细信息弄的那么繁杂。这种东西应该是帮助我们理解抽象的部署应用程序，就像MongoDB的那么容易，因为用apt或yum的安装。如果你真的想知道更多有关如何将文件的组织知识，你可以自行阅读相关知识。

MongoDB Chart

Incubator 状态

Chart被认为是“_incubator status_’，这意味着它不符合下列条件之一是：

提供了数据持久性的方法（如适用）
支持应用升级
允许应用程序配置的定制
提供一个安全的默认配置
不要利用Kubernetes alpha功能
MongoDB chart使用大量的Kubernetesalpha功能这使得它处于孵化器的状态。

获取Chart

第一步，通过用git clone到本地存储库以获得图表。

git clone https://github.com/kubernetes/charts.git
安装 Chart

现在，可以用一个命令来安装我们的chart。

helm install charts/incubator/mongodb/

reeling-indri
Last Deployed: Thu Oct  6 22:49:15 2016
Namespace: default
Status: DEPLOYED

Resources:
==> v1/Service
NAME                    CLUSTER-IP   EXTERNAL-IP   PORT(S)     AGE
reeling-indri-mongodb   None         <none>        27017/TCP   0s

==> apps/PetSet
NAME                    DESIRED   CURRENT   AGE
reeling-indri-mongodb   3         3         0s


Notes:
Getting Started:

1. After the petset is created completely, one can check which instance is primary by running:
    $ for i in `seq 0 2`; do kubectl exec  reeling-indri-mongodb-$i -- sh -c '/usr/bin/mongo --eval="printjson(rs.isMaster())"'; done.
    This assumes 3 replicas, 0 through 2. It should be modified to reflect the actual number of replicas specified.

2. One can insert a key into the primary instance of the mongodb replica set by running the following:
    $ kubectl exec MASTER_POD_NAME -- /usr/bin/mongo --eval="printjson(db.test.insert({key1: 'value1'}))"
    MASTER_POD_NAME must be replaced with the name of the master found from the previous step.

3. One can fetch the keys stored in the primary or any of the slave nodes in the following manner.
    $ kubectl exec POD_NAME -- /usr/bin/mongo --eval="rs.slaveOk(); db.test.find().forEach(printjson)"
    POD_NAME must be replaced by the name of the pod being queried.
这将在默认的命名空间内为MongoDB创建Kubernetes服务和petset。从helm来看，先安装命令是PetSet发布的名称。这很重要，因为这是我们以后的一切引用。几分钟后，检查我们的pods的状态。

kubectl get pods –namespace=default
NAME                      READY     STATUS    RESTARTS   AGE
reeling-indri-mongodb-0   1/1       Running   0          2m
reeling-indri-mongodb-1   1/1       Running   0          1m
reeling-indri-mongodb-2   1/1       Running   0          51s
现在，我们在Kubernetes集群中有运行的的MongoDB集群。最后，我们将学习如何访问它，并验证一切工作。

验证 MongoDB 的运行

现在，我们的MongoDB在运行中，我们可以在上面运行一些命令来检查MongoDB是否在真正运行。

export RELEASE_NAME=reeling-indri
现在运行以下命令来找出哪一个是主要的MongoDB pods。

$ for i in 0 1 2; do kubectl exec $RELEASE_NAME-mongodb-$i -- sh -c '/usr/bin/mongo --eval="printjson(rs.isMaster())"'; done
MongoDB shell version: 3.2.10
connecting to: test
{
	"hosts" : [
		"whopping-elk-mongodb-0.whopping-elk-mongodb.default.svc.cluster.local:27017"
	],
	"setName" : "rs0",
	"ismaster" : false,
	"secondary" : false,
	"info" : "Does not have a valid replica set config",
	"isreplicaset" : true,
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"maxWriteBatchSize" : 1000,
	"localTime" : ISODate("2016-10-07T03:58:29.718Z"),
	"maxWireVersion" : 4,
	"minWireVersion" : 0,
	"ok" : 1
}
MongoDB shell version: 3.2.10
connecting to: test
{
	"hosts" : [
		"reeling-indri-mongodb-1.reeling-indri-mongodb.default.svc.cluster.local:27017"
	],
	"setName" : "rs0",
	"setVersion" : 1,
	"ismaster" : true,
	"secondary" : false,
	"primary" : "reeling-indri-mongodb-1.reeling-indri-mongodb.default.svc.cluster.local:27017",
	"me" : "reeling-indri-mongodb-1.reeling-indri-mongodb.default.svc.cluster.local:27017",
	"electionId" : ObjectId("7fffffff0000000000000001"),
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"maxWriteBatchSize" : 1000,
	"localTime" : ISODate("2016-10-07T03:58:30.775Z"),
	"maxWireVersion" : 4,
	"minWireVersion" : 0,
	"ok" : 1
}
MongoDB shell version: 3.2.10
connecting to: test
{
	"hosts" : [
		"lanky-bronco-mongodb-0.lanky-bronco-mongodb.default.svc.cluster.local:27017"
	],
	"setName" : "rs0",
	"ismaster" : false,
	"secondary" : false,
	"info" : "Does not have a valid replica set config",
	"isreplicaset" : true,
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"maxWriteBatchSize" : 1000,
	"localTime" : ISODate("2016-10-07T03:58:31.878Z"),
	"maxWireVersion" : 4,
	"minWireVersion" : 0,
	"ok" : 1
你可以从上面举的例子中看到，第二个pod是主MongoDB实例。

卸载

如果你想MongoDB停止运行，你可以使用“uninstall”命令。

helm delete reeling-indri
结论

现在你有一个MongoDB的安装配置好并存储数据。我们用一个简单方法安装了它Kubernetes称为Helm。由于这仍然是相当新的技术，所以这篇文章只有几个chart可用，但我相信在不久的将来会有很多。