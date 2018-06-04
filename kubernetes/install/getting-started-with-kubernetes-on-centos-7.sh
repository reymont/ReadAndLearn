

# https://www.vultr.com/docs/getting-started-with-kubernetes-on-centos-7
# Kubernetes master
# Install Kubernetes master packages:
yum install etcd kubernetes-master -y
# Configuration:
# /etc/etcd/etcd.conf
```
# leave rest of the lines unchanged
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_LISTEN_PEER_URLS="http://localhost:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"

# /etc/kubernetes/config
# leave rest of the lines unchanged
KUBE_MASTER="--master=http://kube-master:8080"

# /etc/kubernetes/apiserver
# leave rest of the lines unchanged
KUBE_API_ADDRESS="--address=0.0.0.0"
KUBE_ETCD_SERVERS="--etcd_servers=http://kube-master:2379"
```
# Start Etcd:
systemctl start etcd
# Install and configure Flannel overlay network fabric 
# (this is needed so that containers running on different servers can see each other):
yum install flannel
# Create a Flannel configuration file (flannel-config.json):
{
  "Network": "10.20.0.0/16",
  "SubnetLen": 24,
  "Backend": {
    "Type": "vxlan",
    "VNI": 1
  }  
}
# Set the Flannel configuration in the Etcd server:
etcdctl set coreos.com/network/config < flannel-config.json
# Point Flannel to the Etcd server:
# /etc/sysconfig/flanneld
FLANNEL_ETCD="http://kube-master:2379"

# http://blog.csdn.net/yelllowcong/article/details/78303626
# /etc/sysconfig/flanneld
# 注意这个必须和上面Etcd配置的要一样，不然flannel启动不了
FLANNEL_ETCD_PREFIX="/atomic.io/network"
etcdctl  mk /atomic.io/network/config '{"Network":"172.17.0.0/16", "SubnetMin": "172.17.1.0", "SubnetMax": "172.17.254.0"}'

# Enable services so that they start on boot:
systemctl enable etcd
systemctl enable kube-apiserver
systemctl enable kube-controller-manager
systemctl enable kube-scheduler
systemctl enable flanneld
systemctl start etcd
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start flanneld
systemctl status etcd
systemctl status kube-apiserver
systemctl status kube-controller-manager
systemctl status kube-scheduler
systemctl status flanneld
# Reboot server.

# Kubernetes node
# Install Kubernetes node packages:
yum install docker kubernetes-node -y
# yum remove kubernetes-node -y
# The next two steps will configure Docker to use overlayfs for better performance. For more information visit this blog post:
# Delete the current docker storage directory:
systemctl stop docker
rm -rf /var/lib/docker
# Change configuration files:
# /etc/sysconfig/docker
# leave rest of lines unchanged
OPTIONS='--selinux-enabled=false'
# /etc/sysconfig/docker
# leave rest of lines unchanged
DOCKER_STORAGE_OPTIONS=-s overlay
# Configure kube-node1 to use our previously configured master:
# /etc/kubernetes/config
# leave rest of lines unchanged
KUBE_MASTER="--master=http://kube-master:8080"

# /etc/kubernetes/kubelet
# leave rest of the lines unchanged
KUBELET_ADDRESS="--address=0.0.0.0"
# comment this line, so that the actual hostname is used to register the node
# KUBELET_HOSTNAME="--hostname_override=127.0.0.1"
KUBELET_API_SERVER="--api_servers=http://kube-master:8080"

# Install and configure Flannel overlay network fabric 
# (again - this is needed so that containers running on different servers can see each other):
yum install flannel
# Point Flannel to the Etcd server:

# /etc/sysconfig/flanneld
FLANNEL_ETCD="http://kube-master:2379"
# Enable services:
systemctl enable docker
systemctl enable flanneld
systemctl enable kubelet
systemctl enable kube-proxy
systemctl start docker
systemctl start flanneld
systemctl start kubelet
systemctl start kube-proxy
# Reboot the server.

# Test your Kubernetes server
# After all of the servers have rebooted, check if your Kubernetes cluster is operational:
kubectl get nodes

# 追踪日志
# http://blog.csdn.net/zstack_org/article/details/56274966
# 要主动追踪当前正在编写的日志，大家可以使用-f标记。方式同样为tail -f：
journalctl -f

# http://www.jianshu.com/p/9163585d6780
# Orphaned pod found but volume paths are still present on disk.
# pod由于volume paths没有被清除，手动到/var/lib/kubelet/pods/下清除该pod

# http://www.cnblogs.com/ivictor/p/4998032.html
# retry after the token is automatically created and added to the service account
# 1> 修改/etc/kubernetes/apiserver文件中KUBE_ADMISSION_CONTROL参数。
KUBE_ADMISSION_CONTROL="--admission_control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"
# 去掉“ServiceAccount”选项。
# 2> 重启kube-apiserver服务
systemctl restart kube-apiserver。

# http://blog.csdn.net/learner198461/article/details/78036854?locationNum=4&fps=1
docker pull registry.access.redhat.com/rhel7/pod-infrastructure:latest
yum install *rhsm* -y

# http://www.cnblogs.com/ivictor/p/4998032.html
# 创建Pod过程中，显示异常，通过查看日志/var/log/messages，有以下报错信息： 
Nov 26 21:52:06 localhost kube-apiserver: E1126 21:52:06.697708    1963 server.go:454] Unable to generate self signed cert: open /var/run/kubernetes/apiserver.crt: permission denied
Nov 26 21:52:06 localhost kube-apiserver: E1126 21:52:06.697818    1963 server.go:464] Unable to listen for secure (open /var/run/kubernetes/apiserver.crt: no such file or directory); will try again.
# 解决方法有两种：
## 第一种方法：
vim /usr/lib/systemd/system/kube-apiserver.service
```
[Service]
PermissionsStartOnly=true
ExecStartPre=-/usr/bin/mkdir /var/run/kubernetes
ExecStartPre=/usr/bin/chown -R kube:kube /var/run/kubernetes/
```
systemctl daemon-reload
systemctl restart kube-apiserver
## 第二种方法：
vim /etc/kubernetes/apiserver    
KUBE_API_ARGS="--secure-port=0"
# 在KUBE_API_ARGS加上--secure-port=0参数。
# 原因如下：
# --secure-port=6443: The port on which to serve HTTPS with authentication and authorization. If 0, don't serve HTTPS at all.

# https://github.com/kubernetes/kubernetes/issues/53683
# kubectl 1.8 commands print OpenAPI fallback warning every time talking to 1.6 clusters
# You really shouldn't expect kubectl 1.8 to work with kubernetes 1.6.
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl\
 && chmod +x kubectl\
 && sudo mv kubectl /usr/local/bin/
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/darwin/amd64/kubectl\
 && chmod +x kubectl\
 && sudo mv kubectl /usr/local/bin/
 