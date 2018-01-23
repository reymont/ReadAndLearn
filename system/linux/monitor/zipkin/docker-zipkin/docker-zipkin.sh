
# elk
curl localhost:9200/_cat/indices

# https://github.com/openzipkin/docker-zipkin

docker-compose -f docker-compose.yml -f docker-compose-ui.yml up

      - STORAGE_TYPE=elasticsearch
      - ES_HOSTS=elasticsearch

docker run -d -p 9411:9411 openzipkin/zipkin
docker run -d -p 9411:9411 --restart always --name zipkin index.docker.io/openzipkin/zipkin:2.4
docker run -d -p 9411:9411 --restart always --name zipkin \
-e STORAGE_TYPE=elasticsearch \
-e ES_HOSTS=elasticsearch \
--link=es:elasticsearch \
index.docker.io/openzipkin/zipkin:2.4