

# https://github.com/linkerd/linkerd-examples/blob/master/getting-started/k8s/README.md

# http://labs.play-with-k8s.com/
# You can bootstrap a cluster as follows:
## 1. Initializes cluster master node:
## 2. Initialize cluster networking:
## 3. (Optional) Create an nginx deployment:
kubeadm init --apiserver-advertise-address $(hostname -i)
kubectl apply -n kube-system -f \
    "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 |tr -d '\n')"
kubectl apply -f https://k8s.io/docs/user-guide/nginx-app.yaml
# https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#14-installing-kubeadm-on-your-hosts
# By default, your cluster will not schedule pods on the master
kubectl taint nodes --all node-role.kubernetes.io/master-

# Downloading
# Start by cloning this repo. Make sure that kubectl is installed and configured to talk to your Kubernetes cluster.
yum install -y git wget
cd /opt
git clone https://github.com/linkerd/linkerd-examples.git
cd linkerd-examples/getting-started/k8s
kubectl cluster-info

# Starting nginx
# We create a simple nginx app that simply serves a static file on port 80. 
# To do this in Kubernetes, we create a replication controller and service, defined in nginx.yml. 
# The service is what allows linkerd to discover the nginx pods and load balance over them. 
# To create nginx in the default namespace, run:
vi nginx.yml
`type: NodePort`
kubectl apply -f nginx.yml

# Starting linkerd
# linkerd stores its config file in a Kubernetes ConfigMap. 
# The config map, replication controller, and service for running linkerd are defined in linkerd.yml. 
# To create linkerd in the default namespace, run:

kubectl apply -f linkerd.yml
kubectl patch svc/linkerd -p '{"spec":{"type": "NodePort"}}'
# Kubernetes will create an external ip for linkerd which you can view with:
kubectl get svc/linkerd

kubectl apply -f https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-rbac-beta.yml

kubectl exec linkerd-jrccp -c l5d -it sh

# curl localhost:8001
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "forbidden: User \"system:serviceaccount:default:default\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {

  },
  "code": 403
}#

# https://github.com/fabric8io/fabric8/issues/6840
# You should bind service account system:serviceaccount:default:default 
# (which is the default account bound to Pod) with role cluster-admin, 
# just create a yaml (named like fabric8-rbac.yaml) with following contents:
cat > serviceaccount.yaml <<EOF
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: l5d-rbac
subjects:
  - kind: ServiceAccount
    # Reference to upper's `metadata.name`
    name: default
    # Reference to upper's `metadata.namespace`
    namespace: default
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
kubectl apply -f serviceaccount.yaml


NGINX_HOST_IP=$(kubectl get po -l app=nginx -o jsonpath="{.items[0].status.hostIP}")
NGINX_SVC_IP=$NGINX_HOST_IP:$(kubectl get svc nginx -o 'jsonpath={.spec.ports[0].nodePort}')
curl $NGINX_SVC_IP

# kubectl get po -l app=linkerd -o jsonpath="{.items[0].status.hostIP}"
# kubectl get svc linkerd -o 'jsonpath={.spec.ports[0].nodePort}'
HOST_IP=$(kubectl get po -l app=linkerd -o jsonpath="{.items[0].status.hostIP}")
L5D_SVC_IP=$HOST_IP:$(kubectl get svc linkerd -o 'jsonpath={.spec.ports[0].nodePort}')
curl $L5D_SVC_IP
echo $L5D_SVC_IP

http_proxy=$L5D_SVC_IP curl -s http://hello

http_proxy=10.102.157.96 curl -s http://nginx

minikube ssh
http_proxy=10.109.90.84:4140 curl -s http://nginx
curl -H "Host: nginx" 10.109.90.84:4140

# Send requests
# look for a service with the same name as the Host header to determine where the request should be routed.
# In this case we set the Host header to nginx so that the request is routed to the nginx service.
curl -H "Host: nginx" <linkerd external ip>:4140
curl -H "Host: nginx" 10.100.120.83:4140
http_proxy=10.102.157.96:4140 curl -H "Host: nginx" -v 10.111.60.158:80


# Admin dashboard
You can view the linkerd admin dashboard at <linkerd external ip>:9990.