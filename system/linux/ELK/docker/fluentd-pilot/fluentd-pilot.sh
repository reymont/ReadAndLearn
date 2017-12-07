


yum -y install epel-release
yum -y git
yum -y install docker-compose

git clone git@github.com:AliyunContainerService/fluentd-pilot.git
git clone https://github.com/AliyunContainerService/fluentd-pilot.git
cd fluentd-pilot/quickstart
./run
