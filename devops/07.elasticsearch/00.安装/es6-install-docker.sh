

https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html

docker run -e ELASTIC_PASSWORD=MagicWord docker.elastic.co/elasticsearch/elasticsearch-platinum:6.0.1
# Docker images can be retrieved with the following commands:
docker pull docker.elastic.co/elasticsearch/elasticsearch:6.0.1
docker pull docker.elastic.co/elasticsearch/elasticsearch-platinum:6.0.1
docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:6.0.1
# Development mode
## Elasticsearch can be quickly started for development or testing use with the following command:
docker run -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:6.0.1
# Production mode
grep vm.max_map_count /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
# Inspect status of cluster:
curl http://127.0.0.1:9200/_cat/health
# Elasticsearch loads its configuration from files under 
/usr/share/elasticsearch/config/
# By default, Elasticsearch runs inside the container as user elasticsearch using uid:gid 1000:1000.
mkdir esdatadir
chmod g+rwx esdatadir
chgrp 1000 esdatadir
# docker-compose.yml:
docker-compose up
## Data volumes will persist
docker-compose down 
## To destroy the cluster and the data volumes
docker-compose down -v.
```yml
version: '2.2'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:6.0.1
    container_name: elasticsearch
    environment:
      - cluster.name=docker-cluster
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - esdata1:/usr/share/elasticsearch/data
    ports:
      - 9200:9200
    networks:
      - esnet
  elasticsearch2:
    image: docker.elastic.co/elasticsearch/elasticsearch:6.0.1
    container_name: elasticsearch2
    environment:
      - cluster.name=docker-cluster
      - bootstrap.memory_lock=true
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - "discovery.zen.ping.unicast.hosts=elasticsearch"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - esdata2:/usr/share/elasticsearch/data
    networks:
      - esnet

volumes:
  esdata1:
    driver: local
  esdata2:
    driver: local

networks:
  esnet:
```
