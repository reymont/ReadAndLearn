

# https://github.com/wurstmeister/kafka-docker/issues/123

```yaml
version: '2'
services:
  zookeeper:
    image: wurstmeister/zookeeper
    ports:
      - "2181:2181"
  kafka:
    build: .
    ports:
      - "9092:9092"
      - "9093:9093"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.1.110
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      JMX_PORT: 9093
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
  kafka-manager:
    image: sheepkiller/kafka-manager
    ports:
      - "9000:9000"
    links:
      - zookeeper
    environment:
      ZK_HOSTS: zookeeper:2181
      APPLICATION_SECRET: letmein 
```