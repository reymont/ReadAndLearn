Get pod ip and their coordinating NODE
$ kubectl get pods -o wide
If you want to get detailed information about pod, nodes, then you should set output as yaml:
$ kubectl get pods -o json
Show labels about pods under all namespace:
$ kubectl get pods --all-namespaces --show-labels
Dump kubernets cluster infomation
$ kubectl cluster-info dump
Run commands in a pod
$ kubectl exec test-pod -- ls -alh
Attach to a process that is already running inside an existing container.
$ kubectl attach POD -c CONTAINER [options]
#Sends stdin to a 'bash' in busybox container from pod busy box and sends stdout/stderr from 'bash' back to the client.
$ kubectl attach busybox -it
#Get node information, Kubelet, Kube-proxy version, resource utilisation etc.
$ kubectl describe node ip-172-31-10-199
#根据namespace和name获取pod的描述
kubectl get pods --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk store-bm001-201704241105384un133ea-tgwhn -o yaml
#pods相关
kubectl get pods  --all-namespaces --show-labels=true
kubectl get pods --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk -o yaml|grep -i podip
kubectl get pods --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk apidemorest4lrqc5qj-g59zg -o yaml
kubectl --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk get pods
kubectl --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk get po -l run
kubectl --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk get pods -Lrun -LserviceId
http://kubernetes.io/docs/user-guide/connecting-applications/
#service相关
kubectl get svc --all-namespaces
kubectl get svc --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk apidemorest4lrqc5qj
kubectl describe svc --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk apidemorest4lrqc5qj
kubectl exec --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk rm-27788enqb7wf90k2-lmg7n – printenv
kubectl get svc --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk dr-27788nz3160sppn6 -o yaml
kubectl get svc --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk dr-27788nz3160sppn6 -o go-template='{{.spec.clusterIP}}'
kubectl --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk describe svc dr-27788nz3160sppn6
kubectl get svc --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk
kubectl --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk describe service/apidemorest4lrqc5qj

kubectl --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk get ep dr-27788nz3160sppn6
kubectl get ep --namespace=716mo7m10myxdnfbgfpr3f3dh8npzk apidemorest4lrqc5qj




#1.显示所有pod 
kubectl get pod
#2.显示所有rc 
kubectl get rc
#3.显示所有service 
kubectl get service
#4.删除rc 
kubectl delete rc rcname
#5.删除service 
kubectl delete service servicename
#6.删除pod 
kubectl delete pod podname
#7.查看pod描述 
kubectl describe pod podname // 可以查看错误
#8.删除所有 
kubectl delete pod –all

kubectl get svc -all –all-namespaces 
kubectl delete svc -all –all-namespaces 
kubectl get limitrange –all-namespaces 
kubectl delete limitrange inf-limit –namespace=inf
