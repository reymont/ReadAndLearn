
#tls方式查看节点
kubectl get nodes --server="https://192.168.0.140:6443" --insecure-skip-tls-verify=true