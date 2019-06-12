

# https://logback.qos.ch/manual/configuration.html#contextName

Setting the context name

As mentioned in an earlier chapter, every logger is attached to a logger context. By default, the logger context is called "default". However, you can set a different name with the help of the <contextName> configuration directive. Note that once set, the logger context name cannot be changed. Setting the context name is a simple and straightforward method in order to distinguish between multiple applications logging to the same target.

Example: Set the context name and display it (logback-examples/src/main/resources/chapters/configuration/contextName.xml)

View as .groovy
```xml
<configuration>
  <contextName>myAppName</contextName>
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <encoder>
      <pattern>%d %contextName [%t] %level %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>

  <root level="debug">
    <appender-ref ref="STDOUT" />
  </root>
</configuration>
```
This last example illustrates naming of the logger context. Adding the contextName conversion word in layout's pattern will output the said name.