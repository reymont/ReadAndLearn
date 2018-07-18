

docker pull zookeeper

https://hub.docker.com/_/zookeeper/
https://github.com/31z4/zookeeper-docker

# How to use this image
Start a Zookeeper server instance
`docker run --name some-zookeeper --restart always -d zookeeper`
`docker run --name zk -p 2181:2181 --restart always -d zookeeper`

This image includes EXPOSE 2181 2888 3888 (the zookeeper client port, follower port, election port respectively), so standard container linking will make it automatically available to the linked containers. Since the Zookeeper "fails fast" it's better to always restart it.

Connect to Zookeeper from an application in another Docker container
$ docker run --name some-app --link some-zookeeper:zookeeper -d application-that-uses-zookeeper
Connect to Zookeeper from the Zookeeper command line client
$ docker run -it --rm --link some-zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper
... via docker stack deploy or docker-compose
Example stack.yml for zookeeper:

version: '3.1'

services:
  zoo1:
    image: zookeeper
    restart: always
    hostname: zoo1
    ports:
      - 2181:2181
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=0.0.0.0:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888

  zoo2:
    image: zookeeper
    restart: always
    hostname: zoo2
    ports:
      - 2182:2181
    environment:
      ZOO_MY_ID: 2
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=0.0.0.0:2888:3888 server.3=zoo3:2888:3888

  zoo3:
    image: zookeeper
    restart: always
    hostname: zoo3
    ports:
      - 2183:2181
    environment:
      ZOO_MY_ID: 3
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=0.0.0.0:2888:3888


This will start Zookeeper in replicated mode. Run docker stack deploy -c stack.yml zookeeper (or docker-compose -f stack.yml up) and wait for it to initialize completely. Ports 2181-2183 will be exposed.

Please be aware that setting up multiple servers on a single machine will not create any redundancy. If something were to happen which caused the machine to die, all of the zookeeper servers would be offline. Full redundancy requires that each server have its own machine. It must be a completely separate physical server. Multiple virtual machines on the same physical host are still vulnerable to the complete failure of that host.

Consider using Docker Swarm when running Zookeeper in replicated mode.

Configuration
Zookeeper configuration is located in /conf. One way to change it is mounting your config file as a volume:

$ docker run --name some-zookeeper --restart always -d -v $(pwd)/zoo.cfg:/conf/zoo.cfg zookeeper
Environment variables
ZooKeeper recommended defaults are used if zoo.cfg file is not provided. They can be overridden using the following environment variables.

$ docker run -e "ZOO_INIT_LIMIT=10" --name some-zookeeper --restart always -d 31z4/zookeeper
