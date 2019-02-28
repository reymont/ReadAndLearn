

* [深入kubernetes调度之NodeSelector - VF@CSDN - CSDN博客 ](http://blog.csdn.net/tiger435/article/details/73650147)

NodeName和NodeSelector。

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat-deploy
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: tomcat-app
    spec:
      nodeName: k8s.node1 #指定调度节点为k8s.node1
      containers:
      - name: tomcat
        image: tomcat:8.0
        ports:
        - containerPort: 8080
```

# label

```sh
#标记规则：kubectl label nodes <node-name> <label-key>=<label-value>
kubectl label nodes k8s.node1 cloudnil.com/role=dev

#确认标记
root@k8s.master1:~# kubectl get nodes k8s.node1 --show-labels
NAME        STATUS    AGE       LABELS
k8s.node1   Ready     29d       beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,cloudnil.com/role=dev,kubernetes.io/hostname=k8s.node1
```


```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: tomcat-deploy
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: tomcat-app
    spec:
      nodeSelector:
        cloudnil.com/role: dev #指定调度节点为带有label标记为：cloudnil.com/role=dev的node节点
      containers:
      - name: tomcat
        image: tomcat:8.0
        ports:
        - containerPort: 8080
```

# Assigning Pods to Nodes - Kubernetes

* [Assigning Pods to Nodes - Kubernetes ](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)
* [Remove old node role label that is not used by kubeadm · kubernetes/kubernetes@e25a5b1 ](https://github.com/kubernetes/kubernetes/commit/e25a5b1546392221c79e4d48dff4643c2341a002)

```sh
kubectl get nodes --show-labels
#kubectl label nodes <node-name> <label-key>=<label-value>

```



# How to force Pods/Deployments to Master nodes?

* [kubernetes - How to force Pods/Deployments to Master nodes? - Stack Overflow ](https://stackoverflow.com/questions/41999756/how-to-force-pods-deployments-to-master-nodes)