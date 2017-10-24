

```sh
#标记规则：kubectl label nodes <node-name> <label-key>=<label-value>
kubectl label nodes k8s.node1 cloudnil.com/role=dev

#确认标记
root@k8s.master1:~# kubectl get nodes k8s.node1 --show-labels
NAME        STATUS    AGE       LABELS
k8s.node1   Ready     29d       beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,cloudnil.com/role=dev,kubernetes.io/hostname=k8s.node1
```


```sh
#查看标签
kubectl get node -o wide -n kube-system --show-labels
#ingress
kubectl label nodes gz-node-0 ingress=controller
kubectl label nodes 192.168.0.141 ingress=controller
#ingress
kubectl label nodes gz-node-0 k8s-app=jvmv
```