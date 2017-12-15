#Download elasticsearch
if [ ! -s  "elasticsearch-1.7.2.tar.gz" ]
then
    curl -O https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.2.tar.gz
fi
#Download elasticsearch-head
if [ ! -s  "elasticsearch-head-master.zip" ]
then
    curl -O https://codeload.github.com/mobz/elasticsearch-head/zip/master
    mv master elasticsearch-head-master.zip
fi

#Download fluentd
if [ ! -s  "fluentd-master.zip" ]
then
    curl -O https://codeload.github.com/fluent/fluentd/zip/master
    mv master fluentd-master.zip
fi

#Download kibana
if [ ! -s  "kafka_2.10-0.8.2.2.tgz" ]
then
    curl -O http://www.us.apache.org/dist/kafka/0.8.2.2/kafka_2.10-0.8.2.2.tgz
fi

#Download kibana
if [ ! -s  "kibana-4.1.2-linux-x64.tar.gz" ]
then
    curl -O https://download.elastic.co/kibana/kibana/kibana-4.1.2-linux-x64.tar.gz
fi

