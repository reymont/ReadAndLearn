

http://wpcertification.blogspot.hk/2016/11/how-to-use-kafkalog4jappender-for.html


How to use KafkaLog4jAppender for sending Log4j logs to kafka
Apache Kafka has a KafkaLog4jAppender that you can use for redirecting your Log4j log to Kafka topic. I wanted to try it out so i used following steps, you can download sample project from here First i created a simple standalone java program that use Log4j like this. As you can see this is like any other normal Java program that uses Log4j.
package com.spnotes.kafka;


import org.apache.log4j.LogManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by sunilpatil on 11/7/16.
 */
public class HelloKafkaLogger {
    private static final Logger logger = LoggerFactory.getLogger(HelloKafkaLogger.class);

    public static void main(String[] argv) {
        logger.debug("Debug message from HelloKafkaLogger.main," );
        logger.info("Info message from HelloKafkaLogger.main" );
        logger.warn("Warn message from HelloKafkaLogger.main");
        logger.error("Error message from HelloKafkaLogger.main" );
        LogManager.shutdown();
    }
}
view rawHelloKafkaLogger.java hosted with ❤ by GitHub
Then in the log4j.properties file i added line 12 to 17 for using KafkaLog4jAppender, on line 13, value of brokerList property points to the Kafka server and line 14 value of topic points to the Kafka topic name to which logs should go.
# Root logger option
log4j.rootLogger=DEBUG, stdout, kafka
log4j.logger.kafka=WARN
log4j.logger.org.apache.kafka=WARN

# Redirect log messages to console
log4j.appender.stdout=org.apache.log4j.ConsoleAppender
log4j.appender.stdout.Target=System.out
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n

log4j.appender.kafka=org.apache.kafka.log4jappender.KafkaLog4jAppender
log4j.appender.kafka.brokerList=localhost:9092
log4j.appender.kafka.topic=kafkalogger
log4j.appender.kafka.layout=org.apache.log4j.PatternLayout
log4j.appender.kafka.layout.ConversionPattern=%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1}:%L - %m%n
log4j.appender.kafka.level=INFO
view rawlog4j.properties hosted with ❤ by GitHub
Now before running this program make sure that you actually have topic named kafkalogger, if not you can create using this command

bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic kafkalogger
You can verify if you have topic named kafkalogger by executing following command

bin/kafka-topics.sh --list --zookeeper localhost:2181
Also you can run kafka console consumer that reads messages from Kafka and prints them to console, using following command

bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic kafkalogger
Now when you run your java program you should see messages on console like this
