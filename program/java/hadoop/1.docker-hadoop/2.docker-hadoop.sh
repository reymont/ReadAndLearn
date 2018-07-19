### 1. 安装docker-compose
yum install -y epel-release
yum install -y python-pip
# Compose 1.10.0-rc2 requires Docker Engine 1.10.0 or later for version 2 of the Compose File format
# 安装指定版本：
pip install docker-compose==1.10.0
### 2. 启动
# https://github.com/big-data-europe/docker-hadoop
git clone https://github.com/big-data-europe/docker-hadoop.git
# 构建镜像
cd /opt/docker-hadoop/namenode
docker build -t dockerhadoop_namenode .
docker-compose up -d
docker-compose -f docker-compose-local.yml up -d
# 利用config命令可以打印处配置文件的内容和service名称以及volumes信息
docker-compose -f docker-compose-local.yml config
docker-compose -f docker-compose-local.yml config --services
docker-compose ps
### 3. WordCount
# http://hadoop.apache.org/docs/current/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html
docker exec -it namenode bash
# 创建目录
hadoop fs -mkdir -p /user/joe/wordcount/input/
hadoop fs -mkdir -p /user/joe/wordcount/output/
hadoop fs -ls /user/joe/wordcoun
hadoop fs -put file01 /user/joe/wordcount/input/
hadoop fs -put file02 /user/joe/wordcount/input/
hadoop fs -ls /user/joe/wordcount/input/
# 安装vim
apt-get update && apt-get install -y vim
# 清理output目录
hadoop fs -rm -r -f /user/joe/wordcount/output
hadoop fs -cat /user/joe/wordcount/input/file01
# Hello World Bye World
hadoop fs -cat /user/joe/wordcount/input/file02
# Hello Hadoop Goodbye Hadoop
cd /opt
export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class
hadoop jar wc.jar WordCount /user/joe/wordcount/input /user/joe/wordcount/output
hadoop fs -cat /user/joe/wordcount/output/part-r-00000


### docker hub
https://hub.docker.com/r/reymontli/docker-hadoop/