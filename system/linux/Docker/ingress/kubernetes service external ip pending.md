

docker - kubernetes service external ip pending - Stack Overflow https://stackoverflow.com/questions/44110876/kubernetes-service-external-ip-pending

It looks like you are using a custom `Kubernetes Cluster (using minikube, kubeadm or the like).` In this case, `there is no LoadBalancer integrated` (unlike AWS or Google Cloud). With this default setup, you can only use NodePort (more info here: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport) or an Ingress Controller. With the Ingress Controller you can setup a domain name which maps to your pod (more information here: https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-controllers)