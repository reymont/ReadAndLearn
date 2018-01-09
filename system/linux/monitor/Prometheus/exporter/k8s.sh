#容器CPU系统使用情况
(avg by (instance) (irate(container_cpu_system_seconds_total{id=~".*216b57ec05ceb149159459efa0bb185e4aea401bfb816b7b0f950b9f1e857b51"}[5m])) * 100)
#容器CPU用户使用情况
(avg by (instance) (irate(container_cpu_user_seconds_total{id=~".*216b57ec05ceb149159459efa0bb185e4aea401bfb816b7b0f950b9f1e857b51"}[5m])) * 100)
#容器CPU使用情况
(avg by (instance) (irate(container_cpu_usage_seconds_total{id=~".*216b57ec05ceb149159459efa0bb185e4aea401bfb816b7b0f950b9f1e857b51"}[5m])) * 100)

#内存使用情况
avg(container_memory_usage_bytes{id=~".*216b57ec05ceb149159459efa0bb185e4aea401bfb816b7b0f950b9f1e857b51"}) by (instance)
#内存总量
avg(container_spec_memory_limit_bytes{id=~".*216b57ec05ceb149159459efa0bb185e4aea401bfb816b7b0f950b9f1e857b51"}) by (instance)
#内存使用率
container_memory_usage_bytes{id=~".*216b57ec05ceb149159459efa0bb185e4aea401bfb816b7b0f950b9f1e857b51"}/container_spec_memory_limit_bytes{id=~".*216b57ec05ceb149159459efa0bb185e4aea401bfb816b7b0f950b9f1e857b51"}
#根据docker_id从k8s中获取pod_name，然后根据pod-name获取网络
#上传流量
irate(container_network_transmit_bytes_total{kubernetes_pod_name=~"^store-schedule-201703181147074ujs0bsj.*$"}[2h])
#下载流量
irate(container_network_receive_bytes_total{kubernetes_pod_name=~"^store-schedule-201703181147074ujs0bsj.*$"}[2h])
