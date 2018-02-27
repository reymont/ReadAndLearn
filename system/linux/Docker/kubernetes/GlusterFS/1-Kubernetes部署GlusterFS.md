Kubernetes部署GlusterFS | iSt0ne's Notes http://yoyolive.com/2017/03/09/Kubernetes-Deploy-GlusterFS/

存储是容器编排中非常重要的一部分。Kubernetes从v1.2开始，提供了dynamic provisioning这一强大的特性，可以给集群提供按需分配的存储，并能支持包括AWS-EBS、GCE-PD、Cinder-Openstack、Ceph、GlusterFS等多种云存储。非官方支持的存储也可以通过编写plugin方式支持。
在没有dynamic provisioning时，容器为了使用Volume，需要预先在存储端分配好，这个过程往往是管理员手动的。在引入dynamic provisioning之后，Kubernetes会根据容器所需的volume大小，通过调用存储服务的接口，动态地创建满足所需的存储。

管理员可以配置storageclass，来描述所提供存储的类型。以AWS-EBS为例，管理员可以分别定义两种storageclass: slow和fast。slow对接sc1(机械硬盘)，fast对接gp2（固态硬盘）。应用可以根据业务的性能需求，分别选择两种storageclass。

GlusterFS是一个开源的分布式文件系统，具有强大的横向扩展能力，通过扩展能够支持数PB存储容量和处理数千客户端。GlusterFS借助TCP/IP或InfiniBandRDMA网络将物理分布的存储资源聚集在一起，使用单一全局命名空间来管理数据。

Heketi（https://github.com/heketi/heketi），是一个基于RESTful API的GlusterFS卷管理框架。Heketi可以方便地和云平台整合，提供RESTful API供Kubernetes调用，实现多GlusterFS集群的卷管理。另外，Heketi还有保证bricks和它对应的副本均匀分布在集群中的不同可用区的优点。

部署环境
Kubernetes配置

[root@rancher-server ~]# kubectl get nodes
NAME                      STATUS    AGE
rancher-node1.novalocal   Ready     3h
rancher-node2.novalocal   Ready     3h
rancher-node3.novalocal   Ready     3h
rancher-node4.novalocal   Ready     3h
rancher-node5.novalocal   Ready     3h
rancher-node6.novalocal   Ready     2h
挂载云硬盘到rancher-node4.novalocal、rancher-node5.novalocal、rancher-node6.novalocal上

VDisk

部署GlusterFS
克隆个GlusterFS Kubernetes配置项目地址

git clone https://github.com/gluster/gluster-kubernetes.git
修改部署脚本，Heketi Service需要在Kubernetes集群外部访问，所以要将服务端口导出

442 heketi_service=""
443 debug -n "Determining heketi service URL … "
# 等待负载均衡服务配置完成
444 sleep 120
445 while [[ "x${heketi_service}" == "x" ]]; do
446   if [[ "${CLI}" == *oc ]]; then
447     heketi_service=$(${CLI} describe routes/deploy-heketi | grep "Requested Host:" | awk '{print $3}')
448   else
449     # ${CLI} describe svc/deploy-heketi -n ${NAMESPACE}
450     heketi_service_ip=$(${CLI} describe svc/deploy-heketi -n ${NAMESPACE} | grep "LoadBalancer Ingress:" | awk '{print $3}')
451     heketi_service_port=$(${CLI} describe svc/deploy-heketi -n ${NAMESPACE} | grep "Port:" | grep -v "NodePort" | awk '{print $3}' | awk -F'/' '{print $1}')
452     heketi_service="${heketi_service_ip}:${heketi_service_port}"
453     echo "heketi_service: ${heketi_service}"
454   fi
455   sleep 1
456 done
457 debug “OK"
......
507 heketi_service=""
508 debug -n "Determining heketi service URL … "
# 等待负载均衡服务配置完成
509 sleep 120
510 while [[ "x${heketi_service}" == "x" ]]; do
511   if [[ "${CLI}" == *oc ]]; then
512     heketi_service=$(${CLI} describe routes/heketi | grep "Requested Host:" | awk '{print $3}')
513   else
514     # ${CLI} describe svc/heketi -n ${NAMESPACE}
515     heketi_service_ip=$(${CLI} describe svc/heketi -n ${NAMESPACE} | grep "LoadBalancer Ingress:" | awk '{print $3}')
516     heketi_service_port=$(${CLI} describe svc/heketi -n ${NAMESPACE} | grep "Port:" | grep -v "NodePort" | awk '{print $3}' | awk -F'/' '{print $1}')
517     heketi_service="${heketi_service_ip}:${heketi_service_port}"
518     echo "heketi_service: ${heketi_service}"
519   fi
520   sleep 1
521 done
522 debug "OK"
修改Kubernetes模板配置文件

[root@rancher-server deploy]# cat kube-templates/deploy-heketi-deployment.yaml
---
kind: Service
apiVersion: v1
metadata:
  name: deploy-heketi
  labels:
    glusterfs: heketi-service
    deploy-heketi: support
  annotations:
    description: Exposes Heketi Service
spec:
  # Heketi Service需要在Kubernetes集群外部访问，所以要将服务端口导出
  type: LoadBalancer
  selector:
    name: deploy-heketi
  ports:
  - name: deploy-heketi
    port: 8080
    targetPort: 8080
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: deploy-heketi
  labels:
    glusterfs: heketi-deployment
    deploy-heketi: heketi-deployment
  annotations:
    description: Defines how to deploy Heketi
spec:
  replicas: 1
  template:
    metadata:
      name: deploy-heketi
      labels:
        name: deploy-heketi
        glusterfs: heketi-pod
    spec:
      serviceAccountName: heketi-service-account
      containers:
      - image: heketi/heketi:dev
        imagePullPolicy: IfNotPresent
        name: deploy-heketi
        env:
        - name: HEKETI_EXECUTOR
          value: kubernetes
        - name: HEKETI_KUBE_USE_SECRET
          value: "y"
        - name: HEKETI_FSTAB
          value: "/var/lib/heketi/fstab"
        - name: HEKETI_SNAPSHOT_LIMIT
          value: '14'
        - name: HEKETI_KUBE_GLUSTER_DAEMONSET
          value: "y"
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: db
          mountPath: "/var/lib/heketi"
        readinessProbe:
          timeoutSeconds: 3
          initialDelaySeconds: 3
          httpGet:
            path: "/hello"
            port: 8080
        livenessProbe:
          timeoutSeconds: 3
          initialDelaySeconds: 30
          httpGet:
            path: "/hello"
            port: 8080
      volumes:
      - name: db

[root@rancher-server deploy]# cat kube-templates/heketi-deployment.yaml
---
kind: Service
apiVersion: v1
metadata:
  name: heketi
  labels:
    glusterfs: heketi-service
    deploy-heketi: support
  annotations:
    description: Exposes Heketi Service
spec:
  type: LoadBalancer
  selector:
    name: heketi
  ports:
  - name: heketi
    port: 8080
    targetPort: 8080
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: heketi
  labels:
    glusterfs: heketi-deployment
  annotations:
    description: Defines how to deploy Heketi
spec:
  replicas: 1
  template:
    metadata:
      name: heketi
      labels:
        name: heketi
        glusterfs: heketi-pod
    spec:
      serviceAccountName: heketi-service-account
      containers:
      - image: heketi/heketi:dev
        imagePullPolicy: IfNotPresent
        name: heketi
        env:
        - name: HEKETI_EXECUTOR
          value: kubernetes
        - name: HEKETI_KUBE_USE_SECRET
          value: "y"
        - name: HEKETI_FSTAB
          value: "/var/lib/heketi/fstab"
        - name: HEKETI_SNAPSHOT_LIMIT
          value: '14'
        - name: HEKETI_KUBE_GLUSTER_DAEMONSET
          value: "y"
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: db
          mountPath: "/var/lib/heketi"
        readinessProbe:
          timeoutSeconds: 3
          initialDelaySeconds: 3
          httpGet:
            path: "/hello"
            port: 8080
        livenessProbe:
          timeoutSeconds: 3
          initialDelaySeconds: 30
          httpGet:
            path: "/hello"
            port: 8080
      volumes:
      - name: db
        glusterfs:
          endpoints: heketi-storage-endpoints
          path: heketidbstorage
编写拓扑配置文件

[root@rancher-server deploy]# cat topology.json
{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "rancher-node4.novalocal"
              ],
              "storage": [
                "192.168.101.164"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/vdb",
            "/dev/vdc"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "rancher-node5.novalocal"
              ],
              "storage": [
                "192.168.101.165"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/vdb",
            "/dev/vdc"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "rancher-node6.novalocal"
              ],
              "storage": [
                "192.168.101.166"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/vdb",
            "/dev/vdc"
          ]
        }
      ]
    }
  ]
}
下载heketi客户端

[root@rancher-server deploy]# wget https://github.com/heketi/heketi/releases/download/v4.0.0/heketi-client-v4.0.0.linux.amd64.tar.gz
[root@rancher-server deploy]# tar xzvf heketi-client-v4.0.0.linux.amd64.tar.gz
[root@rancher-server deploy]# cp heketi-client/bin/heketi-cli /usr/local/bin/
[root@rancher-server deploy]# chmod +x /usr/local/bin/heketi-cli
部署服务

[root@rancher-server deploy]# ./gk-deploy -g -n kube-system -c kubectl
Welcome to the deployment tool for GlusterFS on Kubernetes and OpenShift.

Before getting started, this script has some requirements of the execution
environment and of the container platform that you should verify.

The client machine that will run this script must have:
 * Administrative access to an existing Kubernetes or OpenShift cluster
 * Access to a python interpreter 'python'
 * Access to the heketi client 'heketi-cli'

Each of the nodes that will host GlusterFS must also have appropriate firewall
rules for the required GlusterFS ports:
 * 2222  - sshd (if running GlusterFS in a pod)
 * 24007 - GlusterFS Daemon
 * 24008 - GlusterFS Management
 * 49152 to 49251 - Each brick for every volume on the host requires its own
   port. For every new brick, one new port will be used starting at 49152. We
   recommend a default range of 49152-49251 on each host, though you can adjust
   this to fit your needs.

In addition, for an OpenShift deployment you must:
 * Have 'cluster_admin' role on the administrative account doing the deployment
 * Add the 'default' and 'router' Service Accounts to the 'privileged' SCC
 * Add the 'heketi-service-account' Service Account to the 'privileged' SCC
 * Have a router deployed that is configured to allow apps to access services
   running in the cluster

Do you wish to proceed with deployment?

[Y]es, [N]o? [Default: Y]:
Using Kubernetes CLI.
NAME          STATUS    AGE
kube-system   Active    1h
Using namespace "kube-system".
serviceaccount "heketi-service-account" created
node "rancher-node4.novalocal" labeled
node "rancher-node5.novalocal" labeled
node "rancher-node6.novalocal" labeled
daemonset "glusterfs" created
Waiting for GlusterFS pods to start ... OK
service "deploy-heketi" created
deployment "deploy-heketi" created
Waiting for deploy-heketi pod to start ... OK
Name:           deploy-heketi
Namespace:      kube-system
Labels:         deploy-heketi=support
            glusterfs=heketi-service
Selector:       name=deploy-heketi
Type:           LoadBalancer
IP:         10.43.254.191
LoadBalancer Ingress:   10.101.1.162
Port:           deploy-heketi   8080/TCP
NodePort:       deploy-heketi   30985/TCP
Endpoints:      10.42.162.137:8080
Session Affinity:   None
Events:
  FirstSeen LastSeen    Count   From            SubObjectPath   Type        Reason          Message
  --------- --------    -----   ----            -------------   --------    ------          -------
  3m        3m      1   {service-controller }           Normal      CreatingLoadBalancer    Creating load balancer
  3m        3m      1   {service-controller }           Normal      CreatedLoadBalancer Created load balancer
heketi_service: 10.101.1.162:8080
Creating cluster ... ID: 1c2fe81a325b048710f3ad6d07ffbff8
    Creating node rancher-node4.novalocal ... ID: bc49ff0bb218fcf2902cb706cdc00d6c
        Adding device /dev/vdb ... OK
        Adding device /dev/vdc ... OK
    Creating node rancher-node5.novalocal ... ID: ea2d9a302006a87a622ac6bcac67555a
        Adding device /dev/vdb ... OK
        Adding device /dev/vdc ... OK
    Creating node rancher-node6.novalocal ... ID: 5d09cd8351fd1e3dab25e251fa6a23d9
        Adding device /dev/vdb ... OK
        Adding device /dev/vdc ... OK
Saving heketi-storage.json
secret "heketi-storage-secret" created
endpoints "heketi-storage-endpoints" created
service "heketi-storage-endpoints" created
job "heketi-storage-copy-job" created
service "deploy-heketi" deleted
job "heketi-storage-copy-job" deleted
deployment "deploy-heketi" deleted
secret "heketi-storage-secret" deleted
service "heketi" created
deployment "heketi" created
Waiting for heketi pod to start ... OK
Name:           heketi
Namespace:      kube-system
Labels:         deploy-heketi=support
            glusterfs=heketi-service
Selector:       name=heketi
Type:           LoadBalancer
IP:         10.43.129.172
LoadBalancer Ingress:   10.101.1.165
Port:           heketi  8080/TCP
NodePort:       heketi  31078/TCP
Endpoints:      10.42.55.126:8080
Session Affinity:   None
Events:
  FirstSeen LastSeen    Count   From            SubObjectPath   Type        Reason          Message
  --------- --------    -----   ----            -------------   --------    ------          -------
  3m        3m      1   {service-controller }           Normal      CreatingLoadBalancer    Creating load balancer
  3m        3m      1   {service-controller }           Normal      CreatedLoadBalancer Created load balancer
heketi_service: 10.101.1.165:8080
heketi is now running.
错误处理

# 当重复执行部署脚本时会出现如下错误
Creating cluster ... ID: e9164fac33d6eb0096f76033c7c5d0d6
     Creating node rancher-node3.novalocal ... ID: dd0af5202c46f4ed6710fa40f466663b
          Adding device /dev/vdb ... Unable to add device: Unable to execute command on glusterfs-pcpjx:   Can't initialize physical volume "/dev/vdb" of volume group "vg_6b153c6002e7983fcfc044d3ab8878d4" without -ff
# 登陆docker加-ff手动执行初始化操作
[root@rancher-node3 ~]# docker exec -ti f89 bash
[root@rancher-node3 /]# pvcreate -ff --metadatasize=128M --dataalignment=256K /dev/vdb
Really INITIALIZE physical volume "/dev/vdb" of volume group "vg_6b153c6002e7983fcfc044d3ab8878d4" [y/n]? y
  WARNING: Forcing physical volume creation on /dev/vdb of volume group "vg_6b153c6002e7983fcfc044d3ab8878d4"
  Physical volume "/dev/vdb" successfully created
导出HEKETI SERVER地址

[root@rancher-server deploy]# export HEKETI_CLI_SERVER=http://10.101.1.165:8080
查看拓扑信息

[root@rancher-server deploy]# heketi-cli topology info

Cluster Id: 1c2fe81a325b048710f3ad6d07ffbff8

    Volumes:

    Name: heketidbstorage
    Size: 32
    Id: 9f08272aedc22b71abd71f2c2f6301d3
    Cluster Id: 1c2fe81a325b048710f3ad6d07ffbff8
    Mount: 192.168.101.164:heketidbstorage
    Mount Options: backup-volfile-servers=192.168.101.165,192.168.101.166
    Durability Type: replicate
    Replica: 3
    Snapshot: Disabled

        Bricks:
            Id: 3443563006e26bb90ab35248a69299fc
            Path: /var/lib/heketi/mounts/vg_be73db47e84d18b8cbeb393e4d75ce39/brick_3443563006e26bb90ab35248a69299fc/brick
            Size (GiB): 32
            Node: bc49ff0bb218fcf2902cb706cdc00d6c
            Device: be73db47e84d18b8cbeb393e4d75ce39

            Id: 9c14bb4250e8a7db29cae00dbf1828c0
            Path: /var/lib/heketi/mounts/vg_1fe52210ca857e3c80b40f159afd18ea/brick_9c14bb4250e8a7db29cae00dbf1828c0/brick
            Size (GiB): 32
            Node: ea2d9a302006a87a622ac6bcac67555a
            Device: 1fe52210ca857e3c80b40f159afd18ea

            Id: b2ead217863feefd265d9103b43962ca
            Path: /var/lib/heketi/mounts/vg_ee1f9901c50b8bc8497cce2a181cd452/brick_b2ead217863feefd265d9103b43962ca/brick
            Size (GiB): 32
            Node: 5d09cd8351fd1e3dab25e251fa6a23d9
            Device: ee1f9901c50b8bc8497cce2a181cd452


    Nodes:

    Node Id: 5d09cd8351fd1e3dab25e251fa6a23d9
    State: online
    Cluster Id: 1c2fe81a325b048710f3ad6d07ffbff8
    Zone: 1
    Management Hostname: rancher-node6.novalocal
    Storage Hostname: 192.168.101.166
    Devices:
        Id:011a77329427848014186c0a1a9d50d1   Name:/dev/vdc            State:online    Size (GiB):199     Used (GiB):0       Free (GiB):199
            Bricks:
        Id:ee1f9901c50b8bc8497cce2a181cd452   Name:/dev/vdb            State:online    Size (GiB):199     Used (GiB):32      Free (GiB):167
            Bricks:
                Id:b2ead217863feefd265d9103b43962ca   Size (GiB):32      Path: /var/lib/heketi/mounts/vg_ee1f9901c50b8bc8497cce2a181cd452/brick_b2ead217863feefd265d9103b43962ca/brick

    Node Id: bc49ff0bb218fcf2902cb706cdc00d6c
    State: online
    Cluster Id: 1c2fe81a325b048710f3ad6d07ffbff8
    Zone: 1
    Management Hostname: rancher-node4.novalocal
    Storage Hostname: 192.168.101.164
    Devices:
        Id:1ba42526a340272a6565118ae86cb655   Name:/dev/vdb            State:online    Size (GiB):199     Used (GiB):0       Free (GiB):199
            Bricks:
        Id:be73db47e84d18b8cbeb393e4d75ce39   Name:/dev/vdc            State:online    Size (GiB):199     Used (GiB):32      Free (GiB):167
            Bricks:
                Id:3443563006e26bb90ab35248a69299fc   Size (GiB):32      Path: /var/lib/heketi/mounts/vg_be73db47e84d18b8cbeb393e4d75ce39/brick_3443563006e26bb90ab35248a69299fc/brick

    Node Id: ea2d9a302006a87a622ac6bcac67555a
    State: online
    Cluster Id: 1c2fe81a325b048710f3ad6d07ffbff8
    Zone: 1
    Management Hostname: rancher-node5.novalocal
    Storage Hostname: 192.168.101.165
    Devices:
        Id:1fe52210ca857e3c80b40f159afd18ea   Name:/dev/vdc            State:online    Size (GiB):199     Used (GiB):32      Free (GiB):167
            Bricks:
                Id:9c14bb4250e8a7db29cae00dbf1828c0   Size (GiB):32      Path: /var/lib/heketi/mounts/vg_1fe52210ca857e3c80b40f159afd18ea/brick_9c14bb4250e8a7db29cae00dbf1828c0/brick
        Id:7657b6d493bf403671636e0239428c65   Name:/dev/vdb            State:online    Size (GiB):199     Used (GiB):0       Free (GiB):199
            Bricks:
列出volume

[root@rancher-server deploy]# heketi-cli volume list
Id:9f08272aedc22b71abd71f2c2f6301d3    Cluster:1c2fe81a325b048710f3ad6d07ffbff8    Name:heketidbstorage
查看volume信息

[root@rancher-server ~]# heketi-cli volume info 9f08272aedc22b71abd71f2c2f6301d3
Name: heketidbstorage
Size: 32
Volume Id: 9f08272aedc22b71abd71f2c2f6301d3
Cluster Id: 1c2fe81a325b048710f3ad6d07ffbff8
Mount: 192.168.101.164:heketidbstorage
Mount Options: backup-volfile-servers=192.168.101.165,192.168.101.166
Durability Type: replicate
Distributed+Replica: 3
生成endpoints配置文件并创建

[root@rancher-server deploy]# heketi-cli volume create --size=200 \
>   --persistent-volume \
>   --persistent-volume-endpoint=heketi-storage-endpoints >heketi-storage-endpoints.yaml
[root@rancher-server deploy]# cat heketi-storage-endpoints.yaml
{
  "kind": "PersistentVolume",
  "apiVersion": "v1",
  "metadata": {
    "name": "glusterfs-b510d672",
    "creationTimestamp": null
  },
  "spec": {
    "capacity": {
      "storage": "200Gi"
    },
    "glusterfs": {
      "endpoints": "heketi-storage-endpoints",
      "path": "vol_b510d67274e2104df3d4e6ca84555aec"
    },
    "accessModes": [
      "ReadWriteMany"
    ],
    "persistentVolumeReclaimPolicy": "Retain"
  },
  "status": {}
}
[root@rancher-server deploy]# kubectl create -f heketi-storage-endpoints.yaml -n kube-system
persistentvolume "glusterfs-8b77713d" created
查看endpoints

[root@rancher-server deploy]# kubectl get endpoints -n kube-system
NAME                       ENDPOINTS                                               AGE
heketi                     10.42.55.126:8080                                       15m
heketi-storage-endpoints   192.168.101.164:1,192.168.101.165:1,192.168.101.166:1   17m
kube-controller-manager    <none>                                                  1h
kube-dns                   10.42.108.229:53,10.42.108.229:53                       1h
kube-scheduler             <none>                                                  1h
kubernetes-dashboard       10.42.31.157:9090                                       1h
查看StorageClass配置文件

[root@rancher-server deploy]# cat gluster-storage-class.yaml
apiVersion: storage.k8s.io/v1beta1
kind: StorageClass
metadata:
  name: gluster-heketi
provisioner: kubernetes.io/glusterfs
parameters:
  resturl: "http://10.101.1.165:8080"
  restauthenabled: "flase"
  restuser: "admin"
  secretNamespace: "default"
  secretName: "heketi-secret"
创建StorageClass

[root@rancher-server deploy]# kubectl create -f gluster-storage-class.yaml
storageclass "gluster-heketi" created

[root@rancher-server deploy]# kubectl get StorageClass
NAME             TYPE
gluster-heketi   kubernetes.io/glusterfs
查看PVC配置文件

[root@rancher-server deploy]# cat gluster-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: glusterfs-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: gluster-heketi
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
创建PVC

[root@rancher-server deploy]# kubectl create -f gluster-pvc.yaml
persistentvolumeclaim "glusterfs-claim” created
[root@rancher-server deploy]# kubectl get pvc
NAME              STATUS    VOLUME                                     CAPACITY   ACCESSMODES   AGE
glusterfs-claim   Bound     pvc-3777ed68-f18c-11e6-9e78-7aebc4e21f54   5Gi        RWX           43s
[root@rancher-server deploy]# kubectl describe pvc glusterfs-claim
Name:          glusterfs-claim
Namespace:     default
StorageClass:     gluster-heketi
Status:          Bound
Volume:          pvc-3777ed68-f18c-11e6-9e78-7aebc4e21f54
Labels:          <none>
Capacity:     5Gi
Access Modes:     RWX
查看busybox应用配置文件

[root@rancher-server deploy]# cat app.yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
    - image: busybox
      command:
        - sleep
        - "3600"
      name: busybox
      volumeMounts:
        - mountPath: /usr/share/busybox
          name: mypvc
  volumes:
    - name: mypvc
      persistentVolumeClaim:
        claimName: glusterfs-claim
创建应用

[root@rancher-server deploy]# kubectl create -f app.yaml
pod "busybox" created

[root@rancher-server deploy]# kubectl get pods -o wide
NAME      READY     STATUS    RESTARTS   AGE       IP             NODE
busybox   1/1       Running   0          1m        10.42.143.75   rancher-node3.novalocal
[root@rancher-node3 ~]# docker ps
CONTAINER ID        IMAGE                                      COMMAND                  CREATED              STATUS              PORTS               NAMES
107200c3da74        busybox                                    "sleep 3600"             About a minute ago   Up About a minute                       k8s_busybox.19973479_busybox_default_9f126f56-f18c-11e6-9e78-7aebc4e21f54_3a83e561
[root@rancher-node3 ~]# docker exec -ti 1072 /bin/sh
/ # df -h
Filesystem                Size      Used Available Use% Mounted on
/dev/mapper/docker-253:1-310378690-7ffa15d771fc235224960bf5a02a773f930f8196ef99d35bf7a9a07a36859ca9
                         10.0G     33.9M     10.0G   0% /
tmpfs                     3.8G         0      3.8G   0% /dev
tmpfs                     3.8G         0      3.8G   0% /sys/fs/cgroup
/dev/vda1                80.0G     12.0G     67.9G  15% /dev/termination-log
/dev/vda1                80.0G     12.0G     67.9G  15% /etc/resolv.conf
/dev/vda1                80.0G     12.0G     67.9G  15% /etc/hostname
/dev/vda1                80.0G     12.0G     67.9G  15% /etc/hosts
shm                      64.0M         0     64.0M   0% /dev/shm
192.168.101.164:vol_930e466feced37f287d9f543f4eab597
                          5.0G     32.6M      5.0G   1% /usr/share/busybox
tmpfs                     3.8G     12.0K      3.8G   0% /var/run/secrets/kubernetes.io/serviceaccount
tmpfs                     3.8G         0      3.8G   0% /proc/kcore
tmpfs                     3.8G         0      3.8G   0% /proc/timer_list
tmpfs                     3.8G         0      3.8G   0% /proc/timer_stats
tmpfs                     3.8G         0      3.8G   0% /proc/sched_debug
参考
GlusterFS集群文件系统研究：http://blog.sae.sina.com.cn/archives/4004
GlusterFS系统中文管理手册：http://www.blogchong.com/?mod=pad&act=view&id=18
https://github.com/gluster/gluster-kubernetes/blob/master/docs/setup-guide.md
https://access.redhat.com/documentation/en/red-hat-gluster-storage/3.1/single/deployment-guide-for-containerized-red-hat-gluster-storage-in-openshift-enterprise/
Running a Replicated Stateful Application：https://kubernetes.io/docs/tutorials/stateful-application/run-replicated-stateful-application/