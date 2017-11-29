
# 停止第二个节点
./sbin/rabbitmqctl -n rabbit_1@Phantome stop_app
# 重设第二个节点的元数据和状态为清空的状态
./sbin/rabbitmqctl -n rabbit_1@Phantome reset
# 将已停止的节点加入到集群中
./sbin/rabbitmqctl -n rabbit_1@Phantome cluster rabbit@Phantome rabbit_1@Phantome