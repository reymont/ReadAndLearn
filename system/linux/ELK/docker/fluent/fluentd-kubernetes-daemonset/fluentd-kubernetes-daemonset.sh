
# https://github.com/fluent/fluentd-kubernetes-daemonset
# https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/fluentd-daemonset-elasticsearch.yaml

kubectl create -f fluentd-daemonset-elasticsearch.yaml
# kubectl delete -f fluentd-daemonset-elasticsearch.yaml
kubectl get pod --all-namespaces
kubectl describe po fluentd-ph1mp -n kube-system

# 查看索引
curl localhost:9200/_cat/indices

# docker run
docker run --rm\
 -v /var/log:/var/log\
 -v /var/lib/docker/containers:/var/lib/docker/containers\
 -e FLUENT_ELASTICSEARCH_HOST=172.20.62.42\
 -e FLUENT_ELASTICSEARCH_PORT=9200\
 fluent/fluentd-kubernetes-daemonset:elasticsearch