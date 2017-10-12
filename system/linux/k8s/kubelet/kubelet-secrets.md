


```sh
kubectl delete ServiceAccount default -n kube-system
kubectl get secrets --all-namespaces

kubectl delete secrets -n kube-system --all
kubectl delete -f kube-ingress-controller.yaml
kubectl get po --all-namespaces
kubectl apply -f kube-ingress-controller.yaml
```