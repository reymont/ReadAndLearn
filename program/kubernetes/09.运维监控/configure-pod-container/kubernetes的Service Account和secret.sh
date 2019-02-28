

# kubernetes的Service Account和secret - CSDN博客 
# http://blog.csdn.net/u010278923/article/details/72857928

# 运行在pod里的进程需要调用Kubernetes API以及非Kubernetes API的其它服务。
# Service Account它并不是给kubernetes集群的用户使用的，而是给pod里面的进程使用的，它为pod提供必要的身份认证。
kubectl get sa --all-namespaces

# 如果kubernetes开启了ServiceAccount（–admission_control=…,ServiceAccount,… ）
# 那么会在每个namespace下面都会创建一个默认的default的sa。

kubectl get sa  default  -o yaml

# 当用户再该namespace下创建pod的时候都会默认使用这个sa

kubectl get secret default-token-rsf8r -o yaml

# 上面的内容是经过base64加密过后的，我们直接进入容器内：

ls -l  /var/run/secrets/kubernetes.io/serviceaccount/