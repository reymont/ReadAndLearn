

* [Creating a Custom Cluster from Scratch - Kubernetes ](https://kubernetes.io/docs/getting-started-guides/scratch/)
* [kubelet - Kubernetes ](https://kubernetes.io/docs/admin/kubelet/)

## Configuring and Installing Base Software on Nodes

This section discusses how to configure machines to be Kubernetes nodes.
You should run three daemons on every node:

* docker or rkt
* kubelet
* kube-proxy

You will also need to do assorted other configuration on top of a base OS install.

> Tip: One possible starting point is to setup a cluster using an existing Getting Started Guide. After getting a cluster running, you can then copy the init.d scripts or systemd unit files from that cluster, and then modify them for use on your custom cluster.



### kubelet

All nodes should run kubelet. See Software Binaries.
Arguments to consider:

* If following the HTTPS security approach:
  * --api-servers=https://$MASTER_IP
  * --kubeconfig=/var/lib/kubelet/kubeconfig
* Otherwise, if taking the firewall-based security approach
  * --api-servers=http://$MASTER_IP
* --config=/etc/kubernetes/manifests
* --cluster-dns= to the address of the DNS server you will setup (see Starting Cluster Services.)
* --cluster-domain= to the dns domain prefix to use for cluster DNS addresses.
* --docker-root=
* --root-dir=
* --configure-cbr0= (described below)
* --register-node (described in Node documentation.)