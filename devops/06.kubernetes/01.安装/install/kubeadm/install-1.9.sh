

setenforce 0
vi /etc/selinux/config
SELINUX=disabled

# 创建/etc/sysctl.d/k8s.conf文件，添加如下内容：
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
# 执行sysctl -p /etc/sysctl.d/k8s.conf使修改生效。

# 1.2安装Docker
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum list docker-ce.x86_64  --showduplicates |sort -r
# Kubernetes 1.8已经针对Docker的1.11.2, 1.12.6, 1.13.1和17.03等版本做了验证。 因为我们这里在各节点安装docker的17.03.2版本。
yum makecache fast

yum install -y --setopt=obsoletes=0 \
  docker-ce-17.03.2.ce-1.el7.centos \
  docker-ce-selinux-17.03.2.ce-1.el7.centos

systemctl start docker
systemctl enable docker

# yum erase -y kubelet kubeadm kubectl 
yum install -y kubelet kubeadm kubectl

kubeadm init --apiserver-advertise-address 172.20.62.42
kubectl get node
kubectl get pod --all-namespaces -o wide
journalctl -fxu kubelet
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
# 接下来安装flannel network add-on：
# kubectl delete -f  kube-flannel.yml
## 检查 flannel
kubectl get pod --all-namespaces -o wide
kubectl delete -n kube-system deployment kube-dns
# kubectl get svc --all-namespaces -o wide
kubectl logs -n kube-system kube-dns-6f4fd4bdf-l5kls kubedns
kubectl logs -n kube-system kube-dns-6f4fd4bdf-l5kls dnsmasq
kubectl logs -n kube-system kube-dns-6f4fd4bdf-l5kls sidecar
# 确认解析正常:
yum install bind-utils -y
nslookup kubernetes.default
nslookup kubernetes.default.svc.cluster.local
# 删除非必须的dns
cat /etc/resolv.conf
# 重置kube-dns
# https://github.com/heptio/aws-quickstart/issues/69
kubectl scale deploy/kube-dns -n kube-system --replicas=0
kubectl scale deploy/kube-dns -n kube-system --replicas=1
# Waiting for services and endpoints to be initialized from apiserver
  
# kubectl describe -n kube-system pod kube-dns-6f4fd4bdf-jsn46
# kubectl delete -n kube-system pod kube-dns-6f4fd4bdf-tbr54
# kubectl logs -n kube-system pod kube-dns-6f4fd4bdf-jsn46

#-----------------------------------------------------------------------------#
kubeadm init\
 --pod-network-cidr 192.168.0.0/16\
 --apiserver-advertise-address 172.20.62.42
kubeadm init\
 --pod-network-cidr 192.168.0.0/16\
 --service-cidr 10.96.0.0/12\
 --apiserver-advertise-address 172.20.62.42
# https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/#requirements--limitations
# calico
kubectl apply -f https://docs.projectcalico.org/v2.6/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml

# dns
yum erase -y dnsmasq
yum install -y dnsmasq
/usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper
/usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/docker-machines.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper

# kubeadm init\
#  --kubernetes-version=v1.9.0\
#  --pod-network-cidr=10.244.0.0/16\
#  --apiserver-advertise-address=192.168.61.11\
#  --ignore-preflight-errors=Swap
# Port 10250 is in use
systemctl stop kubelet
rm -rf /var/lib/etcd

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
https://kubernetes.io/docs/concepts/cluster-administration/addons/
# You can now join any number of machines by running the following on each node
kubeadm join --token 11db13.0f04e11150570c7e 172.20.62.42:6443\
 --discovery-token-ca-cert-hash sha256:907aa6faf77f794f43cdd421440109764a9abcd0c0260f6f8e0a4133a0d61f0f


# 查看一下集群状态：
kubectl get cs
# NAME                 STATUS    MESSAGE              ERROR
# scheduler            Healthy   ok
# controller-manager   Healthy   ok
# etcd-0               Healthy   {"health": "true"}

# 集群初始化如果遇到问题，可以使用下面的命令进行清理：
kubeadm reset
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/
