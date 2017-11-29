

docker搭建系列
docker环境搭建zk集群
docker搭建redis集群
docker环境搭建elasticsearch
docker搭建rabbitmq集群
docker环境搭建ELK
序
本文主要讲述如何用docker搭建rabbitmq的集群。

下载镜像
采用bijukunjummen该镜像。

git clone https://github.com/bijukunjummen/docker-rabbitmq-cluster.git
运行
启动集群
cd docker-rabbitmq-cluster/cluster
docker-compose up -d
......
Status: Downloaded newer image for bijukunjummen/rabbitmq-server:latest
docker.io/bijukunjummen/rabbitmq-server: this image was pulled from a legacy registry.  Important: This registry version will not be supported in future versions of docker.
Creating cluster_rabbit1_1
Creating cluster_rabbit2_1
Creating cluster_rabbit3_1
默认启动了三个节点

rabbit1:
  image: bijukunjummen/rabbitmq-server
  hostname: rabbit1
  ports:
    - "5672:5672"
    - "15672:15672"

rabbit2:
  image: bijukunjummen/rabbitmq-server
  hostname: rabbit2
  links:
    - rabbit1
  environment:
   - CLUSTERED=true
   - CLUSTER_WITH=rabbit1
   - RAM_NODE=true
  ports:
      - "5673:5672"
      - "15673:15672"

rabbit3:
  image: bijukunjummen/rabbitmq-server
  hostname: rabbit3
  links:
    - rabbit1
    - rabbit2
  environment:
   - CLUSTERED=true
   - CLUSTER_WITH=rabbit1
  ports:
        - "5674:5672"
查看
docker@default:~$ docker ps
CONTAINER ID        IMAGE                           COMMAND                  CREATED             STATUS              PORTS                                                                                  NAMES
ba5f665bb213        bijukunjummen/rabbitmq-server   "/bin/sh -c /opt/rabb"   10 minutes ago      Up 10 minutes       4369/tcp, 9100-9105/tcp, 15672/tcp, 25672/tcp, 0.0.0.0:5674->5672/tcp                  cluster_rabbit3_1
b9466e206b2b        bijukunjummen/rabbitmq-server   "/bin/sh -c /opt/rabb"   10 minutes ago      Up 10 minutes       4369/tcp, 9100-9105/tcp, 25672/tcp, 0.0.0.0:5673->5672/tcp, 0.0.0.0:15673->15672/tcp   cluster_rabbit2_1
b733201aeadf        bijukunjummen/rabbitmq-server   "/bin/sh -c /opt/rabb"   10 minutes ago      Up 10 minutes       4369/tcp, 0.0.0.0:5672->5672/tcp, 9100-9105/tcp, 0.0.0.0:15672->15672/tcp, 25672/tcp   cluster_rabbit1_1
88196436c434        daocloud.io/daocloud/daomonit   "/usr/local/bin/daomo"   37 hours ago        Up 2 hours                                                                                                 daomonit
访问
http://192.168.99.100:15672，弹出登陆界面

输入guest/guest


参考
docker-rabbitmq-cluster
tutum/rabbitmq

https://github.com/bijukunjummen/docker-rabbitmq-cluster
https://hub.docker.com/r/tutum/rabbitmq/