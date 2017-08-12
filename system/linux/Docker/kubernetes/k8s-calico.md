


* [Calico-https-etcd-k8s-v2.1.5最新版集群布署 - 小刚的博客 - CSDN博客 ](http://blog.csdn.net/idea77/article/details/73090403)

看了下calico k8s 布署全网文档还是比较少的，为了大家少踩坑，特拟写此文，如有任何问题，欢迎各位留言交流


目前k8s 网络最快的第一就是Calico          第二种稍慢flannel ，根据自己的网络环境条件来定

目前经本人测试calico v2.15版本的集群 在k8s 1.6的集群版  此文基于centos7    

注意k8s1.6以上kubelet 的bug特别多，大家要注意。





calico即可以加入现有集群也可以初始化集群的时候布署

有几点说明一下 两种布署方案，一般集群都配有ssl证书和非证书的情况

第一种无https 连接etcd方案

第二种https 连接etcd集群方案

1. http 模式布署即没有证书，直接连接etcd

2.加载etcd https证书模式，有点麻烦



Calico可以不依赖现有集群可以直接布署


kubecel create -f  Calico.yaml


在kubelet配置文件指定cni插件的时候calico还没启动，会报错，集群会报kubectl get nodes

jenkins-2       NotReady     1d        v1.6.4
node1.txg.com  NotReady     2d        v1.6.4
node2.txg.com   NotReady     1d        v1.6.4
此时kubelet无法和apiserver建立正常状态，因为我们配置文件指定了cni插件模式，此时只有DaemonSet 的   hostNetwork: true     pod 可以启动

这时不要着急，等Calico插件node节点布署完成后即正常，Calico 会在每一个k8s node上启动一个DaemonSet常驻节点 初始化cni插件，目录为宿主机/etc/cni ; /opt/cni

DaemonSet pod为永久常驻node 网络模式为hostnetwork 所以才可以启动，如果，因为此时k8s不会启动cni的pod模式,cni网络还没完成，此时网络为hostnetwork模式
DaemonSet 没有初始化完成的时候kubectl create -f  nginx.yaml是会失败的，因为 集群还没有Ready   ，确认kubelet无误，集群即可正常工作

[root@master3 calico]# kubectl get nodes

NAME            STATUS    AGE       VERSION
jenkins-2       Ready     1d        v1.6.4
node1.txg.com   Ready     2d        v1.6.4
node2.txg.com   Ready     1d        v1.6.4
正常如下

[root@master3 calico]# kubectl get ds --all-namespaces 
NAMESPACE     NAME          DESIRED   CURRENT   READY     UP-TO-DATE   AVAILABLE   NODE-SELECTOR   AGE
kube-system   calico-node   5         5         5         5            5           <none>          1d
[root@master3 calico]# 
此时k8s 网络已初始化完成

具体流程复制下面的yaml启动即可 如下 

# Calico Version v2.1.5
# http://docs.projectcalico.org/v2.1/releases#v2.1.5
# This manifest includes the following component versions:
# 此处为原始镜相，先准备好三个镜相下载好，我这里打了tag到私有仓库
#   calico/node:v1.1.3
#   calico/cni:v1.8.0
#   calico/kube-policy-controller:v0.5.4
#   kubelet 需要配配加入参数 "--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
#   kube-proxy 配置加入参数 "--proxy-mode=iptables"
#内核 调优 所有节点 echo "net.netfilter.nf_conntrack_max=1000000" >> /etc/sysctl.conf  所有节点
#注意，所有节点必需布署kubelet 和Docker 包括k8s master主节点，因为是用DaemonSet常驻节点 初始化cni插件
#注意，calicoctl 需要配置文件才能和etcd 通讯此处是个大坑，用于查看集群状态 
#所有docker.service 服务/lib/systemd/system/docker.service 注释#EnvironmentFile=/etc/profile.d/flanneld.env 配置
#取消#--bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} ;重启执行systemctl daemon-reload  ;docker.service
#wget -c  https://github.com/projectcalico/calicoctl/releases/download/v1.1.3/calicoctl && chmod +x calicoctl
##master上需要配置 调用calicoctl 这个用来配置calico集群管理ctl工具，需要/etc/calico/calicoctl.cfg  引用etcd
 
非http 连接etcd  配置
#[root@master3 dashboard]# cat /etc/calico/calicoctl.cfg 
kind: calicoApiConfig
apiVersion: v1
kind: calicoApiConfig
metadata:
spec:
  datastoreType: "etcdv2"
    etcdEndpoints: "http://192.168.1.65:2379,http://192.168.1.66:2379,http://192.168.1.67:2379"

https 如下

[root@master3 calico]# cat /etc/calico/calicoctl.cfg 
kind: calicoApiConfig
apiVersion: v1
kind: calicoApiConfig
metadata:
spec:
  datastoreType: "etcdv2"
  etcdEndpoints: "https://192.168.1.65:2379,https://192.168.1.66:2379,https://192.168.1.67:2379"
  etcdKeyFile: "/etc/kubernetes/ssl/kubernetes-key.pem"
  etcdCertFile: "/etc/kubernetes/ssl/kubernetes.pem"
  etcdCACertFile: "/etc/kubernetes/ssl/ca.pem"

##删除pool默认可能会有宿主网段IP 池
##建 立新的ipool 池方法
#
#
#[root@master3 calico]# cat pool.yaml 
#apiVersion: v1
#kind: ipPool
#metadata:
#  cidr: 172.1.0.0/16
#  spec:
#    ipip:
#        enabled: true
#            mode: cross-subnet
#              nat-outgoing: true
#                disabled: false
#
#                  
#                  calicoctl delete ipPool 192.168.0.0/16
#                  calicoctl apply -f pool.yaml 
#
#查看集群状态
#                  [root@master1 ~]# calicoctl node status
#                  Calico process is running.
#
#                  IPv4 BGP status
#                  +--------------+-------------------+-------+----------+--------------------------------+
#                  | PEER ADDRESS |     PEER TYPE     | STATE |  SINCE   |              INFO              |
#                  +--------------+-------------------+-------+----------+--------------------------------+
#                  | 192.168.1.62 | node-to-node mesh | up    | 08:29:36 | Established                    |
#                  | 192.168.1.63 | node-to-node mesh | up    | 08:29:36 | Established                    |
#                  | 192.168.1.68 | node-to-node mesh | start | 14:13:42 | Connect Socket: Connection     |
#                  |              |                   |       |          | refused                        |
#                  | 192.168.2.68 | node-to-node mesh | up    | 14:13:45 | Established                    |
#                  | 192.168.2.72 | node-to-node mesh | up    | 14:12:18 | Established                    |
#                  | 192.168.2.69 | node-to-node mesh | up    | 14:12:15 | Established                    |
#                  | 192.168.1.69 | node-to-node mesh | up    | 14:12:22 | Established                    |
#                  +--------------+-------------------+-------+----------+--------------------------------+
#

注意，开启rbac的请创建rbac授权，没有开启的就不用创建，rbac开启会导致calico无法分配pod ip

kubectl create -f  rbac.yaml 

[root@master3 calico]# cat rbac.yaml 
# Calico Version master
# http://docs.projectcalico.org/master/releases#master


---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: calico-policy-controller
  namespace: kube-system
rules:
  - apiGroups:
    - ""
    - extensions
    resources:
      - pods
      - namespaces
      - networkpolicies
    verbs:
      - watch
      - list
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: calico-policy-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: calico-policy-controller
subjects:
- kind: ServiceAccount
  name: calico-policy-controller
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: calico-node
  namespace: kube-system
rules:
  - apiGroups: [""]
    resources:
      - pods
      - nodes
    verbs:
      - get
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: calico-node
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: calico-node
subjects:
- kind: ServiceAccount
  name: calico-node
  namespace: kube-system



1.无https 连接etcd方案

kubecel create -f  Calico.yaml
cat   Calico.yaml





# This ConfigMap is used to configure a self-hosted Calico installation.


kind: ConfigMap
apiVersion: v1
metadata:
  name: calico-config
  namespace: kube-system
data:
  # Configure this with the location of your etcd cluster.注意此处配置 etcd https 集群ip地址
  etcd_endpoints: "http://192.168.1.65:2379,http://192.168.1.66:2379,http://192.168.1.67:2379"


  # Configure the Calico backend to use.
  calico_backend: "bird"


  # The CNI network configuration to install on each node.
  cni_network_config: |-
    {
        "name": "k8s-pod-network",
        "type": "calico",
        "etcd_endpoints": "__ETCD_ENDPOINTS__",
        "etcd_key_file": "__ETCD_KEY_FILE__",
        "etcd_cert_file": "__ETCD_CERT_FILE__",
        "etcd_ca_cert_file": "__ETCD_CA_CERT_FILE__",
        "log_level": "info",
        "ipam": {
            "type": "calico-ipam"
        },
        "policy": {
            "type": "k8s",
            "k8s_api_root": "https://__KUBERNETES_SERVICE_HOST__:__KUBERNETES_SERVICE_PORT__",
            "k8s_auth_token": "__SERVICEACCOUNT_TOKEN__"
        },
        "kubernetes": {
            "kubeconfig": "__KUBECONFIG_FILEPATH__"
        }
    }


  # If you're using TLS enabled etcd uncomment the following.
  # You must also populate the Secret below with these files.
  etcd_ca: ""   # "/calico-secrets/etcd-ca"
  etcd_cert: "" # "/calico-secrets/etcd-cert"
  etcd_key: ""  # "/calico-secrets/etcd-key"


---


# The following contains k8s Secrets for use with a TLS enabled etcd cluster.
# For information on populating Secrets, see http://kubernetes.io/docs/user-guide/secrets/
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: calico-etcd-secrets
  namespace: kube-system
data:
  # Populate the following files with etcd TLS configuration if desired, but leave blank if
  # not using TLS for etcd.
  # This self-hosted install expects three files with the following names.  The values
  # should be base64 encoded strings of the entire contents of each file.
  # etcd-key: null
  # etcd-cert: null
  # etcd-ca: null


---


# This manifest installs the calico/node Container, as well
# as the Calico CNI plugins and network config on
# each master and worker node in a Kubernetes cluster.
kind: DaemonSet
apiVersion: extensions/v1beta1
metadata:
  name: calico-node
  namespace: kube-system
  labels:
    k8s-app: calico-node
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  template:
    metadata:
      labels:
        k8s-app: calico-node
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
        scheduler.alpha.kubernetes.io/tolerations: |
          [{"key": "dedicated", "value": "master", "effect": "NoSchedule" },
           {"key":"CriticalAddonsOnly", "operator":"Exists"}]
    spec:
      hostNetwork: true
      containers:
        # Runs calico/node container on each Kubernetes node.  This
        # container programs network policy and routes on each
        # host.
        - name: calico-node
          image: 192.168.1.103/k8s_public/calico-node:v1.1.3
          env:
            # The location of the Calico etcd cluster.
            - name: ETCD_ENDPOINTS
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_endpoints
            # Choose the backend to use.
            - name: CALICO_NETWORKING_BACKEND
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: calico_backend
            # Disable file logging so `kubectl logs` works.
            - name: CALICO_DISABLE_FILE_LOGGING
              value: "true"
            # Set Felix endpoint to host default action to ACCEPT.
            - name: FELIX_DEFAULTENDPOINTTOHOSTACTION
              value: "ACCEPT"
            # Configure the IP Pool from which Pod IPs will be chosen.
            - name: CALICO_IPV4POOL_CIDR
              #value: "192.168.0.0/16"此处配置ip分配pod 的池 
              value: "172.1.0.0/16"
            - name: CALICO_IPV4POOL_IPIP
              value: "always"
            # Disable IPv6 on Kubernetes.
            - name: FELIX_IPV6SUPPORT
              value: "false"
            # Set Felix logging to "info"
            - name: FELIX_LOGSEVERITYSCREEN
              value: "info"
            # Location of the CA certificate for etcd.
            - name: ETCD_CA_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_ca
            # Location of the client key for etcd.
            - name: ETCD_KEY_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_key
            # Location of the client certificate for etcd.
            - name: ETCD_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_cert
            # Auto-detect the BGP IP address.
            - name: IP
              value: ""
          securityContext:
            privileged: true
          resources:
            requests:
              cpu: 250m
          volumeMounts:
            - mountPath: /lib/modules
              name: lib-modules
              readOnly: true
            - mountPath: /var/run/calico
              name: var-run-calico
              readOnly: false
            - mountPath: /calico-secrets
              name: etcd-certs
        # This container installs the Calico CNI binaries
        # and CNI network config file on each node.
        - name: install-cni
          image: 192.168.1.103/k8s_public/calico-cni:v1.8.0
          command: ["/install-cni.sh"]
          env:
            # The location of the Calico etcd cluster.
            - name: ETCD_ENDPOINTS
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_endpoints
            # The CNI network config to install on each node.
            - name: CNI_NETWORK_CONFIG
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: cni_network_config
          volumeMounts:
            - mountPath: /host/opt/cni/bin
              name: cni-bin-dir
            - mountPath: /host/etc/cni/net.d
              name: cni-net-dir
            - mountPath: /calico-secrets
              name: etcd-certs
      volumes:
        # Used by calico/node.
        - name: lib-modules
          hostPath:
            path: /lib/modules
        - name: var-run-calico
          hostPath:
            path: /var/run/calico
        # Used to install CNI.
        - name: cni-bin-dir
          hostPath:
            path: /opt/cni/bin
        - name: cni-net-dir
          hostPath:
            path: /etc/cni/net.d
        # Mount in the etcd TLS secrets.
        - name: etcd-certs
          secret:
            secretName: calico-etcd-secrets


---


# This manifest deploys the Calico policy controller on Kubernetes.
# See https://github.com/projectcalico/k8s-policy
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: calico-policy-controller
  namespace: kube-system
  labels:
    k8s-app: calico-policy
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ''
    scheduler.alpha.kubernetes.io/tolerations: |
      [{"key": "dedicated", "value": "master", "effect": "NoSchedule" },
       {"key":"CriticalAddonsOnly", "operator":"Exists"}]
spec:
  # The policy controller can only have a single active instance.
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      name: calico-policy-controller
      namespace: kube-system
      labels:
        k8s-app: calico-policy
    spec:
      # The policy controller must run in the host network namespace so that
      # it isn't governed by policy that would prevent it from working.
      hostNetwork: true
      containers:
        - name: calico-policy-controller
          image: 192.168.1.103/k8s_public/kube-policy-controller:v0.5.4
          env:
            # The location of the Calico etcd cluster.
            - name: ETCD_ENDPOINTS
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_endpoints
            # Location of the CA certificate for etcd.
            - name: ETCD_CA_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_ca
            # Location of the client key for etcd.
            - name: ETCD_KEY_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_key
            # Location of the client certificate for etcd.
            - name: ETCD_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_cert
            # The location of the Kubernetes API.  Use the default Kubernetes
            # service for API access.
            - name: K8S_API
              value: "https://kubernetes.default:443"
            # Since we're running in the host namespace and might not have KubeDNS
            # access, configure the container's /etc/hosts to resolve
            # kubernetes.default to the correct service clusterIP.
            - name: CONFIGURE_ETC_HOSTS
              value: "true"
          volumeMounts:
            # Mount in the etcd TLS secrets.
            - mountPath: /calico-secrets
              name: etcd-certs
      volumes:
        # Mount in the etcd TLS secrets.
        - name: etcd-certs
          secret:
            secretName: calico-etcd-secrets

-------
2.https  证书连接etcd方案

kubecel create -f  Calico-https.yaml
cat   Calico-https.yaml



------- 
#注意最后送上https的方式的calico 调用etcd 通讯存储集群配置，保证每个节点存存在三个文件目录/etc/kubernetes/ssl/etcd-ca   /etc/kubernetes/ssl/etcd-cert /etc/kubernetes/ssl/etcd-key
#这三个文件是用kubernets的证书复制重命名过来的 也就是etcd的证书 cd /etc/kubernetes/ssl/ ; cp kubernetes-key.pem etcd-key; cp  kubernetes.pem etcd-cert; cp ca.pem etcd-ca 
#下发到所有的kubelet 的节点 /etc/kubernetes/ssl/ 下
 #calico里面一定要叫这个名字，原理如下，然后用hostpath 挂载卷        - name: etcd-certs    调用configmap 里面的  etcd_ca: "/calico-secrets/etcd-ca"   # "/calico-secrets/etcd-ca"
  #etcd_cert: "/calico-secrets/etcd-cert" # 最终容器证书目录 "/calico-secrets/etcd-cert"
 # etcd_key: "/calico-secrets/etcd-key"  # "/calico-secrets/etcd-key"
  #        hostPath:
  #          path: /etc/kubernetes/ssl
#calico-https-etcd calico配置文件如下


# This ConfigMap is used to configure a self-hosted Calico installation.


kind: ConfigMap
apiVersion: v1
metadata:
  name: calico-config
  namespace: kube-system
data:
  # Configure this with the location of your etcd cluster.注意此处配置 etcd集群ip地址
  etcd_endpoints: "https://192.168.1.65:2379,https://192.168.1.66:2379,https://192.168.1.67:2379"


  # Configure the Calico backend to use.
  calico_backend: "bird"


  # The CNI network configuration to install on each node.
  cni_network_config: |-
    {
        "name": "k8s-pod-network",
        "type": "calico",
        "etcd_endpoints": "__ETCD_ENDPOINTS__",
        "etcd_key_file": "__ETCD_KEY_FILE__",
        "etcd_cert_file": "__ETCD_CERT_FILE__",
        "etcd_ca_cert_file": "__ETCD_CA_CERT_FILE__",
        "log_level": "info",
        "ipam": {
            "type": "calico-ipam"
        },
        "policy": {
            "type": "k8s",
            "k8s_api_root": "https://__KUBERNETES_SERVICE_HOST__:__KUBERNETES_SERVICE_PORT__",
            "k8s_auth_token": "__SERVICEACCOUNT_TOKEN__"
        },
        "kubernetes": {
            "kubeconfig": "__KUBECONFIG_FILEPATH__"
        }
    }


  # If you're using TLS enabled etcd uncomment the following.
  # You must also populate the Secret below with these files.
  etcd_ca: "/calico-secrets/etcd-ca"   # "/calico-secrets/etcd-ca"
  etcd_cert: "/calico-secrets/etcd-cert" # "/calico-secrets/etcd-cert"
  etcd_key: "/calico-secrets/etcd-key"  # "/calico-secrets/etcd-key"


---


# The following contains k8s Secrets for use with a TLS enabled etcd cluster.
# For information on populating Secrets, see http://kubernetes.io/docs/user-guide/secrets/
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: calico-etcd-secrets
  namespace: kube-system
data:
  # Populate the following files with etcd TLS configuration if desired, but leave blank if
  # not using TLS for etcd.
  # This self-hosted install expects three files with the following names.  The values
  # should be base64 encoded strings of the entire contents of each file.
  # etcd-key: null
  # etcd-cert: null
  # etcd-ca: null


---


# This manifest installs the calico/node container, as well
# as the Calico CNI plugins and network config on
# each master and worker node in a Kubernetes cluster.
kind: DaemonSet
apiVersion: extensions/v1beta1
metadata:
  name: calico-node
  namespace: kube-system
  labels:
    k8s-app: calico-node
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  template:
    metadata:
      labels:
        k8s-app: calico-node
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
        scheduler.alpha.kubernetes.io/tolerations: |
          [{"key": "dedicated", "value": "master", "effect": "NoSchedule" },
           {"key":"CriticalAddonsOnly", "operator":"Exists"}]
    spec:
      hostNetwork: true
      containers:
        # Runs calico/node container on each Kubernetes node.  This
        # container programs network policy and routes on each
        # host.
        - name: calico-node
          image: 192.168.1.103/k8s_public/calico-node:v1.1.3
          env:
            # The location of the Calico etcd cluster.
            - name: ETCD_ENDPOINTS
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_endpoints
            # Choose the backend to use.
            - name: CALICO_NETWORKING_BACKEND
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: calico_backend
            # Disable file logging so `kubectl logs` works.
            - name: CALICO_DISABLE_FILE_LOGGING
              value: "true"
            # Set Felix endpoint to host default action to ACCEPT.
            - name: FELIX_DEFAULTENDPOINTTOHOSTACTION
              value: "ACCEPT"
            # Configure the IP Pool from which Pod IPs will be chosen.
            - name: CALICO_IPV4POOL_CIDR
              #value: "192.168.0.0/16"此处配置ip分配pod 的池 
              value: "172.1.0.0/16"
            - name: CALICO_IPV4POOL_IPIP
              value: "always"
            # Disable IPv6 on Kubernetes.
            - name: FELIX_IPV6SUPPORT
              value: "false"
            # Set Felix logging to "info"
            - name: FELIX_LOGSEVERITYSCREEN
              value: "info"
            # Location of the CA certificate for etcd.
            - name: ETCD_CA_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_ca
            # Location of the client key for etcd.
            - name: ETCD_KEY_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_key
            # Location of the client certificate for etcd.
            - name: ETCD_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_cert
            # Auto-detect the BGP IP address.
            - name: IP
              value: ""
          securityContext:
            privileged: true
          resources:
            requests:
              cpu: 250m
          volumeMounts:
            - mountPath: /lib/modules
              name: lib-modules
              readOnly: true
            - mountPath: /var/run/calico
              name: var-run-calico
              readOnly: false
            - mountPath: /calico-secrets
              name: etcd-certs
        # This container installs the Calico CNI binaries
        # and CNI network config file on each node.
        - name: install-cni
          image: 192.168.1.103/k8s_public/calico-cni:v1.8.0
          command: ["/install-cni.sh"]
          env:
            # The location of the Calico etcd cluster.
            - name: ETCD_ENDPOINTS
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_endpoints
            # The CNI network config to install on each node.
            - name: CNI_NETWORK_CONFIG
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: cni_network_config
          volumeMounts:
            - mountPath: /host/opt/cni/bin
              name: cni-bin-dir
            - mountPath: /host/etc/cni/net.d
              name: cni-net-dir
            - mountPath: /calico-secrets
              name: etcd-certs
      volumes:
        # Used by calico/node.
        - name: lib-modules
          hostPath:
            path: /lib/modules
        - name: var-run-calico
          hostPath:
            path: /var/run/calico
        # Used to install CNI.
        - name: cni-bin-dir
          hostPath:
            path: /opt/cni/bin
        - name: cni-net-dir
          hostPath:
            path: /etc/cni/net.d
        - name: etcd-certs 
          hostPath:
            path: /etc/kubernetes/ssl


        # Mount in the etcd TLS secrets.
      #  - name: etcd-certs
      #    secret:
      #      secretName: calico-etcd-secrets


---


# This manifest deploys the Calico policy controller on Kubernetes.
# See https://github.com/projectcalico/k8s-policy
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: calico-policy-controller
  namespace: kube-system
  labels:
    k8s-app: calico-policy
  annotations:
    scheduler.alpha.kubernetes.io/critical-pod: ''
    scheduler.alpha.kubernetes.io/tolerations: |
      [{"key": "dedicated", "value": "master", "effect": "NoSchedule" },
       {"key":"CriticalAddonsOnly", "operator":"Exists"}]
spec:
  # The policy controller can only have a single active instance.
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      name: calico-policy-controller
      namespace: kube-system
      labels:
        k8s-app: calico-policy
    spec:
      # The policy controller must run in the host network namespace so that
      # it isn't governed by policy that would prevent it from working.
      hostNetwork: true
      containers:
        - name: calico-policy-controller
          image: 192.168.1.103/k8s_public/kube-policy-controller:v0.5.4
          env:
            # The location of the Calico etcd cluster.
            - name: ETCD_ENDPOINTS
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_endpoints
            # Location of the CA certificate for etcd.
            - name: ETCD_CA_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_ca
            # Location of the client key for etcd.
            - name: ETCD_KEY_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_key
            # Location of the client certificate for etcd.
            - name: ETCD_CERT_FILE
              valueFrom:
                configMapKeyRef:
                  name: calico-config
                  key: etcd_cert
            # The location of the Kubernetes API.  Use the default Kubernetes
            # service for API access.
            - name: K8S_API
              value: "https://kubernetes.default:443"
              #value: "https://192.168.1.63:8080"


            # Since we're running in the host namespace and might not have KubeDNS
            # access, configure the container's /etc/hosts to resolve
            # kubernetes.default to the correct service clusterIP.
            - name: CONFIGURE_ETC_HOSTS
              value: "true"
          volumeMounts:
            # Mount in the etcd TLS secrets.
            - mountPath: /calico-secrets
              name: etcd-certs
      volumes:
        # Mount in the etcd TLS secrets.
      #  - name: etcd-certs
      #    secret:
      #      secretName: calico-etcd-secrets
        - name: etcd-certs
          hostPath:
            path: /etc/kubernetes/ssl


------
检查状态 所有node启动正常

[root@master3 calico]# kubectl get ds,pod --all-namespaces -o wide|grep calico 
kube-system   ds/calico-node   5         5         5         5            5           <none>          1d        calico-node,install-cni   192.168.1.103/k8s_public/calico-node:v1.1.3,192.168.1.103/k8s_public/calico-cni:v1.8.0   k8s-app=calico-node


kube-system   po/calico-node-7xjtm                           2/2       Running   0          22h       192.168.2.68    node3.txg.com
kube-system   po/calico-node-gpng4                           2/2       Running   6          1d        192.168.1.68    node1.txg.com
kube-system   po/calico-node-kl72c                           2/2       Running   4          1d        192.168.2.69    node4.txg.com
kube-system   po/calico-node-klb4b                           2/2       Running   0          22h       192.168.2.72    jenkins-2
kube-system   po/calico-node-w9f9x                           2/2       Running   4          1d        192.168.1.69    node2.txg.com
kube-system   po/calico-policy-controller-2361802377-2tx4k   1/1       Running   0          22h       192.168.1.68    node1.txg.com
[root@master3 calico]# 
可能有人会说DaemonSet  模式的话,k8s 的node 节点挂了会怎么样，大家可以测试一下

下面我用ansible删除所有节点的配置和docker文件

停止所有服务

ansible -m shell -a "systemctl daemon-reload; systemctl  stop  kubelet.service kube-proxy.service docker.service "  'nodes'

删除文件

ansible -m shell -a " rm -rf /etc/cni/* ;rm -rf /opt/cni/* ; rm -rf /var/lib/docker/*   " 'nodes'
重启node

 ansible -m shell -a " reboot  " 'nodes'
重启后我们发现所有k8s node节点的 DaemonSet  Calico 服务已经重新创建了，集群正常，完全正常。

所有node cni 正常之后即可正常创建所有服务kube-dns kube-dashboard 等