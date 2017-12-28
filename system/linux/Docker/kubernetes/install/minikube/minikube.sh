


# https://github.com/kubernetes/minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64\
 && chmod +x minikube \
 && sudo mv minikube /usr/local/bin/
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x kubectl
curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.8.0/bin/linux/amd64/kubectl\
 && chmod +x kubectl\
 && sudo mv kubectl /usr/local/bin/

# kubeconfig
# minikube默认挂载C:\Users\<YOU>目录
C:\Users\chanceli\.minikube\files
/c/Users/chanceli/.minikube/files
sudo /c/Users/chanceli/.minikube/files/kubectl --kubeconfig=/var/lib/localkube/kubeconfig get pods
# 添加alias
alias kubectl='sudo /c/Users/chanceli/.minikube/files/kubectl --kubeconfig=/var/lib/localkube/kubeconfig'
kubectl get pod

# localkube本地
/usr/local/bin/localkube
/var/lib/localkube/certs/proxy-client-ca.crt

# 本地连接docker
eval $(minikube docker-env)

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_HOME=$HOME
export CHANGE_MINIKUBE_NONE_USER=true
mkdir $HOME/.kube || true
touch $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config
# Minikube also supports a --vm-driver=none option that runs the Kubernetes components on the host and not in a VM. 
# Docker is required to use this driver but no hypervisor.
minikube start --vm-driver=none
minikube start --vm-driver=kvm2

yum install -y kvm

# this for loop waits until kubectl can access the api server that Minikube has created
for i in {1..150}; do # timeout for 5 minutes
   ./kubectl get po &> /dev/null
   if [ $? -ne 1 ]; then
      break
  fi
  sleep 2
done

# kubectl commands are now able to interact with Minikube cluster

minikube start
kubectl run hello-minikube --image=gcr.io/google_containers/echoserver:1.4 --port=8080
kubectl expose deployment hello-minikube --type=NodePort
# We have now launched an echoserver pod but we have to wait until the pod is up before curling/accessing it
# via the exposed service.
# To check whether the pod is up and running we can use the following:
kubectl get pod
# We can see that the pod is still being created from the ContainerCreating status
kubectl get pod
# We can see that the pod is now Running and we will now be able to curl it:
curl $(minikube service hello-minikube --url)
kubectl delete service hello-minikube
kubectl delete deployment hello-minikube
minikube stop

