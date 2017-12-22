
# https://github.com/kubernetes/ingress-nginx/blob/master/docs/examples/static-ip/README.md

# https://github.com/kubernetes/ingress-nginx/blob/master/docs/examples/PREREQUISITES.md
# Test HTTP Service
kubectl create -f http-svc.yaml
kubectl get svc http-svc
kubectl patch svc http-svc -p '{"spec":{"type": "LoadBalancer"}}'
kubectl describe svc http-svc
# LoadBalancer Ingress:	108.59.87.136
kubectl patch svc http-svc -p '{"spec":{"type": "NodePort"}}'