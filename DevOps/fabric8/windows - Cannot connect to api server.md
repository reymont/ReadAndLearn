

# https://github.com/fabric8io/fabric8/issues/6813
# https://blog.fabric8.io/a-busy-java-developers-guide-to-developing-microservices-on-kubernetes-and-docker-98b7b9816fdf
# https://fabric8.io/guide/getStarted/kubernetes.html
# https://github.com/kubernetes/minikube/issues/811

when asking minikube logs, i see that minikube is not able to found node info on http://127.0.0.1:8080/api/v1/nodes/minikube.

I have fixed the issue. It is a proxy issue. I have to setup no_proxy with the VB ip.
you can run minikube ip to get the ip
then set no_proxy=localhost,127.0.0.1,[VM_IP]

minikube start \
  --vm-driver xhyve \
  --docker-env NO_PROXY=".local,localhost,.abc.com,.xyz.com,127.0.0.1"