#网络最高
topk(3,sum(node_network_receive_bytes) by (instance))
#cpu usage cpu使用情况
100 - (avg by (mode) (irate(node_cpu{instance="192.168.0.180"}[5m])) * 100)
100 - (avg by (instance) (irate(node_cpu{mode="idle"}[5m])) * 100)
100 - (avg by (instance) (irate(node_cpu{mode="idle",instance="192.168.0.197"}[5m])) * 100)
#cpu系统使用情况
(avg by (instance) (irate(node_cpu{mode="system"}[2h])) * 100)
#cpu用户使用情况
(avg by (instance) (irate(node_cpu{mode="user"}[2h])) * 100)
#内存总量
node_memory_MemTotal
node_memory_MemFree
node_memory_Cached
node_memory_Buffers
#内存使用情况
(node_memory_MemTotal-node_memory_Buffers-node_memory_MemFree-node_memory_Cached)
#内存使用率
(node_memory_MemTotal-node_memory_Buffers-node_memory_MemFree-node_memory_Cached)*100/node_memory_MemTotal
irate(node_network_receive_bytes{device='eno16777984'}[2h])
irate(node_network_transmit_bytes{device='eno16777984'}[2h])
rate(node_disk_bytes_read{device="sda"}[2h])
rate(node_disk_bytes_written{device="sda"}[2h])
node_filesystem_size
node_filesystem_free/node_filesystem_size
(node_filesystem_size-node_filesystem_free)*100/node_filesystem_size

