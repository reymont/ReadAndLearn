https://buoyant.io/2017/04/06/a-service-mesh-for-kubernetes-part-viii-linkerd-as-an-ingress-controller

kubectl create ns l5d-system
# https://raw.githubusercontent.com/linkerd/linkerd-examples/master/k8s-daemonset/k8s/linkerd-ingress-controller.yml
kubectl apply -f linkerd-ingress-controller.yml -n l5d-system
kubectl delete -f linkerd-ingress-controller.yml -n l5d-system
 
kubectl get po -n l5d-system
# config.yaml
kubectl get cm l5d-config -n l5d-system -o yaml
