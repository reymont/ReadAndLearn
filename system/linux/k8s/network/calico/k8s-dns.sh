
#进入容器jvm-deployment-3465872216-8fhzp进行域名解析
kubectl exec -it jvm-deployment-3465872216-8fhzp -n kube-system sh
/ # nslookup jvm-service
Name:      jvm-service
Address 1: 10.96.74.19 jvm-service.kube-system.svc.cluster.local
/ # nslookup kubernetes-dashboard
Name:      kubernetes-dashboard
Address 1: 10.96.19.66 kubernetes-dashboard.kube-system.svc.cluster.local
/ # nslookup kubernetes-dashboard.kube-system.svc.cluster.local
Name:      kubernetes-dashboard.kube-system.svc.cluster.local
Address 1: 10.96.19.66 kubernetes-dashboard.kube-system.svc.cluster.local

# 为什么svc.ob.local可以ping得通？
ping kubernetes-dashboard.kube-system.svc.ob.local


calicoctl node status
#Calico process is running.
#IPv4 BGP status
#+---------------+-------------------+-------+------------+-------------+
#| PEER ADDRESS  |     PEER TYPE     | STATE |   SINCE    |    INFO     |
#+---------------+-------------------+-------+------------+-------------+
#| 192.168.0.141 | node-to-node mesh | up    | 2017-08-17 | Established |
#| 192.168.0.148 | node-to-node mesh | up    | 2017-08-17 | Established |
#+---------------+-------------------+-------+------------+-------------+
#IPv6 BGP status
#No IPv6 peers found.

