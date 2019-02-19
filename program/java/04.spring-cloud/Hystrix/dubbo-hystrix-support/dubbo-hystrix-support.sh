

# https://hub.docker.com/_/zookeeper/
docker pull zookeeper

docker run -it --rm --link some-zookeeper:zookeeper zookeeper zkCli.sh -server zookeeper
docker run -p 2181:2181 --name zk --restart always -d zookeeper