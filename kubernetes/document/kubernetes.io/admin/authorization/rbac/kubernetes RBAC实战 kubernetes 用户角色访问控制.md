

kubernetes RBAC实战 kubernetes 用户角色访问控制，dashboard访问，kubectl配置生成 - ionic - SegmentFault https://segmentfault.com/a/1190000012151075


kubernetes RBAC实战
环境准备
先用kubeadm安装好kubernetes集群，包地址在此 好用又方便，服务周到，童叟无欺

本文目的，让名为devuser的用户只能有权限访问特定namespace下的pod

命令行kubectl访问
安装cfssl
此工具生成证书非常方便, pem证书与crt证书,编码一致可直接使用

wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
mv cfssl_linux-amd64 /bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
mv cfssljson_linux-amd64 /bin/cfssljson

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl-certinfo_linux-amd64
mv cfssl-certinfo_linux-amd64 /bin/cfssl-certinfo
签发客户端证书
根据ca证书与么钥签发用户证书
根证书已经在/etc/kubernetes/pki目录下了

[root@master1 ~]# ls /etc/kubernetes/pki/
apiserver.crt                 ca-config.json  devuser-csr.json    front-proxy-ca.key      sa.pub
apiserver.key                 ca.crt          devuser-key.pem     front-proxy-client.crt
apiserver-kubelet-client.crt  ca.key          devuser.pem         front-proxy-client.key
apiserver-kubelet-client.key  devuser.csr     front-proxy-ca.crt  sa.key
注意以下几个文件： ca.crt ca.key ca-config.json devuser-csr.json

创建ca-config.json文件

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF
创建devuser-csr.json文件：
k8s的用户名就是从CN上获取的。 组是从O上获取的。这个用户或者组用于后面的角色绑定使用

cat > devuser-csr.json <<EOF
{
  "CN": "devuser",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF
生成user的证书：

$ cfssl gencert -ca=ca.crt -ca-key=ca.key -config=ca-config.json -profile=kubernetes devuser-csr.json | cfssljson -bare devuser
就会生成下面的文件：

devuser.csr devuser-key.pem devuser.pem
校验证书
# cfssl-certinfo -cert kubernetes.pem
生成config文件
kubeadm已经生成了admin.conf，我们可以直接利用这个文件，省的自己再去配置集群参数

$ cp /etc/kubernetes/admin.conf devuser.kubeconfig
设置客户端认证参数:

kubectl config set-credentials devuser \
--client-certificate=/etc/kubernetes/ssl/devuser.pem \
--client-key=/etc/kubernetes/ssl/devuser-key.pem \
--embed-certs=true \
--kubeconfig=devuser.kubeconfig
设置上下文参数：

kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=devuser \
--namespace=kube-system \
--kubeconfig=devuser.kubeconfig
设置莫认上下文：

kubectl config use-context kubernetes --kubeconfig=devuser.kubeconfig
以上执行一个步骤就可以看一下 devuser.kubeconfig的变化。里面最主要的三个东西

cluster: 集群信息，包含集群地址与公钥
user: 用户信息，客户端证书与私钥，正真的信息是从证书里读取出来的，人能看到的只是给人看的。
context: 维护一个三元组，namespace cluster 与 user
创建角色
创建一个叫pod-reader的角色

[root@master1 ~]# cat pod-reader.yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: kube-system
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
kubectl create -f pod-reader.yaml
绑定用户
创建一个角色绑定，把pod-reader角色绑定到 devuser上

[root@master1 ~]# cat devuser-role-bind.yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: read-pods
  namespace: kube-system
subjects:
- kind: User
  name: devuser   # 目标用户
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader  # 角色信息
  apiGroup: rbac.authorization.k8s.io
kubectl create -f devuser-role-bind.yaml
使用新的config文件
$ rm .kube/config && cp devuser.kubeconfig .kube/config
效果, 已经没有别的namespace的权限了，也不能访问node信息了：

[root@master1 ~]# kubectl get node
Error from server (Forbidden): nodes is forbidden: User "devuser" cannot list nodes at the cluster scope

[root@master1 ~]# kubectl get pod -n kube-system
NAME                                       READY     STATUS    RESTARTS   AGE
calico-kube-controllers-55449f8d88-74x8f   1/1       Running   0          8d
calico-node-clpqr                          2/2       Running   0          8d
kube-apiserver-master1                     1/1       Running   2          8d
kube-controller-manager-master1            1/1       Running   1          8d
kube-dns-545bc4bfd4-p6trj                  3/3       Running   0          8d
kube-proxy-tln54                           1/1       Running   0          8d
kube-scheduler-master1                     1/1       Running   1          8d

[root@master1 ~]# kubectl get pod -n default
Error from server (Forbidden): pods is forbidden: User "devuser" cannot list pods in the namespace "default": role.rbac.authorization.k8s.io "pod-reader" not found
dashboard访问
service account原理
k8s里面有两种用户，一种是User，一种就是service account，User给人用的，service account给进程用的，让进程有相关的权限。

如dasboard就是一个进程，我们就可以创建一个service account给它，让它去访问k8s。

我们看一下是如何把admin权限赋给dashboard的：

╰─➤  cat dashboard-admin.yaml
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: kubernetes-dashboard
  labels:
    k8s-app: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system
把 kubernetes-dashboard 这个ServiceAccount绑定到cluster-admin这个ClusterRole上，这个cluster role非常牛逼，啥权限都有

[root@master1 ~]# kubectl describe clusterrole cluster-admin -n kube-system
Name:         cluster-admin
Labels:       kubernetes.io/bootstrapping=rbac-defaults
Annotations:  rbac.authorization.kubernetes.io/autoupdate=true
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
             [*]                []              [*]
  *.*        []                 []              [*]
而创建dashboard时创建了这个service account:

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
然后deployment里指定service account

      volumes:
      - name: kubernetes-dashboard-certs
        secret:
          secretName: kubernetes-dashboard-certs
      - name: tmp-volume
        emptyDir: {}
      serviceAccountName: kubernetes-dashboard
更安全的做法
[root@master1 ~]# cat admin-token.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: admin
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: admin
  namespace: kube-system
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin
  namespace: kube-system
  labels:
    kubernetes.io/cluster-service: "true"
    addonmanager.kubernetes.io/mode: Reconcile
[root@master1 ~]# kubectl get secret -n kube-system|grep admin
admin-token-7rdhf                        kubernetes.io/service-account-token   3         14m
[root@master1 ~]# kubectl describe secret admin-token-7rdhf -n kube-system
Name:         admin-token-7rdhf
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name=admin
              kubernetes.io/service-account.uid=affe82d4-d10b-11e7-ad03-00163e01d684

Type:  kubernetes.io/service-account-token

Data
====
ca.crt:     1025 bytes
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi10b2tlbi03cmRoZiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImFmZmU4MmQ0LWQxMGItMTFlNy1hZDAzLTAwMTYzZTAxZDY4NCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTphZG1pbiJ9.jSfQhFsY7V0ZmfqxM8lM_UUOoUhI86axDSeyVVtldSUY-BeP2Nw4q-ooKGJTBBsrOWvMiQePcQxJTKR1K4EIfnA2FOnVm4IjMa40pr7-oRVY37YnR_1LMalG9vrWmqFiqIsKe9hjkoFDuCaP7UIuv16RsV7hRlL4IToqmJMyJ1xj2qb1oW4P1pdaRr4Pw02XBz9yBpD1fs-lbwheu1UKcEnbHS_0S3zlmAgCrpwDFl2UYOmgUKQVpJhX4wBRRQbwo1Sn4rEFVI1NIa9l_lM7Mf6YEquLHRu3BCZTdu9YfY9pevQz4OfHE0NOvDIqmGRL8Z9kPADAXbljWzcD1m1xCQ
用此token在界面上登录即可