

* [Services - Kubernetes ](https://kubernetes.io/docs/concepts/services-networking/service/)
* [如何在Kubernetes中暴露服务访问 - RancherLabs的博客 - CSDN博客 ](http://blog.csdn.net/rancherlabs/article/details/53991992)
* [Google Kubernetes设计文档之服务篇 | Software Engineering Lab | Zhejiang University ](http://www.sel.zju.edu.cn/?p=360)
* [kubernetes学习2--RC/service/pod实践 - 夢の殇 - CSDN博客 ](http://blog.csdn.net/dream_broken/article/details/53115770)

# pod


```bash
kubectl get pods
kubectl get pod php-test -o wide
```


* [Kubernetes应用部署模型解析（部署篇）-CSDN.NET ](http://www.csdn.net/article/2015-06-12/2824937)

```yaml
$ cat nginx-service-nodeport.yaml 
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