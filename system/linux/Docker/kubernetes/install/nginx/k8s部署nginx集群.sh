

# k8s部署nginx集群 - puroc - 博客园 http://www.cnblogs.com/puroc/p/5764330.html
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
# 3、创建pod
kubectl create -f nginx-rc.yaml
# 4、创建service
kubectl create -f nginx-service-nodeport.yaml
# 5、查看pod
kubectl get pod -o wide
kubectl describe pod nginx-controller-v40nj
# 6、查看service
kubectl get svc
kubectl describe service nginx-service-nodeport
# 7、测试service是否好用
curl 10.10.20.203:31152
curl 10.10.20.206:31152