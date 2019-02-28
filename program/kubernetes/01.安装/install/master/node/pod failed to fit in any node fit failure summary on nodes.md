

pod failed to fit in any node fit failure summary on nodes : PodToleratesNodeTaints (1) · Issue #41070 · kubernetes/kubernetes 
https://github.com/kubernetes/kubernetes/issues/41070

The k8s 1.5 assume it's unsafe to deploy user containers to master. So master will be tainted as NoSchedule by default.

`kubectl taint nodes test-perf-service7.novalocal node-role.kubernetes.io/master:NoSchedule-`

I can see this is a master so by default it is tainted as non-schedulable:
Taints: node.alpha.kubernetes.io/role=master:NoSchedule

If you want to deploy containers on this machine, please remove that taint:

`kubectl taint nodes your-node-name node.alpha.kubernetes.io/role:NoSchedule-`