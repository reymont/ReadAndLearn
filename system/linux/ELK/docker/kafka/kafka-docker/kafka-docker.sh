

# https://github.com/wurstmeister/kafka-docker
# https://hub.docker.com/r/wurstmeister/kafka/
# http://wurstmeister.github.io/kafka-docker/

docker pull wurstmeister/kafka:1.0.0

git clone https://github.com/wurstmeister/kafka-docker.git
# Usage
# Start a cluster:
docker-compose up -d
# Add more brokers:
docker-compose scale kafka=3
# Destroy a cluster:
docker-compose stop
docker-compose -f docker-compose-single-broker.yml up