https://github.com/luxas/kubeadm-workshop

```
kind: MasterConfiguration
apiVersion: kubeadm.k8s.io/v1alpha1
controllerManagerExtraArgs:
  horizontal-pod-autoscaler-use-rest-clients: "true"
  horizontal-pod-autoscaler-sync-period: "10s"
  node-monitor-grace-period: "10s"
apiServerExtraArgs:
  runtime-config: "api/all=true"
kubernetesVersion: "stable-1.8"
```
kubeadm init --config kubeadm.yaml
cp /etc/kubernetes/admin.conf $HOME/

kubectl -n kube-system set image daemonset/kube-proxy kube-proxy=luxas/kube-proxy:v1.8.0-beta.1

# Here's how to use Weave Net as the networking provider the really easy way:

$ kubectl apply -f https://git.io/weave-kube-1.6
# OR you can run these two commands if you want to encrypt the communication between nodes:

$ kubectl create secret -n kube-system generic weave-passwd --from-literal=weave-passwd=$(hexdump -n 16 -e '4/4 "%08x" 1 "\n"' /dev/random)
$ kubectl apply -n kube-system -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&password-secret=weave-passwd"


$ kubectl taint nodes --all node-role.kubernetes.io/master-
