

# 在Docker上运行Apache Kafka - DockOne.io http://dockone.io/article/565

# 下面是用Docker运行Apache Kafka的步骤，假设你已经装好了boot2docker和docker。
boot2docker version
docker --version
# boot2docker up在Mac OS上启动微型Linux内核。
boot2docker up
# To connect the Docker client to the Docker daemon, please set:
export DOCKER_HOST=tcp://192.168.59.104:2376
export DOCKER_CERT_PATH=/Users/jacek/.boot2docker/certs/boot2docker-vm
export DOCKER_TLS_VERIFY=1 

# 2，（仅适用Mac OS X和Windows用户）执行$(boot2docker shellinit)设置好终端，让docker知道微型Linux内核运行在哪儿(通过boot2docker)。为了设置上面的export，你必须在所有打开的运行Docker终端中重复这一步骤。如果你遇到docker命令的通信问题，记着这一步。
$(boot2docker shellinit)
Writing /Users/jacek/.boot2docker/certs/boot2docker-vm/ca.pem
Writing /Users/jacek/.boot2docker/certs/boot2docker-vm/cert.pem
Writing /Users/jacek/.boot2docker/certs/boot2docker-vm/key.pem 
# 4，在Docker Hub上创建账号并运行docker login保存证书。你不必重复通过docker pull从Docker镜像的公用中心下载镜像，把Docker Hub看作存储Docker镜像的GitHub。参考文档使用Docker Hub获得最新信息。
# 执行docker pull wurstmeister/kafka从Docker Hub下载Zookeeper镜像（可能需要几分钟）
docker pull wurstmeister/zookeeper
docker pull wurstmeister/kafka
# 7，在命令行中执行docker images验证wurstmeister/kafka和wurstmeister/zookeeper两个镜像已下载。
docker images
# 8，现在可以在一个终端里运行docker run --name zookeeper -p 2181 -t wurstmeister/zookeeper引导启动Zookeeper。如果你在Mac OS X或Windows上，记得$(boot2docker shellinit)。
docker run --rm -p 2181:2181 -t wurstmeister/zookeeper
# docker run -d --restart=always --name zookeeper -p 2181:2181 -t wurstmeister/zookeeper
# 现在ZooKeeper在监听2181端口。用Docker（或者Mac OS上的Boot2Docker）的IP地址远程连接确认下。
telnet `boot2docker ip` 2181
# 9，在另一个终端里执行
docker run --rm \
 -e HOST_IP=localhost\
 -e KAFKA_ADVERTISED_PORT=9092\
 -e KAFKA_BROKER_ID=1\
 -e ZK=zk\
 -p 9092\
 --link zookeeper:zk\
 -t wurstmeister/kafka
docker run -d --restart=always --name kafka\
 -e HOST_IP=localhost\
 -e KAFKA_ADVERTISED_HOST_NAME=172.20.62.42\
 -e KAFKA_PROTOCOL_NAME=172.20.62.42\
 -e KAFKA_ADVERTISED_PORT=9092\
 -e KAFKA_BROKER_ID=1\
 -e ZK=zk\
 -p 9092:9092\
 --link zookeeper:zk\
 -t wurstmeister/kafka
docker run -d --restart=always --name kafka\
 -e HOST_IP=localhost\
 -e KAFKA_ADVERTISED_HOST_NAME=172.20.62.42\
 -e KAFKA_PROTOCOL_NAME=172.20.62.42\
 -e KAFKA_ADVERTISED_PORT=9092\
 -e KAFKA_BROKER_ID=1\
 -e ZK=zk\
 -e "KAFKA_JMX_OPTS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=172.20.62.42 -Dcom.sun.management.jmxremote.rmi.port=9999"\
 -e JMX_PORT=9999\
 -p 9999:9999\
 -p 9092:9092\
 --link zookeeper:zk\
 -t wurstmeister/kafka
# 现在你的电脑上运行着依托Docker的Apache Kafka，你是它的的开心用户。用docker ps查看容器状态。
docker ps
# 10，要结束你的Apache Kafka旅程时，用docker stop kafka zookeeper(或docker stop $(docker ps -aq)，如果运行的容器只有kafka和zookeeper)docker stop容器。
docker stop kafka zookeeper
# 11，最后，用boot2docker down停止boot2docker守护进程（仅对于Mac OS X和Windows用户）。

# http://www.cnblogs.com/xiaodf/p/6093261.html
# 创建kafka topic
docker exec -it kafka bash
cd /opt/kafka
bin/kafka-topics.sh --zookeeper zookeeper:2181 --create --topic cdr --partitions 30  --replication-factor 1
# 注： partitions指定topic分区数，replication-factor指定topic每个分区的副本数
# partitions分区数:
# partitions ：分区数，控制topic将分片成多少个log。可以显示指定，如果不指定则会使用broker(server.properties)中的num.partitions配置的数量
# 虽然增加分区数可以提供kafka集群的吞吐量、但是过多的分区数或者或是单台服务器上的分区数过多，会增加不可用及延迟的风险。因为多的分区数，意味着需要打开更多的文件句柄、增加点到点的延时、增加客户端的内存消耗。
# 分区数也限制了consumer的并行度，即限制了并行consumer消息的线程数不能大于分区数
# 分区数也限制了producer发送消息是指定的分区。如创建topic时分区设置为1，producer发送消息时通过自定义的分区方法指定分区为2或以上的数都会出错的；这种情况可以通过alter –partitions 来增加分区数。
# replication-factor副本
# replication factor 控制消息保存在几个broker(服务器)上，一般情况下等于broker的个数。
# 如果没有在创建时显示指定或通过API向一个不存在的topic生产消息时会使用broker(server.properties)中的default.replication.factor配置的数量
# 查看所有topic列表
bin/kafka-topics.sh --zookeeper zookeeper:2181 --list
# 查看指定topic信息
bin/kafka-topics.sh --zookeeper zookeeper:2181 --describe --topic cdr
# 控制台向topic生产数据
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic cdr
# 控制台消费topic的数据
bin/kafka-console-consumer.sh  --zookeeper zookeeper:2181  --topic cdr --from-beginning
# 查看topic某分区偏移量最大（小）值
bin/kafka-run-class.sh kafka.tools.GetOffsetShell --topic hive-mdatabase-hostsltable\
  --time -1 --broker-list localhost:9092 --partitions 0
# 注： time为-1时表示最大值，time为-2时表示最小值
# 增加topic分区数
## 为topic cdr 增加10个分区
bin/kafka-topics.sh --zookeeper zookeeper:2181  --alter --topic cdr --partitions 10
# 删除topic，慎用，只会删除zookeeper中的元数据，消息文件须手动删除
bin/kafka-run-class.sh kafka.admin.DeleteTopicCommand --zookeeper zookeeper:2181 --topic cdr
# 查看topic消费进度
# 这个会显示出consumer group的offset情况， 必须参数为--group， 不指定--topic，默认为所有topic
# Displays the: Consumer Group, Topic, Partitions, Offset, logSize, Lag, Owner for the specified set of Topics and Consumer Group
bin/kafka-run-class.sh kafka.tools.ConsumerOffsetChecker --group pv

# https://community.hortonworks.com/articles/109848/how-to-view-the-oldest-message-in-a-kafka-topic.html
# The following command shows all messages not just one:
bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic iot --from-beginning
# To view specific number of message in a Kafka topic, use the --max-messages option. 
# To view the oldest message, run the console consumer with --from-beginning and --max-messages 1:
bin/kafka-console-consumer.sh --zookeeper zookeeper:2181 --topic iot --from-beginning --max-messages 1