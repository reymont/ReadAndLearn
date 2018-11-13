

# https://kubernetes.io/docs/tasks/access-application-cluster/service-access-application-cluster/

# To check the version, enter 
kubectl version

# Creating a service for an application running in two pods
## Run a Hello World application in your cluster:
kubectl run hello-world --replicas=2 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
## The preceding command creates a Deployment object and an associated ReplicaSet object. 
## The ReplicaSet has two Pods, each of which runs the Hello World application.

## Display information about the Deployment:
kubectl get deployments hello-world
kubectl describe deployments hello-world

## Display information about your ReplicaSet objects:
kubectl get replicasets
kubectl describe replicasets

## Create a Service object that exposes the deployment:
kubectl expose deployment hello-world --type=NodePort --name=example-service

## Display information about the Service:
kubectl describe services example-service
# The output is similar to this:
#  Name:                   example-service
#  Namespace:              default
#  Labels:                 run=load-balancer-example
#  Annotations:            <none>
#  Selector:               run=load-balancer-example
#  Type:                   NodePort
#  IP:                     10.32.0.16
#  Port:                   <unset> 8080/TCP
#  Endpoints:              10.200.1.4:8080,10.200.2.5:8080
#  Session Affinity:       None
#  Events:                 <none>

# Make a note of the NodePort value for the service. For example, in the preceding output, the NodePort value is 31496.
## List the pods that are running the Hello World application:
kubectl get pods --selector="run=load-balancer-example" --output=wide

# Get the public IP address of one of your nodes that is running a Hello World pod. 
# How you get this address depends on how you set up your cluster. 
# For example, if you are using Minikube, you can see the node address by running kubectl cluster-info. 

# On your chosen node, create a firewall rule that allows TCP traffic on your node port. 
# For example, if your Service has a NodePort value of 31568, 
# create a firewall rule that allows TCP traffic on port 31568. 
# Different cloud providers offer different ways of configuring firewall rules. 
# Use the node address and node port to access the Hello World application:
curl http://<public-node-ip>:<node-port>

# Cleaning up
## To delete the Service, enter this command:
kubectl delete services example-service
## To delete the Deployment, the ReplicaSet, and the Pods that are running the Hello World application, enter this command:
kubectl delete deployment hello-world