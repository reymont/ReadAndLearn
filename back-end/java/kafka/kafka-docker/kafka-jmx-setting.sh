

# https://github.com/wurstmeister/kafka-docker/pull/84
# KAFKA_JMX_OPTS is not part of server.properties file, but it defines kafka launch mode
# https://github.com/apache/kafka/blob/1e4dd66b19857f4f0ce3f83fd0a808885b0a88c1/bin/kafka-run-class.sh#L137

```sh
# JMX settings
if [ -z "$KAFKA_JMX_OPTS" ]; then
  KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false "
fi

# JMX port to use
if [  $JMX_PORT ]; then
  KAFKA_JMX_OPTS="$KAFKA_JMX_OPTS -Dcom.sun.management.jmxremote.port=$JMX_PORT "
fi
```