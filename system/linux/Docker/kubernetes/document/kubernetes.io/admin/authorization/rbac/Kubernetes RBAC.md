
Kubernetes RBAC — 漠然 https://mritd.me/2017/07/17/kubernetes-rbac-chinese-translation/


基于角色的访问控制使用 rbac.authorization.k8s.io API 组来实现权限控制，RBAC 允许管理员通过 Kubernetes API 动态的配置权限策略。在 1.6 版本中 RBAC 还处于 Beat 阶段，如果想要开启 RBAC 授权模式需要在 apiserver 组件中指定 --authorization-mode=RBAC 选项。
一、API Overview

本节介绍了 RBAC 的四个顶级类型，用户可以像与其他 Kubernetes API 资源一样通过 kubectl、API 调用方式与其交互；例如使用 kubectl create -f (resource).yml 命令创建资源对象，跟随本文档操作前最好先阅读引导部分。

1.1、Role and ClusterRole

在 RBAC API 中，Role 表示一组规则权限，权限只会增加(累加权限)，不存在一个资源一开始就有很多权限而通过 RBAC 对其进行减少的操作；Role 可以定义在一个 namespace 中，如果想要跨 namespace 则可以创建 ClusterRole。

Role 只能用于授予对单个命名空间中的资源访问权限， 以下是一个对默认命名空间中 Pods 具有访问权限的样例:

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" indicates the core API group
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
ClusterRole 具有与 Role 相同的权限角色控制能力，不同的是 ClusterRole 是集群级别的，ClusterRole 可以用于:

集群级别的资源控制(例如 node 访问权限)
非资源型 endpoints(例如 /healthz 访问)
所有命名空间资源控制(例如 pods)
以下是 ClusterRole 授权某个特定命名空间或全部命名空间(取决于绑定方式)访问 secrets 的样例

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  # "namespace" omitted since ClusterRoles are not namespaced
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
1.2、RoleBinding and ClusterRoleBinding

RoloBinding 可以将角色中定义的权限授予用户或用户组，RoleBinding 包含一组权限列表(subjects)，权限列表中包含有不同形式的待授予权限资源类型(users, groups, or service accounts)；RoloBinding 同样包含对被 Bind 的 Role 引用；RoleBinding 适用于某个命名空间内授权，而 ClusterRoleBinding 适用于集群范围内的授权。

RoleBinding 可以在同一命名空间中引用对应的 Role，以下 RoleBinding 样例将 default 命名空间的 pod-reader Role 授予 jane 用户，此后 jane 用户在 default 命名空间中将具有 pod-reader 的权限

# This role binding allows "jane" to read pods in the "default" namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
RoleBinding 同样可以引用 ClusterRole 来对当前 namespace 内用户、用户组或 ServiceAccount 进行授权，这种操作允许集群管理员在整个集群内定义一些通用的 ClusterRole，然后在不同的 namespace 中使用 RoleBinding 来引用

例如，以下 RoleBinding 引用了一个 ClusterRole，这个 ClusterRole 具有整个集群内对 secrets 的访问权限；但是其授权用户 dave 只能访问 development 空间中的 secrets(因为 RoleBinding 定义在 development 命名空间)

# This role binding allows "dave" to read secrets in the "development" namespace.
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: read-secrets
  namespace: development # This only grants permissions within the "development" namespace.
subjects:
- kind: User
  name: dave
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
最后，使用 ClusterRoleBinding 可以对整个集群中的所有命名空间资源权限进行授权；以下 ClusterRoleBinding 样例展示了授权 manager 组内所有用户在全部命名空间中对 secrets 进行访问

# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: read-secrets-global
subjects:
- kind: Group
  name: manager
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
1.3、Referring to Resources

Kubernetes 集群内一些资源一般以其名称字符串来表示，这些字符串一般会在 API 的 URL 地址中出现；同时某些资源也会包含子资源，例如 logs 资源就属于 pods 的子资源，API 中 URL 样例如下

GET /api/v1/namespaces/{namespace}/pods/{name}/log
如果要在 RBAC 授权模型中控制这些子资源的访问权限，可以通过 / 分隔符来实现，以下是一个定义 pods 资资源 logs 访问权限的 Role 定义样例

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: pod-and-pod-logs-reader
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
具体的资源引用可以通过 resourceNames 来定义，当指定 get、delete、update、patch 四个动词时，可以控制对其目标资源的相应动作；以下为限制一个 subject 对名称为 my-configmap 的 configmap 只能具有 get 和 update 权限的样例

kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: configmap-updater
rules:
- apiGroups: [""]
  resources: ["configmap"]
  resourceNames: ["my-configmap"]
  verbs: ["update", "get"]
值得注意的是，当设定了 resourceNames 后，verbs 动词不能指定为 list、watch、create 和 deletecollection；因为这个具体的资源名称不在上面四个动词限定的请求 URL 地址中匹配到，最终会因为 URL 地址不匹配导致 Role 无法创建成功

1.3.1、Role Examples

以下样例只给出了 role 部分

在核心 API 组中允许读取 pods 资源

rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
在 extensions 和 apps API 组中允许读取/写入 deployments

rules:
- apiGroups: ["extensions", "apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
允许读取 pods 资源，允许读取/写入 jobs 资源

rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch", "extensions"]
  resources: ["jobs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
允许读取名称为 my-config 的 ConfigMap(需要与 RoleBinding 绑定来限制某个特定命名空间和指定名字的 ConfigMap)

rules:
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["my-config"]
  verbs: ["get"]
允许在核心组中读取 nodes 资源( Node 是集群范围内的资源，需要使用 ClusterRole 并且与 ClusterRoleBinding 绑定才能进行限制)

rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get", "list", "watch"]
允许对非资源型 endpoint /healthz 和其子路径 /healthz/* 进行 GET 和 POST 请求(同样需要使用 ClusterRole 和 ClusterRoleBinding 才能生效)

rules:
- nonResourceURLs: ["/healthz", "/healthz/*"] # '*' in a nonResourceURL is a suffix glob match
  verbs: ["get", "post"]
1.4、Referring to Subjects

RoleBinding 和 ClusterRoleBinding 可以将 Role 绑定到 Subjects；Subjects 可以是 groups、users 或者 service accounts。

Subjects 中 Users 使用字符串表示，它可以是一个普通的名字字符串，如 “alice”；也可以是 email 格式的邮箱地址，如 “bob@example.com”；甚至是一组字符串形式的数字 ID。Users 的格式必须满足集群管理员配置的验证模块，RBAC 授权系统中没有对其做任何格式限定；但是 Users 的前缀 system: 是系统保留的，集群管理员应该确保普通用户不会使用这个前缀格式

Kubernetes 的 Group 信息目前由 Authenticator 模块提供，Groups 书写格式与 Users 相同，都为一个字符串，并且没有特定的格式要求；同样 system: 前缀为系统保留

具有 system:serviceaccount: 前缀的用户名和 system:serviceaccounts: 前缀的组为 Service Accounts

1.4.1、Role Binding Examples

以下示例仅展示 RoleBinding 的 subjects 部分

指定一个名字为 alice@example.com 的用户

subjects:
- kind: User
  name: "alice@example.com"
  apiGroup: rbac.authorization.k8s.io
指定一个名字为 frontend-admins 的组

subjects:
- kind: Group
  name: "frontend-admins"
  apiGroup: rbac.authorization.k8s.io
指定 kube-system namespace 中默认的 Service Account

subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
指定在 qa namespace 中全部的 Service Account

subjects:
- kind: Group
  name: system:serviceaccounts:qa
  apiGroup: rbac.authorization.k8s.io
指定全部 namspace 中的全部 Service Account

subjects:
- kind: Group
  name: system:serviceaccounts
  apiGroup: rbac.authorization.k8s.io
指定全部的 authenticated 用户(1.5+)

subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
指定全部的 unauthenticated 用户(1.5+)

subjects:
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
指定全部用户

subjects:
- kind: Group
  name: system:authenticated
  apiGroup: rbac.authorization.k8s.io
- kind: Group
  name: system:unauthenticated
  apiGroup: rbac.authorization.k8s.io
二、Default Roles and Role Bindings

集群创建后 API Server 默认会创建一些 ClusterRole 和 ClusterRoleBinding 对象；这些对象以 system: 为前缀，这表明这些资源对象由集群基础设施拥有；修改这些集群基础设施拥有的对象可能导致集群不可用。 一个简单的例子是 system:node ClusterRole，这个 ClusterRole 定义了 kubelet 的相关权限，如果该 ClusterRole 被修改可能导致 ClusterRole 不可用。

所有的默认 ClusterRole 和 RoleBinding 都具有 kubernetes.io/bootstrapping=rbac-defaults lable

2.1、Auto-reconciliation

API Server 在每次启动后都会更新已经丢失的默认 ClusterRole 和 其绑定的相关 Subjects；这将允许集群自动修复因为意外更改导致的 RBAC 授权错误，同时能够使在升级集群后基础设施的 RBAC 授权得以自动更新。

如果想要关闭 API Server 的自动修复功能，只需要将默认创建的 ClusterRole 和其 RoleBind 的 rbac.authorization.kubernetes.io/autoupdate 注解设置为 false 即可，这样做会有很大风险导致集群因为意外修改 RBAC 而无法工作

Auto-reconciliation 在 1.6+ 版本被默认启用(当 RBAC 授权被激活时)

2.2、Discovery Roles

Default ClusterRole	Default ClusterRoleBinding	Description
system:basic-user	system:authenticated and system:unauthenticated groups	允许用户以只读的方式读取其基础信息
system:discovery	system:authenticated and system:unauthenticated groups	允许以只读的形式访问 发现和协商 API Level 所需的 API discovery endpoints
2.3、User-facing Roles

一些默认的 Role 并未以 system: 前缀开头，这表明这些默认的 Role 是面向用户级别的。这其中包括超级用户的一些 Role( cluster-admin )，和为面向集群范围授权的 RoleBinding( cluster-status )，以及在特定命名空间中授权的 RoleBinding( admin，edit，view )

Default ClusterRole	Default ClusterRoleBinding	Description
cluster-admin	system:masters group	允许超级用户对集群内任意资源执行任何动作。当该 Role 绑定到 ClusterRoleBinding 时，将授予目标 subject 在任意 namespace 内对任何 resource 执行任何动作的权限；当绑定到 RoleBinding 时，将授予目标 subject 在当前 namespace 内对任意 resource 执行任何动作的权限，当然也包括 namespace 自己
admin	None	管理员权限，用于在单个 namespace 内授权；在与某个 RoleBinding 绑定后提供在单个 namesapce 中对资源的读写权限，包括在单个 namesapce 内创建 Role 和进行 RoleBinding 的权限。该 ClusterRole 不允许对资源配额和 namespace 本身进行修改
edit	None	允许读写指定 namespace 中的大多数资源对象；该 ClusterRole 不允许查看或修改 Role 和 RoleBinding
view	None	允许以只读方式访问特定 namespace 中的大多数资源对象；该 ClusterRole 不允许查看 Role 或 RoleBinding，同时不允许查看 secrets，因为他们会不断更新
2.4、Core Component Roles

Default ClusterRole	Default ClusterRoleBinding	Description
system:kube-scheduler	system:kube-scheduler user	允许访问 kube-scheduler 所需资源
system:kube-controller-manager	system:kube-controller-manager user	允许访问 kube-controller-manager 所需资源；该 ClusterRole 包含每个控制循环所需要的权限
system:node	system:nodes group (deprecated in 1.7)	允许访问 kubelet 所需资源；包括对所有的 secrets 读访问权限和对所有 pod 的写权限；在 1.7 中更推荐使用 Node authorizer 和 NodeRestriction admission plugin 而非本 ClusterRole；Node authorizer 和 NodeRestriction admission plugin 可以授权当前 node 上运行的具体 pod 对 kubelet API 的访问权限，在 1.7 版本中，如果开启了 Node authorization mode，那么 system:nodes group将不会被创建和自动绑定
system:node-proxier	system:kube-proxy user	允许访问 kube-proxy 所需资源
2.5、Other Component Roles

Default ClusterRole	Default ClusterRoleBinding	Description
system:auth-delegator	None	允许委托认证和授权检查；此情况下通常由附加的 API Server 来进行统一认证和授权
system:heapster	None	Heapster 组件相关权限
system:kube-aggregator	None	kube-aggregator 相关权限
system:kube-dns	kube-dns service account in the kube-system namespace	kube-dns 相关权限
system:node-bootstrapper	None	允许访问 Kubelet TLS bootstrapping 相关资源权限
system:node-problem-detector	None	node-problem-detector 相关权限
system:persistent-volume-provisioner	Node	允许访问 dynamic volume provisioners 相关资源权限
2.6、Controller Roles

Kubernetes controller manager 运行着一些核心的 control loops，当使用 --use-service-account-credentials 参数启动时，每个 control loop 都会使用独立的 Service Account 启动；相应的 roles 会以 system:controller 前缀存在于每个 control loop 中；如果不指定该选项，那么 Kubernetes controller manager 将会使用自己的凭据来运行所有 control loops，此时必须保证 RBAC 授权模型中授予了其所有相关 Role，如下:

system:controller:attachdetach-controller
system:controller:certificate-controller
system:controller:cronjob-controller
system:controller:daemon-set-controller
system:controller:deployment-controller
system:controller:disruption-controller
system:controller:endpoint-controller
system:controller:generic-garbage-collector
system:controller:horizontal-pod-autoscaler
system:controller:job-controller
system:controller:namespace-controller
system:controller:node-controller
system:controller:persistent-volume-binder
system:controller:pod-garbage-collector
system:controller:replicaset-controller
system:controller:replication-controller
system:controller:resourcequota-controller
system:controller:route-controller
system:controller:service-account-controller
system:controller:service-controller
system:controller:statefulset-controller
system:controller:ttl-controller
三、Privilege Escalation Prevention and Bootstrapping

RBAC API 会通过阻止用户编辑 Role 或 RoleBinding 来进行特权升级，RBAC 在 API 级别实现了这一机制，所以即使 RBAC authorizer 不被使用也适用。

用户即使在对某个 Role 拥有全部权限的情况下也仅能在其作用范围内(ClusterRole -> 集群范围内，Role -> 当前 namespace 或 集群范围)对其进行 create 和 update 操作； 例如 “user-1” 用户不具有在集群范围内列出 secrets 的权限，那么他也无法在集群范围内创建具有该权限的 ClusterRole，也就是说想传递权限必须先获得该权限；想要允许用户 cretae/update Role 有两种方式:

1、授予一个该用户期望 create/update 的 Role 或者 ClusterRole
2、授予一个包含该用户期望 create/update 的 Role 或者 ClusterRole 的 Role 或者 ClusterRole(有点绕…)；如果用户尝试 crate/update 一个其不拥有的 Role 或者 ClusterRole，则 API 会禁止
用户只有拥有了一个 RoleBind 引用的 Role 全部权限，或者被显示授予了对其具有 bind 的权限下，才能在其作用范围(范围同上)内对其进行 create/update 操作； 例如 “user-1” 在不具有列出集群内 secrets 权限的情况下，也不可能为具有该权限的 Role 创建 ClusterRoleBinding；如果想要用户具有 create/update ClusterRoleBinding 的权限有以下两种方式:

1、授予一个该用户期望 create/update 的 RoleBinding 或者 ClusterRoleBinding 的 Role 或 ClusterRole 的 Role 或 ClusterRole(汉语专8)
2、通过其他方式授予一个该用户 期望 create/update 的 RoleBinding 或者 ClusterRoleBinding 的权限:
2.1、授予一个包含用户期望 create/update 的 RoleBinding 或者 ClusterRoleBinding 的 Role 或 ClusterRole 的 Role 或 ClusterRole(我汉语10级)
2.2、明确的授予用户一个在对特定 Role 或 ClusterRole 进行 bind 的权限
以下样例中，ClusterRole 和 RoleBinding 将允许 “user-1” 用户具有授予其他用户在 “user-1-namespace” namespace 下具有 admin、edit 和 view roles 的权限

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  name: role-grantor
rules:
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["rolebindings"]
  verbs: ["create"]
- apiGroups: ["rbac.authorization.k8s.io"]
  resources: ["clusterroles"]
  verbs: ["bind"]
  resourceNames: ["admin","edit","view"]
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: RoleBinding
metadata:
  name: role-grantor-binding
  namespace: user-1-namespace
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: role-grantor
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: user-1
当使用 bootstrapping 时，初始用户尚没有访问 API 的权限，此时想要授予他们一些尚未拥有的权限是不可能的，此时可以有两种解决方案:

1、通过使用系统级的 system:masters 组从而通过默认绑定绑定到 cluster-admin 超级用户，这样就可以直接沟通 API Server
2、如果 API Server 开启了 --insecure-port 端口，那么可以通过此端口调用完成第一次授权动作
四、Command-line Utilities

通过两个 kubectl 的子命令完成在特定命名空间或集群内的授权管理

4.1、kubectl create rolebinding

在特定 namespae 中创建 Role 或者 ClusterRole 的 RoleBinding 样例

在 acme namespace 中授权用户 bob 具有 admin ClusterRole 的 RoleBinding

kubectl create rolebinding bob-admin-binding --clusterrole=admin --user=bob --namespace=acme
在 acme namespace 中授权名称为 acme:myapp 的 service account 具有 view ClusterRole 的 RoleBinding

kubectl create rolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp --namespace=acme
4.2、kubectl create clusterrolebinding

在全部命名空间中创建 Role 或者 ClusterRole 的 ClusterRoleBinding 样例

在整个集群内授权 “root” 用户具有 cluster-admin ClusterRole 的 ClusterRoleBinding

kubectl create clusterrolebinding root-cluster-admin-binding --clusterrole=cluster-admin --user=root
在整个集群内授权 “kubelet” 用户具有 system:node ClusterRole 的 ClusterRoleBinding

kubectl create clusterrolebinding kubelet-node-binding --clusterrole=system:node --user=kubelet
在 “acme” 命名空间中授权名称为 acme:myapp 的 service account 具有 view ClusterRole 的 ClusterRoleBinding

kubectl create clusterrolebinding myapp-view-binding --clusterrole=view --serviceaccount=acme:myapp
更详细使用请参考命令行帮助文档

五、Service Account Permissions

默认的 RBAC 权限策略仅向 control-plane 组件、nodes 和 controllers 进行授权，不包括 kube-system namespace 以外的 Service Account 进行授权(除了向已经被验证过的用户授予的 discovery 权限之外)

这允许你根据需要向特定的服务账户授予特定的权限；细粒度的权限角色绑定控制会更加安全，但是需要更大的精力来进行权限管理；更加宽松的权限角色绑定控制也许会给一些用户分配其不需要的权限，但是相对来说管理相对更加宽松

从最安全到最不安全的权限管理如下:

5.1、为特定应用程序指定的服务账户授予特定的 Role(最佳实践)

这种方式需要应用在 spec 中设置 serviceAccountName，同时这个 SserviceAccount 必须已经被创建(可以通过 API、manifest 文件或者 通过命令 kubectl create serviceaccount 等)。例如在 “my-namespace” namespace 下授予 “my-sa” ServiceAccount view ClusterRole 如下:

kubectl create rolebinding my-sa-view \
  --clusterrole=view \
  --serviceaccount=my-namespace:my-sa \
  --namespace=my-namespace
5.2、为特定应用程序默认的服务账户授予特定的 Role

如果应用程序在 spec 中没有设置 serviceAccountName，那么将会使用 “default” ServiceAccount。

注意: 如果对 default ServiceAccount 进行 RoleBinding(授权)，那么在当前命名空间内所有没有指定 serviceAccountName 的 pod 都将获得该权限。 例如在 “my-namespace” namespace 下授予 “default” ServiceAccount view ClusterRole 如下:

kubectl create rolebinding default-view \
  --clusterrole=view \
  --serviceaccount=my-namespace:default \
  --namespace=my-namespace
目前大多数 add-ons 运行在 “kube-system” namespace 的 “default” ServiceAccount 下，如果想要 add-ons 使用超级用户的权限只需要对 “kube-system” namespace 下的 “default” ServiceAccount 授予超级用户权限即可，需要注意的是超级用户对 API secrets 具有读写权限，这将导致所有 add-ons 组件具有该权限

kubectl create clusterrolebinding add-on-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:default
5.3、为特定命名空间的所有服务账户授权

如果希望 namespace 中所有应用程序(无论属于哪个 ServiceAccount)都具有某一个 Role，则可以通过将该 Role 授予该 namespace 的 ServiceAccount 组来实现；例如授予 “my-namespace” namespace 下所有 ServiceAccount view ClusterRole 如下:

kubectl create rolebinding serviceaccounts-view \
  --clusterrole=view \
  --group=system:serviceaccounts:my-namespace \
  --namespace=my-namespace
5.4、为集群范围内所有服务账户授权(不建议)

如果你懒得管理每个 namespace 的权限，那么可以将授权扩散到整个集群，将权限授予集群内每个 ServiceAccount；例如授予全部 namespace 中所有 ServiceAccount view ClusterRole:

kubectl create clusterrolebinding serviceaccounts-view \
  --clusterrole=view \
  --group=system:serviceaccounts
5.5、为集群范围内所有服务账户授予超级用户权限(no zuo no die)

如果你根本不关心权限分配，那么可以向集群内所有 namespace 下所有 ServiceAccount 授予超级用户权限；注意: 这将允许具有读取权限的用户创建一个容器从而间接读取到超级用户凭据

kubectl create clusterrolebinding serviceaccounts-cluster-admin \
  --clusterrole=cluster-admin \
  --group=system:serviceaccounts
六、Upgrading from 1.5

在 Kubernetes 1.6 版本之前，许多部署使用了非常宽泛的 ABAC 授权策略，包括授予对所有服务帐户的完整API访问权限；默认的 RBAC 权限策略仅向 control-plane 组件、nodes 和 controllers 进行授权，不包括 kube-system namespace 以外的 Service Account 进行授权(除了向已经被验证过的用户授予的 discovery 权限之外)

这种方式虽然安全性更高，但是 RBAC 授权方式可能影响到已经存在的期望自动获得 API 权限的 workloads，以下有两种解决方案:

6.1、Parallel Authorizers

并行授权策略允许同时运行 RBAC 和 ABAC，并且包含旧的 ABAC 授权策略

--authorization-mode=RBAC,ABAC --authorization-policy-file=mypolicy.jsonl
此时 RBAC 授权控制器将首先处理授权，如果请求被拒绝则转交给 ABAC 授权控制器处理；这种授权方式将会允许 RBAC 和 ABAC 同时处理授权请求，只要目标 Subjects 在 RBAC 或 ABAC 中任意一个授权器授权成功即可

当日志级别设置为 2(–v=2) 或者更高时，可以在 API Server 日志中看到 RBAC 拒绝的日志(以 RBAC DENY: 开头)，你可以通过日志中该信息来确定哪些 Role 应该授予哪些 Subjects。一旦完成所有的授权处理，并且在日志中没有再出现 RBAC 授权拒绝的日志时，就可以删除掉 ABAC 授权

6.2、Permissive RBAC Permissions

您可以使用 RBAC RoleBinding 来复制一个允许的策略。

注意: 以下策略允许所有服务帐户充当集群管理员。在容器中运行的任何应用程序都会自动接收服务帐户凭据，并可以针对 API 执行任何操作，包括查看和修改 secrets 权限；所以这种方法并不推荐。

kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
转载请注明出处，本文采用 CC4.0 协议授权