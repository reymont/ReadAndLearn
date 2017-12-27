

# https://segmentfault.com/a/1190000012151075

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