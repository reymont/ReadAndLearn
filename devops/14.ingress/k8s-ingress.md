

* [Kubernetes Ingress解析_Kubernetes中文社区 ](https://www.kubernetes.org.cn/1885.html)

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  backend:
    serviceName: testsvc
    servicePort: 80
```

使用kubectl create -f命令创建，然后查看ingress：

```bash
$ kubectl get ing
```


* [Ingress Resources - Kubernetes ](https://kubernetes.io/docs/concepts/services-networking/ingress/)

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        backend:
          serviceName: test
          servicePort: 80
```


* [ingress/README.md at master · kubernetes/ingress ](https://github.com/kubernetes/ingress/blob/master/examples/deployment/nginx/README.md)