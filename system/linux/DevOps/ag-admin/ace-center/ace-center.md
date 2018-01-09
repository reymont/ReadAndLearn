



```sh
# https://github.com/dockerfile/rabbitmq
# http://blog.csdn.net/qq_35981283/article/details/69648171
# Usage
# Run rabbitmq-server
docker run -d -p 5672:5672 -p 15672:15672 dockerfile/rabbitmq
# Run rabbitmq-server w/ persistent shared directories.
docker run -d -p 5672:5672 -p 15672:15672 -v <log-dir>:/data/log -v <data-dir>:/data/mnesia dockerfile/rabbitmq
docker run -d --name myrabbitmq -p 5673:5672 -p 15673:15672 docker.io/rabbitmq:3-management
docker pull rabbitmq:3.7.2-management
```

# Caused by: java.lang.ClassNotFoundException: com.google.common.base.Function

执行mvn dependency:tree|grep google
找到依赖com.google.guava:guava:jar:18.0:compile

删除之\.m2\repository\com\google\guava\guava\18.0

添加依赖
```xml
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>16.0.1</version>
</dependency>
<dependency>
    <groupId>com.diffplug.guava</groupId>
    <artifactId>guava-cache</artifactId>
    <version>19.0.0</version>
</dependency>
```