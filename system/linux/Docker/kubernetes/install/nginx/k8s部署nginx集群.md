

k8s部署nginx集群 - puroc - 博客园 http://www.cnblogs.com/puroc/p/5764330.html

环境：

两台虚拟机，

10.10.20.203 部署docker、etcd、flannel、kube-apiserver、kube-controller-manager、kube-scheduler

10.10.20.206 部署docker、flannel、kubelet、kube-proxy

 

# 1、创建nginx-rc.yaml

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-controller
spec:
  replicas: 2
  selector:
    name: nginx
  template:
    metadata:
      labels:
        name: nginx
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
```
# 创建nginx-service-nodeport.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service-nodeport
spec:
  ports:
    - port: 8000
      targetPort: 80
      protocol: TCP
  type: NodePort
  selector:
    name: nginx
```
3、创建pod

kubectl create -f nginx-rc.yaml
4、创建service

kubectl create -f nginx-service-nodeport.yaml
5、查看pod

[root@k8s-master ~]# kubectl get pods
NAME                     READY     STATUS    RESTARTS   AGE
nginx-controller-v40nj   1/1       Running   1          1h
nginx-controller-zxdzh   1/1       Running   1          1h
复制代码
[root@k8s-master ~]# kubectl describe pod nginx-controller-v40nj
Name:        nginx-controller-v40nj
Namespace:    default
Node:        k8s-slave1-206/60.19.29.21
Start Time:    Thu, 11 Aug 2016 19:02:20 -0700
Labels:        name=nginx
Status:        Running
IP:        10.0.83.3
Controllers:    ReplicationController/nginx-controller
Containers:
  nginx:
    Container ID:        docker://269adc9b693aba0356ba18e4253c2b498fc7b7a8ce0af83857fcfd6b70e6ef03
    Image:            nginx
    Image ID:            docker://sha256:0d409d33b27e47423b049f7f863faa08655a8c901749c2b25b93ca67d01a470d
    Port:            80/TCP
    State:            Running
      Started:            Thu, 11 Aug 2016 20:49:27 -0700
    Last State:            Terminated
      Reason:            Completed
      Exit Code:        0
      Started:            Thu, 11 Aug 2016 19:03:44 -0700
      Finished:            Thu, 11 Aug 2016 20:12:12 -0700
    Ready:            True
    Restart Count:        1
    Environment Variables:    <none>
Conditions:
  Type        Status
  Initialized     True
  Ready     True
  PodScheduled     True
No volumes.
QoS Tier:    BestEffort
Events:
  FirstSeen    LastSeen    Count    From                SubobjectPath        Type        Reason    Message
  ---------    --------    -----    ----                -------------        --------    ------    -------
  5m        5m        1    {kubelet k8s-slave1-206}    spec.containers{nginx}    Normal        Pulling    pulling image "nginx"
  5m        5m        2    {kubelet k8s-slave1-206}                Warning        MissingClusterDNS    kubelet does not have ClusterDNS IP configured and cannot create Pod using "ClusterFirst" policy. Falling back to DNSDefault policy.
  5m        5m        1    {kubelet k8s-slave1-206}    spec.containers{nginx}    Normal        Pulled    Successfully pulled image "nginx"
  5m        5m        1    {kubelet k8s-slave1-206}    spec.containers{nginx}    Normal        Created    Created container with docker id 269adc9b693a
  5m        5m        1    {kubelet k8s-slave1-206}    spec.containers{nginx}    Normal        Started    Started container with docker id 269adc9b693a
复制代码
6、查看service

[root@k8s-master ~]# kubectl get service
NAME                     CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
kubernetes               10.254.0.1     <none>        443/TCP    16h
nginx-service-nodeport   10.254.29.72   <nodes>       8000/TCP   49m
复制代码
[root@k8s-master ~]# kubectl describe service nginx-service-nodeport
Name:            nginx-service-nodeport
Namespace:        default
Labels:            <none>
Selector:        name=nginx
Type:            NodePort
IP:            10.254.29.72
Port:            <unset>    8000/TCP
NodePort:        <unset>    31152/TCP
Endpoints:        10.0.83.2:80,10.0.83.3:80
Session Affinity:    None
No events.
复制代码
7、测试service是否好用

因为service使用的是NodePort方式，所以在任何一个节点访问31152这个端口都可以访问nginx

复制代码
$ curl 10.10.20.203:31152
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
复制代码
复制代码
$ curl 10.10.20.206:31152
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
复制代码