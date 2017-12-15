

# https://hub.docker.com/_/kibana/

# How to use this image
# You can run the default kibana command simply:
docker run --link some-elasticsearch:elasticsearch -d kibana
# You can also pass in additional flags to kibana:
docker run --link some-elasticsearch:elasticsearch -d kibana --plugins /somewhere/else
# This image includes EXPOSE 5601 (default port). If you'd like to be able to access the instance from the host without the container's IP, standard port mappings can be used:
docker run --name some-kibana --link some-elasticsearch:elasticsearch -p 5601:5601 -d kibana
# You can also provide the address of elasticsearch via ELASTICSEARCH_URL environnement variable:
docker run --name some-kibana -e ELASTICSEARCH_URL=http://some-elasticsearch:9200 -p 5601:5601 -d kibana
# Then, access it via http://localhost:5601 or http://host-ip:5601 in a browser.