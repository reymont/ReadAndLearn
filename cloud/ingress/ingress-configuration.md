

* [ingress/controllers/nginx at master · kubernetes/ingress ](https://github.com/kubernetes/ingress/tree/master/controllers/nginx#running-multiple-ingress-controllers)

# ingress-class

--ingress-class string             Name of the ingress class to route through this controller.

Running multiple ingress controllers

If you're running multiple ingress controllers, or running on a cloudprovider that natively handles ingress, you need to specify the annotation `kubernetes.io/ingress.class: "nginx"` in all ingresses that you would like this controller to claim. Not specifying the annotation will lead to multiple ingress controllers claiming the same ingress. Specifying the wrong value will result in all ingress controllers ignoring the ingress. Multiple ingress controllers running in the same cluster was not supported in Kubernetes versions < 1.3.