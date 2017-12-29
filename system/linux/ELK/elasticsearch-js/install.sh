


$ npm install --save elasticsearch
# + elasticsearch@14.0.0

docker-machine start
eval $(docker-machine env)
docker pull elasticsearch:5.6.3

# https://github.com/elastic/elasticsearch-docker/issues/43
docker run -p 9200:9200 \
-e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
-e "http.host=0.0.0.0" \
-e "transport.host=127.0.0.1" \
docker.elastic.co/elasticsearch/elasticsearch:5.2.2

# https://github.com/elastic/elasticsearch-docker/issues/11
docker run --privileged=true --name es -d \
-p 9200:9200 \
-e ES_JAVA_OPTS="-Xms512m -Xmx512m" \
elasticsearch:5.6.3

curl 192.168.99.100:9200
