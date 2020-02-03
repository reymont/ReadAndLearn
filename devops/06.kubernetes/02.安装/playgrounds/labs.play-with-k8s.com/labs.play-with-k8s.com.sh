


# http://labs.play-with-k8s.com/
# You can bootstrap a cluster as follows:
## 1. Initializes cluster master node:
kubeadm init --apiserver-advertise-address $(hostname -i)
## 2. Initialize cluster networking:
kubectl apply -n kube-system -f \
    "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 |tr -d '\n')"
## 3. (Optional) Create an nginx deployment:
kubectl apply -f https://k8s.io/docs/user-guide//nginx-app.yaml

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm join --token 222190.a5bb6ea843249de2 172.20.0.2:6443\
 --discovery-token-ca-cert-hash sha256:f79e3da373263a5f1a83accf4fa2cb88fab389afc1e302b499312098157459e9
