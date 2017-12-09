

# To find out which cluster Tiller would install to, 
kubectl config current-context 
# or
kubectl cluster-info
# initialize the local CLI and also install Tiller into Kubernetes
helm init
# you saw with 
kubectl config current-context.
# 在宿主机命令行，与客户机docker守护进程通信
eval $(minikube docker-env)
# 删除所有pod
kubectl delete pods --all --now
# 停止minikube
minikube stop

$ helm delete --purge cautious-shrimp
$ helm ls --deleted