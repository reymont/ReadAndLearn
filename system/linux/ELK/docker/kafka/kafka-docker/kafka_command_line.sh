

# https://www.cloudera.com/documentation/kafka/latest/topics/kafka_command_line.html
Kafka command-line tools are located in /usr/bin:
# Create, alter, list, and describe topics. For example:
$ /usr/bin/kafka-topics --zookeeper zk01.example.com:2181 --list
$ /usr/bin/kafka-topics --create --zookeeper hostname:2181/kafka --replication-factor 2 
  --partitions 4 --topic topicname 
# Read data from a Kafka topic and write it to standard output. For example:
$ /usr/bin/kafka-console-consumer --zookeeper zk01.example.com:2181 --topic t1
# Read data from standard output and write it to a Kafka topic. For example:
$ /usr/bin/kafka-console-producer --broker-list kafka02.example.com:9092,kafka03.example.com:9092 --topic t1
# Note: kafka-consumer-offset-checker is not supported in the new Consumer API. Use the ConsumerGroupCommand tool, below.
# Check the number of messages read and written, as well as the lag for each consumer in a specific consumer group. For example:
$ /usr/bin/kafka-consumer-offset-checker --group flume --topic t1 --zookeeper zk01.example.com:2181
kafka-consumer-groups
# To view offsets as in the previous example with the ConsumerOffsetChecker, you describe the consumer group using the following command:
/usr/bin/kafka-consumer-groups --zookeeper zk01.example.com:2181 --describe --group flume
