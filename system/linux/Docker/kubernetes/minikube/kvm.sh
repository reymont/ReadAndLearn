

# https://github.com/kubernetes/minikube/blob/master/docs/drivers.md#kvm2-driver
# kvm2
yum install -y libvirt libvirt-daemon-kvm qemu-kvm virt-manager
usermod -a -G libvirt $(whoami)
newgrp libvirt
minikube start --vm-driver kvm2

curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-kvm2\
 && chmod +x docker-machine-driver-kvm2\
 && sudo mv docker-machine-driver-kvm2 /usr/bin/

cat /etc/group | grep libvir
virsh -c qemu:///system list
# error: failed to connect to the hypervisor
# error: Failed to connect socket to '/var/run/libvirt/libvirt-sock': Permission denied

# too many open files
# http://blog.csdn.net/hua00shao/article/details/45044445?locationNum=6&fps=1
ulimit -a
ulimit -n 2048

# minikube fails to start cluster
# https://github.com/kubernetes/minikube/issues/2169
virsh -c qemu:///system net-start default
virsh -c qemu:///system net-start minikube



