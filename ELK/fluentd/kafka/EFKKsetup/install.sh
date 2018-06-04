bold=$(tput bold)
normal=$(tput sgr0)

sudo tar xvf elasticsearch-1.7.2.tar.gz -C /opt/
sudo chown -R $USER /opt/elasticsearch-1.7.2
unzip -o -d /opt/elasticsearch-1.7.2/plugins/ elasticsearch-head-master.zip
if [ -d /opt/elasticsearch-1.7.2/plugins/head ]
then
    sudo rm -rf /opt/elasticsearch-1.7.2/plugins/head
fi
sudo mv -f /opt/elasticsearch-1.7.2/plugins/elasticsearch-head-master /opt/elasticsearch-1.7.2/plugins/head
cp -fv config_files/elasticsearch/elasticsearch.yml /opt/elasticsearch-1.7.2/config/elasticsearch.yml


unzip -o fluentd-master.zip
cd fluentd-master
bundle install
bundle exec rake build
sudo gem2.0 install pkg/fluentd-0.12.16.gem
sudo gem2.0 install fluent-plugin-kafka
sudo gem2.0 install fluent-plugin-elasticsearch
cd ..
cp -rfv config_files/fluentd/* fluentd-master/bin/


sudo tar xvf kafka_2.10-0.8.2.2.tgz -C /opt/
sudo chown -R $USER /opt/kafka_2.10-0.8.2.2/
cp -fv config_files/kafka/* /opt/kafka_2.10-0.8.2.2/config/


sudo tar xvf kibana-4.1.2-linux-x64.tar.gz -C /opt/
sudo chown -R $USER /opt/kibana-4.1.2-linux-x64
cp -fv config_files/kibana/kibana.yml /opt/kibana-4.1.2-linux-x64/config/kibana.yml

echo "#################################################################################"
echo "################################### ${bold}IMPORTANT${normal} ###################################"
echo "#################################################################################"
echo ""
echo "Enter the proper details in the following configuration files for completion:"
echo "        /opt/kafka_2.10-0.8.2.2/config/server.properties"
echo "        /opt/kafka_2.10-0.8.2.2/config/zookeeper.properties"
echo ""
echo "        /opt/kibana-4.1.2-linux-x64/config/kibana.yml"
