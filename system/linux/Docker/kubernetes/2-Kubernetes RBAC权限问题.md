Kubernetes RBAC权限问题 - CSDN博客 http://blog.csdn.net/wenwst/article/details/78890724

Kubernetes RBAC权限问题

在配置Ingress出现以下问题,是由于RBAC配置引起。RBAC在Kubernetes1.6开始引用。使用API版本也不同，因此，在配置yaml文件时需要注意。这里我们通过一个例子来解决RBAC的问题，当然，关于RBAC的概念在这里好像没有提及到。

1. 问题1
I0531 02:36:29.882636       7 launch.go:101] &{NGINX 0.9.0-beta.7 git-c1b8a32 https://github.com/kubernetes/ingress}
I0531 02:36:29.882660       7 launch.go:104] Watching for ingress class: nginx
I0531 02:36:29.882815       7 launch.go:257] Creating API server client for https://10.254.0.1:443
F0531 02:36:29.914513       7 launch.go:118] no service with name kube-system/default-http-backend found: User "system:serviceaccount:kube-system:default" cannot get services in the namespace "kube-system". (get services default-http-backend)

2. 问题2
 MountVolume.SetUp failed for volume "kubernetes.io/secret/6e55da79-e6de-11e7-8fc8-a2a5d2bd6632-fluentd-token-n74hg" (spec.Name: "fluentd-token-n74hg") pod "6e55da79-e6de-11e7-8fc8-a2a5d2bd6632" (UID: "6e55da79-e6de-11e7-8fc8-a2a5d2bd6632") with: secrets "fluentd-token-n74hg" not found

3. 问题3
2017-06-15 03:05:29 +0000 [info]: adding match pattern="**" type="elasticsearch"
2017-06-15 03:05:29 +0000 [error]: config error file="/fluentd/etc/fluent.conf" error="Exception encountered fetching metadata from Kubernetes API endpoint: 403 Forbidden (User \"system:serviceaccount:kube-system:default\" cannot list pods at the cluster scope.)"
2017-06-15 03:05:29 +0000 [info]: process finished code=256
2017-06-15 03:05:29 +0000 [warn]: process died within 1 second. exit.
You have new mail in /var/spool/mail/root
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
以下的Yaml可以根据自己的项目进行配置。
创建Namespace 
创建一个命令空间nginx-ingress,在接下来，我们会针对于nginx-ingress进行处理。所以，也不需要在意这个命令空间是什么名子。
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-ingress
1
2
3
4
创建ServiceAccount 
创建一个ServiceAccount，名为nginx-ingress-serviceaccount，namespace是刚才创建的nginx-ingress。
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
  namespace: nginx-ingress
1
2
3
4
5
在deployment中，我们通过serviceAccountName: kubernetes-dashboard来调用这个ServiceAccount。

创建ClusterRole 
创建一个ClusterRole，名为nginx-ingress-clusterrole。并通过rules分配相应的权限。这里要注意apiVersion是rbac.authorization.k8s.io/v1beta1，因为现在这边使用的是kubernetes 1.6。在别的版本中，使用的是rbac.authorization.k8s.io/v1。
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: nginx-ingress-clusterrole
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
        - events
    verbs:
        - create
        - patch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses/status
    verbs:
      - update
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
创建Role 
创建角色Role，命名为nginx-ingress-role，属于nginx-ingress命令空间，并通过rules分配相应的权限。
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: Role
metadata:
  name: nginx-ingress-role
  namespace: nginx-ingress
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - pods
      - secrets
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - endpoints
    verbs:
      - get
      - create
      - update
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
创建RoleBinding 
创建一个RoleBinding名为nginx-ingress-role-nisa-binding，设置 namespace为nginx-ingress。
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: nginx-ingress-role-nisa-binding
  namespace: nginx-ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nginx-ingress-role
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: nginx-ingress
1
2
3
4
5
6
7
8
9
10
11
12
13
创建RoleBinding 
创建一个RoleBinding。
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: nginx-ingress-clusterrole-nisa-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: nginx-ingress-clusterrole
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
namespace: nginx-ingress
1
2
3
4
5
6
7
8
9
10
11
12
版权声明：本文为博主原创文章，未经博主允许不得转载。 http://blog.csdn.net/wenwst/article/details/78890724
