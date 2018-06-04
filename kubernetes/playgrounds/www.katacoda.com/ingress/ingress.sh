# Step 1 - Create Deployment
## To start, deploy an example HTTP server that will be the target of our requests. 
## The deployment contains three deployments, 
## one called webapp1 and a second called webapp2, and a third called webapp3 with a service for each.
kubectl create -f deployment.yaml
kubectl get deployment

# Step 2 - Deploy Ingress
## Ingress is deployed as a Replication Controller. 
## This controller combines a software load balancer, such as Nginx or HAProxy, 
## with Kubernetes integration for configuring itself based on the defined rules.
## The YAML file below defines a nginx-based Ingress controller 
## together with a service making it available on Port 80 to external 
## connections using ExternalIPs. If the Kubernetes cluster was running on a cloud 
## provider then it would use a LoadBalancer service type.
cat ingress.yaml
## The Ingress controllers are deployed in a familiar fashion to other Kubernetes objects with 
kubectl create -f ingress.yaml
## The status can be identified using 
kubectl get rc

# Step 3 - Deploy Ingress Rules
## Ingress rules are an object type with Kubernetes. 
## The rules can be based on a request host (domain), or the path of the request, or a combination of both.

## An example set of rules are defined within 
cat ingress-rules.yaml
## The important parts of the rules are defined below.
## The rules apply to requests for the host my.kubernetes.example. 
## Two rules are defined based on the path request with a single catch all definition. 
## Requests to the path /webapp1 are forwarded onto the service webapp1-svc. 
## Likewise, the requests to /webapp2 are forwarded to webapp2-svc. If no rules apply, webapp3-svc will be used.
# This demonstrates how an application's URL structure can behave independently about how the applications are deployed.
```
- host: my.kubernetes.example
  http:
    paths:
    - path: /webapp1
      backend:
        serviceName: webapp1-svc
        servicePort: 80
    - path: /webapp2
      backend:
        serviceName: webapp2-svc
        servicePort: 80
    - backend:
        serviceName: webapp3-svc
        servicePort: 80
```
## As with all Kubernetes objects, they can be deployed via 
kubectl create -f ingress-rules.yaml
## Once deployed, the status of all the Ingress rules can be discovered via 
kubectl get ing