

https://www.kubernetes.org.cn/1879.html

RBAC vs ABAC

目前 Kubernetes 中有一系列的鉴权机制。

https://kubernetes.io/docs/admin/authorization/
`鉴权的作用是，决定一个用户是否有权使用 Kubernetes API 做某些事情`。它除了会影响 kubectl 等组件之外，还会对一些运行在集群内部并对集群进行操作的软件产生作用，例如使用了 Kubernetes 插件的 Jenkins，或者是利用 Kubernetes API 进行软件部署的 Helm。ABAC 和 RBAC 都能够对访问策略进行配置。

ABAC（Attribute Based Access Control）本来是不错的概念，但是在 Kubernetes 中的实现比较难于管理和理解（怪我咯），而且需要对 Master 所在节点的 SSH 和文件系统权限，而且要使得对授权的变更成功生效，还需要重新启动 API Server。

而 `RBAC 的授权策略可以利用 kubectl 或者 Kubernetes API 直接进行配置`。RBAC 可以授权给用户，让用户有权进行授权管理，这样就可以无需接触节点，直接进行授权管理。RBAC 在 Kubernetes 中被映射为 API 资源和操作。

因为 Kubernetes 社区的投入和偏好，相对于 ABAC 而言，RBAC 是更好的选择。

基础概念

需要理解 RBAC 一些基础的概念和思路，`RBAC 是让用户能够访问 Kubernetes API 资源的授权方式`。

a51223d13121de324b96f95079739b13

在 RBAC 中定义了两个对象，用于描述在用户和资源之间的连接权限。

角色

角色是一系列的权限的集合，例如一个角色可以包含读取 Pod 的权限和列出 Pod 的权限， ClusterRole 跟 Role 类似，但是可以在集群中到处使用（ Role 是 namespace 一级的）。

角色绑定

RoleBinding 把角色映射到用户，从而让这些用户继承角色在 namespace 中的权限。ClusterRoleBinding 让用户继承 ClusterRole 在整个集群中的权限。

57bdf8ca7815303ad055ddfdb208836f

关于 RoleBinding 和 ClusterRoleBinding： https://kubernetes.io/docs/admin/authorization/rbac/#rolebinding-and-clusterrolebinding
Kubernetes 中的 RBAC

RBAC 现在被 Kubernetes 深度集成，并使用他给系统组件进行授权。系统角色 (System Roles) 一般具有前缀system:，很容易识别：

➜  kubectl get clusterroles --namespace=kube-system
NAME                    KIND
admin                   ClusterRole.v1beta1.rbac.authorization.k8s.io
cluster-admin           ClusterRole.v1beta1.rbac.authorization.k8s.io
edit                    ClusterRole.v1beta1.rbac.authorization.k8s.io
kubelet-api-admin       ClusterRole.v1beta1.rbac.authorization.k8s.io
system:auth-delegator   ClusterRole.v1beta1.rbac.authorization.k8s.io
system:basic-user       ClusterRole.v1beta1.rbac.authorization.k8s.io
system:controller:attachdetach-controller ClusterRole.v1beta1.rbac.authorization.k8s.io
system:controller:certificate-controller ClusterRole.v1beta1.rbac.authorization.k8s.io
...
RBAC 系统角色已经完成足够的覆盖，让集群可以完全在 RBAC 的管理下运行。

在 ABAC 到 RBAC 进行迁移的过程中，有些在 ABAC 集群中缺省开放的权限，在 RBAC 中会被视为不必要的授权，会对其进行降级。这种情况会影响到使用 Service Account 的负载。ABAC 配置中，从 Pod 中发出的请求会使用 Pod Token，API Server 会为其授予较高权限。例如下面的命令在 APAC 集群中会返回 JSON 结果，而在 RBAC 的情况下则会返回错误。

➜  kubectl run nginx --image=nginx:latest
➜  kubectl exec -it $(kubectl get pods -o jsonpath='{.items[0].metadata.name}') bash
➜  apt-get update && apt-get install -y curl
➜  curl -ik \
  -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  https://kubernetes/api/v1/namespaces/default/pods
降级过程的说明： https://kubernetes.io/docs/admin/authorization/rbac/#upgrading-from-15
所有在 Kubernetes 集群中运行的应用，一旦和 API Server 进行通信，都会有可能受到迁移的影响。

要平滑的从 ABAC 升级到 RBAC，在创建 1.6 集群的时候，可以同时启用 ABAC 和 RBAC。当他们同时启用的时候，对一个资源的权限请求，在任何一方获得放行都会获得批准。然而在这种配置下的权限太过粗放，很可能无法在单纯的 RBAC 环境下工作。

RBAC 和 ABAC 同时运行： https://kubernetes.io/docs/admin/authorization/rbac/#parallel-authorizers
在 Google Cloud Next 上的两次讲话提到了 Kubernetes 1.6 中的 RBAC。要获得更详细的信息，请阅读 RBAC 文档。

https://www.youtube.com/watch?v=Cd4JU7qzYbE#t=8m01s https://www.youtube.com/watch?v=18P7cFc6nTU#t=41m06s https://kubernetes.io/docs/admin/authorization/rbac/