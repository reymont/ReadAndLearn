
```sh
### 1. JAVA_HOME
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel git wget unzip
vi /etc/profile
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.181-3.b13.el7_5.x86_64
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH
export HADOOP_HOME=/opt/hadoop/hadoop-2.9.1
export PATH=${HADOOP_HOME}/bin:$PATH
source /etc/profile
### 2. HADOOP
cd /opt/hadoop
curl -O http://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.9.1/hadoop-2.9.1.tar.gz
curl -O https://archive.apache.org/dist/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz
tar -xzvf hadoop-2.9.1.tar.gz
### 3。 Setup passphraseless ssh
# Now check that you can ssh to the localhost without a passphrase:
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
ssh localhost

### 4. 配置
# etc/hadoop/hdfs-site.xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
</configuration>
# etc/hadoop/core-site.xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://172.20.62.34:9000</value>
    </property>
</configuration>
# etc/hadoop/slaves, datanode
172.20.62.34
### 5. 执行
# 清理目录
cd /tmp
rm -rf ./*
# 格式化
bin/hdfs namenode -format
sbin/start-dfs.sh
http://172.20.62.34:50070


bin/hdfs dfs -mkdir /user/root/input
bin/hdfs dfs -put etc/hadoop/* /user/root/input
bin/hadoop jar share/hadoop/mapreduce/hadoop-mapreduce-examples-2.9.1.jar grep input output 'dfs[a-z.]+'
# Copy the output files from the distributed filesystem to the local filesystem and examine them
bin/hdfs dfs -get output output
cat output/*
# View the output files on the distributed filesystem
bin/hdfs dfs -cat output/*
```

## 参考

1. http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/SingleCluster.html
2. http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html