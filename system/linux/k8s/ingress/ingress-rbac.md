

* [nginx ingress controller not able to resolve namespace/service (kube 1.6) · Issue #610 · kubernetes/ingress ](https://github.com/kubernetes/ingress/issues/610)
* [[feature request] rbac role manifest · Issue #266 · kubernetes/ingress ](https://github.com/kubernetes/ingress/issues/266)


* [Using RBAC Authorization - Kubernetes ](https://kubernetes.io/docs/admin/authorization/rbac/)

Role-Based Access Control (“RBAC”) uses the `“rbac.authorization.k8s.io”` API group to drive authorization decisions, allowing admins to dynamically configure policies through the Kubernetes API.
As of 1.6 RBAC mode is in beta.
To enable RBAC, start the apiserver with `--authorization-mode=RBAC`

kubectl get clusterrolebinding