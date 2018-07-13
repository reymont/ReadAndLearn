
# Ingress到Kubernetes API Server的权限认证

Authentication to the Kubernetes API Server


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Ingress到Kubernetes API Server的权限认证](#ingress到kubernetes-api-server的权限认证)
	* [Service Account](#service-account)
	* [kubeconfig](#kubeconfig)
* [翻译阅读](#翻译阅读)

<!-- /code_chunk_output -->

原文：[ingress/troubleshooting.md at master · kubernetes/ingress ](https://github.com/kubernetes/ingress/blob/master/docs/troubleshooting.md)

有很多组件参与认证过程。第一步是缩小问题的根源，即是服务认证或kubeconfig文件的问题。

两种方式都可以通过认证：

```
+-------------+   service          +------------+
|             |   authentication   |            |
+  apiserver  +<-------------------+  ingress   |
|             |                    | controller |
+-------------+                    +------------+

```

__Service authentication__

Ingress控制器需要从API Server获取信息。因此，必须通过身份验证，可以通过两种不同的方式通过认证：

1. _Service Account:_ 推荐这种方式，因为并不需要额外配置。Ingress控制器将使用系统提供的信息与API Server器通信。详情请参见`“Service Account”`一节。

The format of the file is identical to `~/.kube/config` which is used by kubectl to connect to the API server. See 'kubeconfig' section for details.
2. _Kubeconfig file:_ 在一些Kubernetes环境Service Account不可用。在这种情况下，需要手动配置。Ingress控制器通过设置`-- kubeconfig`标志。该标志是指定如何连接到API Serve配置文件的路径。使用`-- kubeconfig `不要求设置`--apiserver-host`。文件的格式是`~/.kube/config`，用与kubectl连接API Server。细节请阅读`“kubeconfig”`一节。

3. _使用`--apiserver-host`:_ 使用`--apiserver-host=http://localhost:8080` 可以指定一个不安全的API Server访问方式，或者通过 [kubectl proxy](https://kubernetes.io/docs/user-guide/kubectl/kubectl_proxy/)远程Kubernetes集群的方式。请不要在生产环境中使用这种方法。

在下面的图表中，可以看到完整身份验证流程，从左下角的开始。
```

Kubernetes                                                  Workstation
+---------------------------------------------------+     +------------------+
|                                                   |     |                  |
|  +-----------+   apiserver        +------------+  |     |  +------------+  |
|  |           |   proxy            |            |  |     |  |            |  |
|  | apiserver |                    |  ingress   |  |     |  |  ingress   |  |
|  |           |                    | controller |  |     |  | controller |  |
|  |           |                    |            |  |     |  |            |  |
|  |           |                    |            |  |     |  |            |  |
|  |           |  service account/  |            |  |     |  |            |  |
|  |           |  kubeconfig        |            |  |     |  |            |  |
|  |           +<-------------------+            |  |     |  |            |  |
|  |           |                    |            |  |     |  |            |  |
|  +------+----+      kubeconfig    +------+-----+  |     |  +------+-----+  |
|         |<--------------------------------------------------------|        |
|                                                   |     |                  |
+---------------------------------------------------+     +------------------+
```


## Service Account
If using a service account to connect to the API server, Dashboard expects the file `/var/run/secrets/kubernetes.io/serviceaccount/token` to be present. It provides a secret token that is required to authenticate with the API server.
如果使用Service Account连接到API Server，Dashboard需要能够访问`/var/run/secrets/kubernetes.io/serviceaccount/token`文件。它提供了连接API Server身份验证的秘钥令牌。

用以下命令验证:

```shell
# start a container that contains curl
$ kubectl run test --image=tutum/curl -- sleep 10000

# check that container is running
$ kubectl get pods
NAME                   READY     STATUS    RESTARTS   AGE
test-701078429-s5kca   1/1       Running   0          16s

# check if secret exists
$ kubectl exec test-701078429-s5kca ls /var/run/secrets/kubernetes.io/serviceaccount/
ca.crt
namespace
token

# get service IP of master
$ kubectl get services
NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   10.0.0.1     <none>        443/TCP   1d

# check base connectivity from cluster inside
$ kubectl exec test-701078429-s5kca -- curl -k https://10.0.0.1
Unauthorized

# connect using tokens
$ TOKEN_VALUE=$(kubectl exec test-701078429-s5kca -- cat /var/run/secrets/kubernetes.io/serviceaccount/token)
$ echo $TOKEN_VALUE
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3Mi....9A
$ kubectl exec test-701078429-s5kca -- curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H  "Authorization: Bearer $TOKEN_VALUE" https://10.0.0.1
{
  "paths": [
    "/api",
    "/api/v1",
    "/apis",
    "/apis/apps",
    "/apis/apps/v1alpha1",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1beta1",
    "/apis/authorization.k8s.io",
    "/apis/authorization.k8s.io/v1beta1",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/batch/v2alpha1",
    "/apis/certificates.k8s.io",
    "/apis/certificates.k8s.io/v1alpha1",
    "/apis/extensions",
    "/apis/extensions/v1beta1",
    "/apis/policy",
    "/apis/policy/v1alpha1",
    "/apis/rbac.authorization.k8s.io",
    "/apis/rbac.authorization.k8s.io/v1alpha1",
    "/apis/storage.k8s.io",
    "/apis/storage.k8s.io/v1beta1",
    "/healthz",
    "/healthz/ping",
    "/logs",
    "/metrics",
    "/swaggerapi/",
    "/ui/",
    "/version"
  ]
}
```

如果它不工作，有两个可能的原因：:

1. 令牌的内容无效。按名称找到secrets`kubectl get secrets | grep service-account`，并删除`kubectl delete secret <name>`。它将自动被重新创建。

2. 按非标准方式安装Kubernetes，令牌的文件可能不存在。在API Server配置为使用`ServiceAccount许可控制器(admission controllers)`的情况下，API Server将包含该文件。如果遇到此错误，请验证API Server使用`ServiceAccount许可控制器(admission controllers)`。如果手动配置API Server，可以使用`--admission-control`参数。请注意，也可以使用其他`许可控制器(admission controllers)`。在配置此选项之前，应该阅读有关`许可控制器(admission controllers)`的内容。

参考:

* [User Guide: Service Accounts](http://kubernetes.io/docs/user-guide/service-accounts/)
* [Cluster Administrator Guide: Managing Service Accounts](http://kubernetes.io/docs/admin/service-accounts-admin/)

## kubeconfig
如果你想使用一个kubeconfig申请认证，创建一个类似下面的配置文件：

*Note:* the important part is the flag `--kubeconfig=/etc/kubernetes/kubeconfig.yaml`.


```yaml
kind: Service
apiVersion: v1
metadata:
  name: nginx-default-backend
  labels:
    k8s-addon: ingress-nginx.addons.k8s.io
spec:
  ports:
  - port: 80
    targetPort: http
  selector:
    app: nginx-default-backend

---

kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: nginx-default-backend
  labels:
    k8s-addon: ingress-nginx.addons.k8s.io
spec:
  replicas: 1
  template:
    metadata:
      labels:
        k8s-addon: ingress-nginx.addons.k8s.io
        app: nginx-default-backend
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - name: default-http-backend
        image: gcr.io/google_containers/defaultbackend:1.0
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        resources:
          limits:
            cpu: 10m
            memory: 20Mi
          requests:
            cpu: 10m
            memory: 20Mi
        ports:
        - name: http
          containerPort: 8080
          protocol: TCP

---

kind: ConfigMap
apiVersion: v1
metadata:
  name: ingress-nginx
  labels:
    k8s-addon: ingress-nginx.addons.k8s.io

---

kind: Service
apiVersion: v1
metadata:
  name: ingress-nginx
  labels:
    k8s-addon: ingress-nginx.addons.k8s.io
spec:
  type: LoadBalancer
  selector:
    app: ingress-nginx
  ports:
  - name: http
    port: 80
    targetPort: http
  - name: https
    port: 443
    targetPort: https

---

kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: ingress-nginx
  labels:
    k8s-addon: ingress-nginx.addons.k8s.io
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ingress-nginx
        k8s-addon: ingress-nginx.addons.k8s.io
    spec:
      terminationGracePeriodSeconds: 60
      containers:
      - image: gcr.io/google_containers/nginx-ingress-controller:0.9.0-beta.11
        name: ingress-nginx
        imagePullPolicy: Always
        ports:
          - name: http
            containerPort: 80
            protocol: TCP
          - name: https
            containerPort: 443
            protocol: TCP
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        env:
          - name: POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        args:
        - /nginx-ingress-controller
        - --default-backend-service=$(POD_NAMESPACE)/nginx-default-backend
        - --configmap=$(POD_NAMESPACE)/ingress-nginx
        - --kubeconfig=/etc/kubernetes/kubeconfig.yaml
      volumes:
      - name: "kubeconfig"
        hostPath:
          path: "/etc/kubernetes/"
```

# 翻译阅读

* [Kubernetes（k8s）中文文档 名词解释：Service Account_Kubernetes中文社区 ](https://www.kubernetes.org.cn/service-account)

每个namespace都会自动创建一个`default service account`。`service account`局限它所在的namespace。

* [kubernetes的Service Account和secret - 柳清风的专栏 - CSDN博客 ](http://blog.csdn.net/u010278923/article/details/72857928)