

# https://kubernetes.io/docs/setup/independent/install-kubeadm/ 

# Installing Docker
yum install -y docker
systemctl enable docker && systemctl start docker

# Installing kubeadm, kubelet and kubectl
# rm /etc/yum.repos.d/kubernetes.repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
# yum remove -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet

# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
# Initializing your master
kubeadm init
# To start using your cluster, you need to run (as a regular user):

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# You can now join any number of machines by running the following on each node as root:
kubeadm join --token 0679a3.b4cb44ac04bd9750 172.22.78.68:6443 --discovery-token-ca-cert-hash sha256:fdf52e388ae3d383270b2a469e7c91a405fb543fa362db4546aa1031b2995a9e

# https://kubernetes.io/docs/user-guide/walkthrough/
kubectl create -f pod-nginx.yaml
# On most providers, the pod IPs are not externally accessible.
# The easiest way to test that the pod is working is to create a busybox pod and exec commands on it remotely
# Provided the pod IP is accessible, you should be able to access its http endpoint with wget on port 80:
kubectl run busybox --image=busybox --restart=Never --tty -i --generator=run-pod/v1 --env "POD_IP=$(kubectl get pod nginx -o go-template='{{.status.podIP}}')"
u@busybox$ wget -qO- http://$POD_IP # Run in the busybox container
u@busybox$ exit # Exit the busybox container
kubectl delete pod busybox # Clean up the pod we created with "kubectl run"

# 替换字符串
sed -i 's/172.22.78.77/172.20.62.42/g' `grep 172.22.78.77 -rl /etc/kubernetes/`

