* [聊聊你可能误解的Kubernetes Deployment滚动更新机制 - CSDN博客 ](http://blog.csdn.net/WaltonWang/article/details/77461697?locationNum=5&fps=1)
Kubernetes Deployment滚动更新机制不同于ReplicationController rolling update，Deployment rollout还提供了滚动进度查询，滚动历史记录，回滚等能力，无疑是使用Kubernetes进行应用滚动发布的首选

```sh
kubectl set image deploy frontend php-redis=gcr.io/google-samples/gb-frontend:v3 --record
```
通过kubectl get rs -w来watch ReplicaSet的变化