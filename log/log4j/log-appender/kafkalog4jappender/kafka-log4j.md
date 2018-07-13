

ameizi/kafka-log4j: 使用kafka实现log4j日志集中管理 
https://github.com/ameizi/kafka-log4j

```java
package net.aimeizi.kafka;

import org.apache.log4j.Logger;

public class App {
    private static final Logger LOGGER = Logger.getLogger(App.class);

    public static void main(String[] args) throws InterruptedException {

//        for (int i = 20; i < 25; i++) {
//            LOGGER.info("This is Message [" + i + "] from log4j producer");
//            Thread.sleep(1000);
//        }

        for (int i = 20; i < 40; i++) {
            LOGGER.info("Info [" + i + "]");
            Thread.sleep(1000);
        }

//        LOGGER.debug("Debug Message.");
//        LOGGER.info("Info Message.");
//        LOGGER.warn("Warn Message.");
//        LOGGER.error("Error Message.");
//        LOGGER.fatal("Fatal Message.");
    }
}
```


```conf
log4j.rootLogger=INFO,console

log4j.logger.net.aimeizi.kafka=DEBUG,kafka

# appender kafka
log4j.appender.kafka=kafka.producer.KafkaLog4jAppender
log4j.appender.kafka.topic=iot
# log4j.appender.kafka.brokerList=localhost:9092,localhost:9093, localhost:9094, localhost:9095
log4j.appender.kafka.brokerList=172.20.62.42:9092
log4j.appender.kafka.compressionType=none
log4j.appender.kafka.syncSend=true
log4j.appender.kafka.layout=org.apache.log4j.PatternLayout
log4j.appender.kafka.layout.ConversionPattern=%d [%-5p] [%t] - [%l] %m%n
 
# appender console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.target=System.out
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d [%-5p] [%t] - [%l] %m%n
```