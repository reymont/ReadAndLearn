

# https://medium.com/@georgelai/minikube-playing-with-local-kubernetes-cluster-d93e3e4a1ddf



```sh
minikube addons list
$ minikube addons disable dashboard
$ minikube addons enable heapster
$ minikube addons open heapster

# clean up
$ kubectl delete service,deployment hello-node
$ minikube stop
$ minikube delete
```

Kubernetes is one of the most famous container orchestration systems. And the Minikube is a tool for running a single-node Kubernetes cluster inside a VM. This makes it easier to try Kubernetes or develop with it. This tutorial aims to show how to set up the environment for minikube to run local Kubernetes cluster.
Overview of Environment
The environment which I used to go through the subsequent steps is listed as follows.
Laptop: Lenovo T420s
OS: Ubuntu 14.04
Installing The Minikube
Now let’s get started to install Minikube. First of all, the following requirements ought to be fulfilled.
Virtualization solution must be available. In my case, Virtualbox is chosen as the virtualization solution.
VT-x/AMD-v virtualization must be enabled in BIOS. To check it out, we can use the following command:
$ cat /proc/cpuinfo | grep 'vmx\|svm'
flags  : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx lahf_lm epb tpr_shadow vnmi flexpriority ept vpid xsaveopt dtherm ida arat pln pts
flags  : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx lahf_lm epb tpr_shadow vnmi flexpriority ept vpid xsaveopt dtherm ida arat pln pts
flags  : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx lahf_lm epb tpr_shadow vnmi flexpriority ept vpid xsaveopt dtherm ida arat pln pts
flags  : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx lahf_lm epb tpr_shadow vnmi flexpriority ept vpid xsaveopt dtherm ida arat pln pts
Since the CPU in my laptop supports vmx and is enabled by default, the results of the command listed the related information.
kubectl must be available. We can actually download the latest version of kubectl as follows.
$ curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
$ chmod +x kubectl
$ sudo mv kubectl /usr/local/bin
$ kubectl version --short=true
Client Version: v1.5.2
Server Version: v1.5.3
The installation of Minikube is to download it.
$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.17.1/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
$ minikube version
minikube version: v0.17.1
When starting Minikube at the first time, we may see it downloading the Minikube ISO:
$ minikube start
Starting local Kubernetes cluster...
Starting VM...
Downloading Minikube ISO
 88.71 MB / 88.71 MB [==============================================] 100.00% 0s
SSH-ing files into VM...
Setting up certs...
Starting cluster components...
Connecting to cluster...
Setting up kubeconfig...
Kubectl is now configured to use the cluster.
We can then inspect the Kubernetes cluster information as follows.
$ kubectl cluster-info
Kubernetes master is running at https://192.168.99.100:8443
heapster is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/heapster
KubeDNS is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/kube-dns
kubernetes-dashboard is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard
monitoring-grafana is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/monitoring-grafana
monitoring-influxdb is running at https://192.168.99.100:8443/api/v1/proxy/namespaces/kube-system/services/monitoring-influxdb
To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
$ kubectl get pods --all-namespaces
NAMESPACE     NAME                          READY     STATUS    RESTARTS   AGE
kube-system   heapster-qftbt                1/1       Running   0          16m
kube-system   influxdb-grafana-rk86f        2/2       Running   0          16m
kube-system   kube-addon-manager-minikube   1/1       Running   0          17m
kube-system   kube-dns-v20-1lkx4            3/3       Running   0          16m
kube-system   kubernetes-dashboard-0pc0t    1/1       Running   0          16m
Furthermore, we can also list all of the available nodes in our local Kubernetes cluster as follows.
$ kubectl get nodes
NAME       STATUS    AGE
minikube   Ready     17m
After having launched the following command, we may see the Kubernetes dashboard by means of browser.
$ minikube dashboard
Opening kubernetes dashboard in default browser...

Minikube Addons
Minikube comes with several addons such as Kubernetes Dashboard, Kubernetes DNS, etc. We can list the available addons via
$ minikube addons list
- addon-manager: enabled
- dashboard: enabled
- default-storageclass: enabled
- kube-dns: enabled
- heapster: enabled
- ingress: disabled
- registry-creds: disabled
We can also enable/disable some addons via
$ minikube addons disable dashboard
$ minikube addons enable heapster
To open the corresponding web interface to a specific addon, e.g., heapster, we can issue the following command.
$ minikube addons open heapster
This will open a browser showing the web interface of heapster.

Clean Up
This section shows how to clean up all of the deployed pods in Minikube and finally how to stop the Minikube.
$ kubectl delete service,deployment hello-node
$ minikube stop
If you would like to delete the current minikube cluster, you can issue the following command to do it.
$ minikube delete