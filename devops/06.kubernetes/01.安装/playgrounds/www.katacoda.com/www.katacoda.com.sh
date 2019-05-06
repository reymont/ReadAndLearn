

# https://www.katacoda.com/courses/kubernetes/
# Step 1 - Start Minikube
## Check that it is properly installed, by running the minikube version command:
minikube version
## Start the cluster, by running the minikube start command:
minikube start

# Step 2 - Cluster Info
## Details of the cluster and it's health status can be discovered via kubectl cluster-info
## To view the nodes in the cluster using 
kubectl get nodes

# Step 3 - Deploy Containers
## With a running Kubernetes cluster, containers can now be deployed.
## Using kubectl run, it's allows containers to be deployed onto the cluster - 
kubectl run first-deployment --image=katacoda/docker-http-server --port=80
## The status of the deployment can be discovered via the running Pods - 
kubectl get pods
## Once the container is running it can be exposed via different networking options, depending on requirements.
## On possible solution is NodePort, that provides a dynamic port to a container.
kubectl expose deployment first-deployment --port=80 --type=NodePort
## The command below finds the allocated port and executes a HTTP request.
export PORT=$(kubectl get svc first-deployment -o go-template='{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}')
curl host01:$PORT