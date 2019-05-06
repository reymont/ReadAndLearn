

# https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm-driver

curl -sS https://get.fabric8.io/download.txt | bash


minikube start
ssh docker@192.168.99.101
docker/tcuser

yum install -y wget
# Install libvirt and qemu-kvm on your system, e.g.
yum install libvirt-daemon-kvm qemu-kvm -y
usermod -a -G libvirt $(whoami)
# Add yourself to the libvirtd group (use libvirt group for rpm based distros) so you don't need to sudo
# Fedora/CentOS/RHEL
usermod -a -G libvirt $(whoami)
# Update your current session for the group change to take effect
# Fedora/CentOS/RHEL
$ newgrp libvirt

# http://fabric8.io/guide/getStarted/gofabric8.html
gofabric8 help start
gofabric8 start --memory=6000 --cpus=2
# At any point you can validate your cluster via:
gofabric8 validate
# To open the Fabric8 Developer Console type the following:
gofabric8 console
# To see the URL so you can open it in another browser you can type:
gofabric8 service fabric8 --url
# You can use the same command to open other consoles too like gogs, Jenkins or Nexus
gofabric8 service gogs
gofabric8 service jenkins
gofabric8 service nexus

# 检查minikube cluster kubect的状态gofabric8 start --vm-driver=virtualbox
gofabric8.exe status
gofabric8 start --vm-driver=virtualbox

# 清理
kubectl delete deployments --all --now
kubectl delete services --all --now
kubectl delete pods --all --now
