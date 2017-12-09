

https://fabric8.io/guide/getStarted/minikube.html

# create a new Kubernetes cluster
minikube start --memory=6000

gofabric8 start
gofabric8 deploy -y
gofabric8 validate

# To see the URL so you can open it in another browser you can type:
minikube service fabric8 --url
# You can use the same command to open other consoles too like gogs, Jenkins or Nexus
minikube service gogs
minikube service jenkins
minikube service nexus
# To use docker on your host communicating with the docker daemon inside your MiniKube cluster type:
eval $(minikube docker-env)