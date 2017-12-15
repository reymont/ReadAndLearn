

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

# fluent-plugin-kafka 0.5.3 to kafka 2.11-0.10.2.0 failed · Issue #123 · fluent/fluent-plugin-kafka 
# https://github.com/fluent/fluent-plugin-kafka/issues/123
# the config /opt/kafka/config/server.properties of kafka should be:
listeners=PLAINTEXT://172.16.154.242:9092
advertised.listeners=PLAINTEXT://172.16.154.242:9092

# Example
## Given the environment seen here, the following configuration will be written to the Kafka broker properties.
HOSTNAME_COMMAND: curl http://169.254.169.254/latest/meta-data/public-hostname
KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT
KAFKA_ADVERTISED_PROTOCOL_NAME: OUTSIDE
KAFKA_PROTOCOL_NAME: INSIDE
KAFKA_ADVERTISED_PORT: 9094
## The resulting configuration:
advertised.listeners = OUTSIDE://ec2-xx-xx-xxx-xx.us-west-2.compute.amazonaws.com:9094,INSIDE://:9092
listeners = OUTSIDE://:9094,INSIDE://:9092
inter.broker.listener.name = INSIDE