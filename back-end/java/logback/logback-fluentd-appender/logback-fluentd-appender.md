

https://github.com/linux-china/logback-fluentd-appender

Logback fluentd appender
==================================================
is appenders for [Logback](http://logback.qos.ch/).
You can logging to Fluentd with the logback appender.

Appenders
--------------------------------------
- [fluentd](http://fluentd.org/) 
    - depend on [fluent-logger for Java](https://github.com/fluent/fluent-logger-java).   
     - Install fluentd before running logger.


Installing
--------------------------------------	

###Install jars from Maven2 repository
Configure your pom.xml:

```
<dependencies>

  <dependency>
    <groupId>com.sndyuk</groupId>
    <artifactId>logback-fluentd-appender</artifactId>
    <version>1.1.0</version>
  </dependency>

</dependencies>

<repositories>
  <repository>
    <id>com.sndyuk</id>
    <name>Logback more appenders</name>
    <url>http://sndyuk.github.com/maven</url>
  </repository>
</repositories>
```

### Configure your logback.xml
You can find configuration files here:
 
- [logback.xml](https://github.com/linux-china/logback-fluentd-appender/blob/master/src/test/resources/logback.xml)


License
--------------------------------------
[MIT LICENSE](LICENSE)
