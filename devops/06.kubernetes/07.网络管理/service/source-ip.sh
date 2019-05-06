
# https://kubernetes.io/docs/tutorials/services/source-ip/

# This document makes use of the following terms:
#   * NAT: network address translation
#   * Source NAT: replacing the source IP on a packet, usually with a node’s IP
#   * Destination NAT: replacing the destination IP on a packet, usually with a pod IP
#   * VIP: a virtual IP, such as the one assigned to every Kubernetes Service
#   * Kube-proxy: a network daemon that orchestrates Service VIP management on every node

kubectl run source-ip-app --image=nginx:1.7.9
kubectl get nodes
# You can test source IP preservation by creating a Service over the source IP app:
kubectl expose deployment source-ip-app --name=clusterip --port=80 --target-port=80
kubectl get svc clusterip
# And hitting the ClusterIP from a pod in the same cluster:
kubectl run busybox -it --image=busybox --restart=Never --rm
# ip addr
# wget -qO - 10.0.170.92

# Source IP for Services with Type=NodePort
# As of Kubernetes 1.5, packets sent to Services with Type=NodePort are source NAT’d by default. You can test this by creating a NodePort Service:
kubectl expose deployment source-ip-app --name=nodeport --port=80 --target-port=80 --type=NodePort
NODEPORT=$(kubectl get -o jsonpath="{.spec.ports[0].nodePort}" services nodeport)
NODES=$(kubectl get nodes -o jsonpath='{ $.items[*].status.addresses[?(@.type=="ExternalIP")].address }')

# Kubernetes has a feature to preserve the client source IP (check here for feature availability)
kubectl patch svc nodeport -p '{"spec":{"externalTrafficPolicy":"Local"}}'

# Cleaning up
## Delete the Services:
kubectl delete svc -l run=source-ip-app
## Delete the Deployment, ReplicaSet and Pod:
kubectl delete deployment source-ip-app